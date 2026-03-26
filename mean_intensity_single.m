clear;

% 读取ROI的强度图像的奇数帧，做DLS计算
num_files = 50;

% 预加载第一个文件以确定数据的大小
first_data = load('1.mat'); 
field_name = fieldnames(first_data); % 获取变量名
data_sample = first_data.(field_name{1}); % 获取变量数据
[data_rows, data_cols] = size(data_sample); % 获取数据尺寸

% 预分配三维矩阵
volume = zeros(data_rows, data_cols, num_files);

% 依次读取文件并存入三维矩阵
for i = 1:num_files
    filename = sprintf('%d.mat', i); % 生成文件名
    temp_data = load(filename);
    volume(:,:,i) = temp_data.(field_name{1}); % 存入三维矩阵
end



% 读取对应ROI的相位差faiz数据图像，计算vz
folderPath = 'H:\12.23正式实验\B-SCAN流动（3D,5000,200,100）\doppler_OCT\190';
% 确定文件数量
num_files = 50; % 共有35个.mat文件
% 读取第一个.mat文件以确定矩阵大小
first_data = load(fullfile(folderPath, '1.mat'));
% firstData = load(first_data);
field_name = fieldnames(first_data);
data_sample = first_data.(field_name{1});
[data_rows, data_cols] = size(data_sample);

% 预分配三维矩阵
volume_faiz = zeros(data_rows, data_cols, num_files);
% 读取所有.mat文件并存入三维矩阵
for i = 1:num_files
    filename = fullfile(folderPath, sprintf('%d.mat', i));
    temp_data = load(filename);
    volume_faiz(:,:,i) = temp_data.(field_name{1});
end

grayMat = [0 70];
%% figure one bscan to check the result
frame2Check = volume(:, :, 3);
I = mat2gray(frame2Check, grayMat);   % [min max] where min = 0(black), max = 1(white)
figure;imagesc(I);colormap(gray);axis off;

FileNameOCT=fullfile(['OCT','.bmp']);
imwrite(I,FileNameOCT);
imshow(FileNameOCT);

%% 选一张B-Scan计算图像截取部分
for i = 1:1:50
    OCT_1 = volume(:,:,i);
%     OCT_1 = squeeze(OCT_1);  % B 鐨勫ぇ灏忓皢鏄? 500*500
    OCT_1_pic = mat2gray(OCT_1, grayMat);
    imshow(OCT_1_pic);
    pause(0.3); % 暂停0.5秒
end

OCT_1 = volume(:,:,3);
OCT_1_pic = mat2gray(OCT_1, grayMat);  
imshow(OCT_1_pic);
FileNameOCT=fullfile(['OCT_AC','.bmp']);
imwrite(uint8(OCT_1),FileNameOCT);
imshow(FileNameOCT);

%% 图像旋转
matrix = OCT_1;
% 角度转弧度
angleInDegrees = 0; %正数为顺时针旋转2.7
angleInRadians = deg2rad(angleInDegrees);
% 计算矩阵中心坐标
centerX = size(matrix, 2) / 2;
centerY = size(matrix, 1) / 2;
% 绕中心顺时针旋转
rotatedMatrix = imrotate(matrix, -angleInDegrees, 'bilinear', 'crop');
rotatedMatrix_pic = mat2gray(rotatedMatrix, grayMat);  
imshow(rotatedMatrix_pic);
FileNameOCT=fullfile(['OCT_rotated','.bmp']);
imwrite(uint8(rotatedMatrix),FileNameOCT);
imshow(FileNameOCT);


% volume整体进行旋转
%rotated_volume = zeros(N / 2, M, A);
for i = 1:50
    volume(:,:,i) = imrotate(volume(:,:,i), -angleInDegrees, 'bilinear', 'crop'); %rotated_volume
end

for i = 1:50
    volume_faiz(:,:,i) = imrotate(volume_faiz(:,:,i), -angleInDegrees, 'bilinear', 'crop'); %rotated_volume
end

