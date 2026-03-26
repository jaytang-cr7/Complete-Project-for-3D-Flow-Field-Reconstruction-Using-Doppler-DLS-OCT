%%%%%%% Codes for data processing in OCT.
%%%%%%% Process raw spectrum data for Bscan images using interpolation and
%%%%%%% FFT.
%%%%%%% Several bscans is averaged to enhance constrast at last.
%%%%%%% Processed data is saved in .bin file for further analyse.


clear;
%% 对重复采集文件批处理
% 获取当前文件夹下所有.raw文件
files = dir('*.raw');

% 按文件的修改时间排序
[~, idx] = sort([files.datenum]);

% 重新命名文件
for i = 1:length(idx)
    oldName = files(idx(i)).name;
    newName = [num2str(i), '.raw'];
    movefile(oldName, newName);
end

disp('文件重命名完成！');


%% ------------------- parameters --------------------------------
fpBase = '';
% fpRawData = [fpBase, '1.raw'];
%fpProcessedData = [fpBase, 'p_1.raw'];

samplesPerAline = 2048;        % samples per aline
alinesPerBscan = 5000;         % alines per bscan
bscansPerVolume = 200;            % bscans per volume

bytesPerSample = 1;        % bytes per sample
fmt = 'uint8';           % format of the raw data
    
offsetDC = 1;             % offset to remove DC term
frame2Average = 10;        % number of frames to average

grayMat = [30 70];      % [Min value, max value], theroshold to adjust the gray value of the image
idxBscan = 3;          % index of the bscan to check

dz = 1.886173;    % length of one pixel in aline, unit micrometer

% --------------------------------------------------------------------
N = samplesPerAline;
M = alinesPerBscan;
A = bscansPerVolume;

%% read the vectors for resampling and dispersion compensation
k = importdata([fpBase, 'k.mat']);
kEven = importdata([fpBase, 'kEven.mat']);
dispComp = importdata([fpBase, 'dispComp.mat']);

