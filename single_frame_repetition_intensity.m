clear;
% 定义源文件夹的编号
folders = 1:1:50;

% 定义目标文件夹的编号范围
target_folders = 189:1:190;  % ROI帧数

% 遍历所有目标文件夹编号
for t = 1:length(target_folders)
    % 目标文件夹路径
    target_folder = fullfile(pwd, 'ROI_DLS_OCT', num2str(target_folders(t)));

    % 如果目标文件夹不存在，则创建
    if ~exist(target_folder, 'dir')
        mkdir(target_folder);
    end

    % 遍历所有源文件夹
    for i = 1:length(folders)
        % 构造源文件路径
        source_file = fullfile(pwd, num2str(folders(i)), 'volume', sprintf('volume_data_0%d.mat', target_folders(t)));   %%每一个文件夹的19,20提取出来

        % 构造目标文件路径
        destination_file = fullfile(target_folder, sprintf('%d.mat', i));

        % 复制文件并重命名
        if exist(source_file, 'file')
            copyfile(source_file, destination_file);
            fprintf('已复制 %s 到 %s\n', source_file, destination_file);
        else
            fprintf('警告：文件 %s 不存在，跳过。\n', source_file);
        end
    end

    fprintf('目标文件夹 %s 处理完成。\n', target_folder);
end

disp('所有文件复制完成！');