% rotatedMatrix = OCT_1;
% rotated_volume = volume;
%% 截取图像某部分
OCT_x1 = 268;% 左边：274
OCT_x2 = 388;% 左边：394
OCT_y1 = 3381;% 左边：651
OCT_y2 = 3780;% 左边：1050

OCT_1_cut = rotatedMatrix(OCT_x1:OCT_x2,OCT_y1:OCT_y2);
FileNameOCT=fullfile(['OCT_AC_cut','.bmp']);
imwrite(uint8(OCT_1_cut),FileNameOCT);
imshow(FileNameOCT);

%% 截取所有图像某部分
OCT_1_pic_real = volume(OCT_x1:OCT_x2,OCT_y1:OCT_y2,:);  %用强度计算自相关   %% 这个位置对奇数帧进行操作
volume_faiz_real = volume_faiz(OCT_x1:OCT_x2,OCT_y1:OCT_y2,:);
fai_z_mean_ROI = mean(volume_faiz_real,3);
vz =(fai_z_mean_ROI*0.84)/(4*1.6*pi*0.01);

% 定义颜色的RGB值
blue = [0, 0, 1];
cyan = [0, 1, 1];
black = [0, 0, 0];
orange = [1, 0.647, 0];  % RGB for orange
red = [1, 0, 0];
% 生成渐变
n = 256;  % 自定义颜色图的长度
c1 = interp1([0, 1], [blue; cyan], linspace(0, 1, n/4));  % 蓝到青
c2 = interp1([0, 1], [cyan; black], linspace(0, 1, n/4));  % 青到黑
c3 = interp1([0, 1], [black; orange], linspace(0, 1, n/4));  % 黑到橙
c4 = interp1([0, 1], [orange; red], linspace(0, 1, n/4));  % 橙到红
% 合并颜色
myColormap = [c1; c2; c3; c4];
% 显示自定义colormap
colormap(myColormap);
colorbar;

%vmean = mean(vz(180:200,2160:2260),"all");

figure;
imagesc(vz); % 显示第 page 页的矩阵
colormap(myColormap); % 使用 jet 色彩图
colorbar; % 添加颜色条
clim([-5 5]);

% vz_demo = vz(:,1401:1600); %2301  2500
vz_demo = vz;
figure;
imagesc(vz_demo); % 显示第 page 页的矩阵
colormap(myColormap); % 使用 jet 色彩图
colorbar; % 添加颜色条
clim([-5 5]);

vz_mean = mean(vz_demo,2);  %注意正负


%% DLS

OCT_x1 = 1;  
OCT_x2 = 121; %461
OCT_y1 = 1;%1201  roi2(400)-801:1200  roi3(400左)-1301:1700()
OCT_y2 = 400;%1600

% *******************η偶计算***********************
OCT_1_pic_real_ji = OCT_1_pic_real;  %用强度计算自相关   %% 这个位置对偶数帧进行操作

AC_page = size(OCT_1_pic_real_ji,3);
%% 去噪
OCT_1_pic_real_ji(OCT_1_pic_real_ji <= 0) = 0; %%25
OCT_1_pic_real_ji(OCT_1_pic_real_ji >= 70) = 70;

OCT_1_real_pic = OCT_1_pic_real_ji(:,:,3);
FileNameOCT=fullfile(['OCT_1_real_pic','.bmp']);
imwrite(uint8(OCT_1_real_pic),FileNameOCT);
imshow(FileNameOCT);


%% 自相关算法（Pearson阈值去噪）

% 创建一个新矩阵来存放自相关系数
autoCorrelationCoefficients_2 = zeros(OCT_x2-OCT_x1+1, (OCT_y2-OCT_y1+1)/2, AC_page);
% 对每一页进行自相关计算
for i = 1:AC_page
    for row = 1:(OCT_x2-OCT_x1+1)
        for col = 1:(OCT_y2-OCT_y1+1)/2
            % 获取当前自相关的数据范围
            std_data = OCT_1_pic_real_ji(row, 1:(OCT_y2-OCT_y1+1)/2,i);
            test_data = OCT_1_pic_real_ji(row, col:col + (OCT_y2-OCT_y1+1)/2 - 1,i);
            % 计算相关矩阵
            cov_temp = cov(test_data,std_data);
            % 存储自相关系数
            autoCorrelationCoefficients_2(row, col, i) = (cov_temp(1,2)/(cov_temp(1,1)*cov_temp(2,2)).^0.5);
        end
    end