%% 循环处理每个.raw文件（从1.raw到78.raw）
for i_raw = 31:50
    % 动态生成.raw文件名
    fpRawData = [fpBase, num2str(i_raw), '.raw'];

    % 获取当前文件夹中的文件名
    [~, rawFileName, ~] = fileparts(fpRawData);  % 获取文件名（不含扩展名）
    % 创建以.raw文件名命名的文件夹
    outputFolder = fullfile(fpBase, rawFileName);
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);
    end
    % 创建用于保存 volume_complex 和 volume 的子文件夹
    volumeComplexFolder = fullfile(outputFolder, 'volume_complex');
    if ~exist(volumeComplexFolder, 'dir')
        mkdir(volumeComplexFolder);
    end
    volumeFolder = fullfile(outputFolder, 'volume');
    if ~exist(volumeFolder, 'dir')
        mkdir(volumeFolder);
    end

    % 定义逐帧保存的代码
    fid = fopen(fpRawData, 'r');
    if fid == -1
        error('无法打开文件');
    end
    window = hanning(N);
    for frameNr = 1 : bscansPerVolume
        disp(frameNr);  % 显示当前帧号

        % 定位到当前帧的位置
        fseek(fid, N * M * (frameNr - 1) * bytesPerSample, -1);
        speRaw = fread(fid, [N, M], fmt);

        % 数据处理
        speInterp = interp1(k, speRaw, kEven, 'spline');
        spe4FPRemove = mean(speInterp, 2);
        speInterp = speInterp - spe4FPRemove;
        speComp = speInterp .* dispComp .* window;
        frame_complex = ifft(speComp) * N;

        % 保存frame_complex数据到 volume_complex 文件夹
        volume_complex_data = frame_complex(1 : N / 2, :);
        save(fullfile(volumeComplexFolder, sprintf('volume_complex_data_%04d.mat', frameNr)), 'volume_complex_data');

        % 保存frame数据到 volume 文件夹
        frame = 20 * log10(abs(ifft(speComp) * N));
        volume_data = frame(1 : N / 2, :);
        save(fullfile(volumeFolder, sprintf('volume_data_%04d.mat', frameNr)), 'volume_data');
    end

    fclose(fid);




    % 获取 volume 和 volume_complex 文件夹中的所有 .mat 文件
    volumeFiles = dir(fullfile(volumeFolder, '*.mat'));
    volumeComplexFiles = dir(fullfile(volumeComplexFolder, '*.mat'));

    % 遍历 volume 文件夹中的所有 .mat 文件
    for i = 1:length(volumeFiles)
        % 获取文件名和帧号
        [~, fileName, ext] = fileparts(volumeFiles(i).name);
        frameNr = str2double(fileName(end-3:end));  % 获取帧号

        % 对偶数帧进行处理
        if mod(frameNr, 2) == 0
            % 加载数据
            load(fullfile(volumeFolder, volumeFiles(i).name), 'volume_data');

            % 对数据进行fliplr操作
            volume_data = fliplr(volume_data);

            % 保存修改后的数据
            save(fullfile(volumeFolder, volumeFiles(i).name), 'volume_data');
        end
    end

    % 遍历 volume_complex 文件夹中的所有 .mat 文件
    for i = 1:length(volumeComplexFiles)
        % 获取文件名和帧号
        [~, fileName, ext] = fileparts(volumeComplexFiles(i).name);
        frameNr = str2double(fileName(end-3:end));  % 获取帧号

        % 对偶数帧进行处理
        if mod(frameNr, 2) == 0
            % 加载数据
            load(fullfile(volumeComplexFolder, volumeComplexFiles(i).name), 'volume_complex_data');

            % 对数据进行fliplr操作
            volume_complex_data = fliplr(volume_complex_data);

            % 保存修改后的数据
            save(fullfile(volumeComplexFolder, volumeComplexFiles(i).name), 'volume_complex_data');
        end
    end


    % 创建相位结果的文件夹
    faizFolder = fullfile(volumeComplexFolder, 'faiz');
    if ~exist(faizFolder, 'dir')
        mkdir(faizFolder);
    end

    % 创建vz结果的文件夹
    vzFolder = fullfile(volumeComplexFolder, 'vz');
    if ~exist(vzFolder, 'dir')
        mkdir(vzFolder);
    end


    % 获取 volume_complex 文件夹中的所有 .mat 文件
    volumeComplexFiles = dir(fullfile(volumeComplexFolder, '*.mat'));
    % 定义窗口大小
    window_size = 4;
    % 阈值判定
    threshold = 30;



    % 遍历每个 .mat 文件
    for i = 2:2:length(volumeComplexFiles)
        % 加载每个 .mat 文件的数据
        matFile = fullfile(volumeComplexFolder, volumeComplexFiles(i).name);
        load(matFile, 'volume_complex_data');  % 假设每个 .mat 文件包含名为 volume_complex_data 的二维矩阵
        matFile = fullfile(volumeFolder, volumeFiles(i).name);
        load(matFile, 'volume_data');  % 假设每个 .mat 文件包含名为 volume_complex_data 的二维矩阵

        % 获取数据的尺寸
        [rows, cols] = size(volume_complex_data);
        volume_complex_data(volume_data < threshold) = 0;

        % 你可以在这里加入自己的计算代码，例如：
        % ---- 在这里开始添加你的计算 ----
        % 请将你自己的计算逻辑添加到这里，使用 'volume_complex_data'
        % ---- 计算完成后，请将结果存储到 'fai_z' 变量 ----

        % 初始化结果矩阵（根据你的计算需求）
        fai_z = zeros(rows - window_size + 1, cols - window_size + 1);  % 根据你的计算结果调整
        % 使用 GPU 加速（如果可用）
        volume_complex_data = gpuArray(volume_complex_data);
        fai_z = gpuArray(fai_z);

        tic;
        % 矩阵运算优化

        % 初始化分子和分母
        numerator_matrix = zeros(rows - window_size + 1, cols - window_size + 1, 'gpuArray');
        denominator_matrix = zeros(rows - window_size + 1, cols - window_size + 1, 'gpuArray');

        for i_w = 1:window_size
            % 窗口的第 k 行
            row_data = volume_complex_data(i_w:rows-window_size+i_w, :);

            % 分子计算
            numerator_matrix = numerator_matrix + ...
                imag(row_data(:, 2:cols-window_size+2)) .* real(row_data(:, 1:cols-window_size+1)) - ...
                imag(row_data(:, 1:cols-window_size+1)) .* real(row_data(:, 2:cols-window_size+2));

            % 分母计算
            denominator_matrix = denominator_matrix + ...
                real(row_data(:, 1:cols-window_size+1)) .* real(row_data(:, 2:cols-window_size+2)) + ...
                imag(row_data(:, 1:cols-window_size+1)) .* imag(row_data(:, 2:cols-window_size+2));
        end


        % 计算相位差
        phase_diff = atan2(numerator_matrix, max(denominator_matrix, eps)); % 避免分母为零
        fai_z = gather(phase_diff);

        % 转换结果到 CPU（如果在 GPU 上运行）
        fai_z = gather(fai_z);
        volume_complex_data = gather(volume_complex_data);
        toc;

        % 保存计算结果到新的faiz文件夹
        % 构建新的文件名
        %     [~, fileName, ~] = fileparts(volumeComplexFiles(i).name);

        faizFileName = sprintf('faiz1_%d.mat', i);  % 使用i作为编号
        save(fullfile(faizFolder, faizFileName), 'fai_z');  % 保存到faiz文件夹中
        vz =(fai_z*0.84)/(4*1.6*pi*0.01);

        figure;
        imagesc(vz); % 显示第 page 页的矩阵
        colormap('jet'); % 使用 jet 色彩图
        colorbar; % 添加颜色条
        pause(0.1); % 暂停0.5秒
        close;  % 关闭当前 figure
        vzFileName = sprintf('vz1_%d.mat', i);  % 使用i作为编号
        save(fullfile(vzFolder, vzFileName), 'vz');  % 保存到faiz文件夹中
    end

end


