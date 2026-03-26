clc; clear; close all;


vMat = [-5.3 5];
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


% 指定文件夹的编号范围
folder_numbers = 2:2:200;
num_files = 50; % 需要读取的文件数


% 遍历每个文件夹
for folder_num = folder_numbers
    folder_name = fullfile(pwd, num2str(folder_num)); % 构造文件夹路径
    
    if ~isfolder(folder_name)
        fprintf('文件夹 %s 不存在，跳过。\n', folder_name);
        continue;
    end
    
    % 预加载第一个文件以确定数据大小
    first_file = fullfile(folder_name, '1.mat');
    if ~isfile(first_file)
        fprintf('文件 %s 不存在，跳过。\n', first_file);
        continue;
    end
    
    first_data = load(first_file);
    field_name = fieldnames(first_data); % 获取变量名
    data_sample = first_data.(field_name{1}); % 获取变量数据
    [data_rows, data_cols] = size(data_sample); % 获取数据尺寸

    % 预分配三维矩阵
    data_matrix = zeros(data_rows, data_cols, num_files);

    % 依次读取文件并存入三维矩阵
    for i = 1:num_files
        filename = fullfile(folder_name, sprintf('%d.mat', i)); % 生成完整文件路径
        
        if isfile(filename)
            temp_data = load(filename);
            data_matrix(:,:,i) = temp_data.(field_name{1}); % 存入三维矩阵
        else
            fprintf('文件 %s 不存在，跳过。\n', filename);
        end
    end

    % 计算均值
    mean_faiz_temp = mean(data_matrix, 3);

    % 计算 vz
    vz = (mean_faiz_temp * 0.84) / (4 * 1.6 * pi * 0.01);

    % 限制数值范围
%     vz(vz < -7) = -7;
%     vz(vz > 7) = 7;

    % 显示图像
    figure('Visible', 'off'); % 不显示窗口，加快处理速度
    imagesc(vz); 
    colormap(myColormap); 
    colorbar; 
    clim([-5 5]); % 设置颜色范围

    % 归一化到 0-1 之间
    I = mat2gray(vz, vMat); 
    I_rgb = ind2rgb(uint8(I * 255), myColormap);

    % 保存 PNG 图片
    output_filename = fullfile(folder_name, sprintf('%d.png', folder_num));
    imwrite(I_rgb, output_filename);
    
    fprintf('文件夹 %s 处理完成，图片已保存。\n', folder_name);
end

fprintf('所有文件夹处理完成。\n');





