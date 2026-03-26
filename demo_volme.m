clear;

imgDir = fullfile(pwd, 'image_2');
numImgs = 481;   % 文件数量从 se0000.tif 到 se0480.tif，总共 481 张

% ---------- 读第一帧 ----------
fname = sprintf('Final_13_se20_ou%04d.tif', 1);   % 第一帧是 se0000.tif
img = imread(fullfile(imgDir, fname));

% 转灰度
if ndims(img) == 3
    img = rgb2gray(img);
end
img = im2double(img);

[H, W] = size(img);

% 预分配三维矩阵
volData = zeros(H, W, numImgs);

volData(:,:,1) = img;

% ---------- 剩余帧 ----------
for k = 2:numImgs
    fname = sprintf('Final_13_se20_ou%04d.tif', k);   % se0001.tif, se0002.tif ...
    img = imread(fullfile(imgDir, fname));

    if ndims(img) == 3
        img = rgb2gray(img);
    end
    img = im2double(img);

    volData(:,:,k+1) = img;
end

save('volData_segmentation.mat','volData','-v7.3');

% 自定义透明度函数
% x = linspace(0,1,256);
% alphaMap = single(min(max((x-0.2)/0.4,0),1));
% 
% viewer = volshow(volData, ...
%     'Colormap', gray(256), ...
%     'Alphamap', alphaMap);