end

save('autoCorrelationCoefficients__10000（400）_奇_roi3.mat', 'autoCorrelationCoefficients_2');
%autoCorrelationCoefficients_line = mean(autoCorrelationCoefficients_2(:, :, 2:199),3);
autoCorrelationCoefficients_line = mean(autoCorrelationCoefficients_2(:, :, 1:AC_page),3);
%行平均auto矩阵
autoCorrelationCoefficients_line_mean = autoCorrelationCoefficients_line;
save('autoCorrelationCoefficients_mean__10000（400）_奇_roi3.mat', 'autoCorrelationCoefficients_line_mean');
%% 非线性指数拟合，给定固定方程
%行平均auto矩阵
delay_1 = autoCorrelationCoefficients_line_mean(:, 2);
% 归一化第一时滞自相关
for i = 1:size(autoCorrelationCoefficients_line_mean, 1)
    autoCorrelationCoefficients_line_mean(i, :) = autoCorrelationCoefficients_line_mean(i, :) / delay_1(i);
end
% 删除包含NaN的行
rowsToDelete = any(isnan(autoCorrelationCoefficients_line_mean), 2);
autoCorrelationCoefficients_line_mean(rowsToDelete, :) = [];
% ln_auto = log(abs(autoCorrelationCoefficients_line_mean(:,1:10)));


% 负数截断操作
non_zero_counts = zeros(size(autoCorrelationCoefficients_line_mean, 1), 1); % 初始化存放非零数据个数的矩阵
for i = 1:size(autoCorrelationCoefficients_line_mean, 1)
    % 查找当前行<1/e^2的数
    neg_indices = find(autoCorrelationCoefficients_line_mean(i, :) < 0.1);
    if ~isempty(neg_indices)
        % 将第一个负数及其后面的所有数置为零
        autoCorrelationCoefficients_line_mean(i, neg_indices(1):end) = 0;
    end
    % 统计当前行非零数据的个数
    non_zero_counts(i) = nnz(autoCorrelationCoefficients_line_mean(i, :)); % 计算当前行的非零元素个数
end

autoCorrelationCoefficients_line_mean = autoCorrelationCoefficients_line_mean(1:121,:); %40:431 %roi3(400左)-39:604
non_zero_counts = non_zero_counts(1:121,:);

% 初始化矩阵，用于存放拟合结果和最优参数
fitResultsMatrix = cell(121, 2);
% 对每一行数据进行拟合
for i = 1:121
    % 取出当前行数据
    row_data = autoCorrelationCoefficients_line_mean(i,2:non_zero_counts(i));  %原始数据或ln数据
    % 提取自变量和因变量
    x = (0.01:0.01:non_zero_counts(i)/100 - 0.01)';   %注意是否第一时滞归一化
    y = (row_data)';
    % 使用拟合函数进行拟合
    [fitresult, gof] = createFit(x, y);
    % 将拟合结果和最优参数存放到新的矩阵中
    fitResultsMatrix{i, 1} = fitresult;
    fitResultsMatrix{i, 2} = struct('coefficients', coeffvalues(fitresult), 'gof', gof);
end
% 使用 cellfun 函数提取系数数据
coefficientsCell = cellfun(@(x) x.coefficients, fitResultsMatrix(:, 2), 'UniformOutput', false);
% 将系数数据转换成矩阵
coefficientsMatrix = cell2mat(coefficientsCell);

yita_ji = coefficientsMatrix(:,1);
D_ji = coefficientsMatrix(:,2);


save('yita_ji_400_R.mat', 'yita_ji');
save('D_ji_400_R.mat', 'D_ji');








