clear;
% 加载volData.mat中的三维矩阵
load('volData_segmentation.mat'); % 假设矩阵变量名为volData，如果不同请调整

clearvars -except volData

load('vf_mean_9_10.mat');
load('theta_mean_9_10.mat');
load('gama_mean_9_10.mat');

load('vf_mean_19_20.mat');
load('theta_mean_19_20.mat');
load('gama_mean_19_20.mat');
% 
load('vf_mean_29_30.mat');
load('theta_mean_29_30.mat');
load('gama_mean_29_30.mat');
% 
load('vf_mean_39_40.mat');
load('theta_mean_39_40.mat');
load('gama_mean_39_40.mat');
% 
load('vf_mean_49_50.mat');
load('theta_mean_49_50.mat');
load('gama_mean_49_50.mat');
% 
load('vf_mean_59_60.mat');
load('theta_mean_59_60.mat');
load('gama_mean_59_60.mat');
% 
load('vf_mean_69_70.mat');
load('theta_mean_69_70.mat');
load('gama_mean_69_70.mat');
% 
load('vf_mean_79_80.mat');
load('theta_mean_79_80.mat');
load('gama_mean_79_80.mat');
% 
load('vf_mean_89_90.mat');
load('theta_mean_89_90.mat');
load('gama_mean_89_90.mat');
% 
load('vf_mean_99_100.mat');
load('theta_mean_99_100.mat');
load('gama_mean_99_100.mat');
% 
load('vf_mean_109_110_L.mat');
load('theta_mean_109_110_L.mat');
load('gama_mean_109_110_L.mat');
% 
load('vf_mean_109_110_R.mat');
load('theta_mean_109_110_R.mat');
load('gama_mean_109_110_R.mat');
% 
load('vf_mean_119_120_L.mat');
load('theta_mean_119_120_L.mat');
load('gama_mean_119_120_L.mat');
% 
load('vf_mean_119_120_R.mat');
load('theta_mean_119_120_R.mat');
load('gama_mean_119_120_R.mat');
% 
load('vf_mean_129_130_L.mat');
load('theta_mean_129_130_L.mat');
load('gama_mean_129_130_L.mat');
% 
load('vf_mean_129_130_R.mat');
load('theta_mean_129_130_R.mat');
load('gama_mean_129_130_R.mat');
% 
load('vf_mean_139_140_L.mat');
load('theta_mean_139_140_L.mat');
load('gama_mean_139_140_L.mat');
% 
load('vf_mean_139_140_R.mat');
load('theta_mean_139_140_R.mat');
load('gama_mean_139_140_R.mat');
% 
load('vf_mean_149_150_L.mat');
load('theta_mean_149_150_L.mat');
load('gama_mean_149_150_L.mat');
% 
load('vf_mean_149_150_R.mat');
load('theta_mean_149_150_R.mat');
load('gama_mean_149_150_R.mat');
% 
load('vf_mean_159_160_L.mat');
load('theta_mean_159_160_L.mat');
load('gama_mean_159_160_L.mat');
% 
load('vf_mean_159_160_R.mat');
load('theta_mean_159_160_R.mat');
load('gama_mean_159_160_R.mat');
% 
load('vf_mean_169_170_L.mat');
load('theta_mean_169_170_L.mat');
load('gama_mean_169_170_L.mat');
% 
load('vf_mean_169_170_R.mat');
load('theta_mean_169_170_R.mat');
load('gama_mean_169_170_R.mat');
% 
load('vf_mean_179_180_L.mat');
load('theta_mean_179_180_L.mat');
load('gama_mean_179_180_L.mat');
% 
load('vf_mean_179_180_R.mat');
load('theta_mean_179_180_R.mat');
load('gama_mean_179_180_R.mat');
% 
load('vf_mean_189_190_L.mat');
load('theta_mean_189_190_L.mat');
load('gama_mean_189_190_L.mat');
% 
load('vf_mean_189_190_R.mat');
load('theta_mean_189_190_R.mat');
load('gama_mean_189_190_R.mat');




A = volData; % 如果load直接赋值A，则此行可省略；确保A是481x493x481 double
% 定义降采样因子（用户可调整；越大，降采样越强，可视化越快）
downsample_factor = 5; % 例如2表示每2个点取1个，尺寸减半

% % 降采样矩阵A（子采样，不改变结构，仅减少分辨率）
% A_down = A(1:downsample_factor:end, 1:downsample_factor:end, 1:downsample_factor:end);
% A_down = permute(A_down, [3 2 1]);
% A_down = flip(A_down, 3);

% 使用imresize3进行平滑降采样（需要Image Processing Toolbox）
% 'linear'或'cubic'方法可使降采样更平滑（'cubic'更平滑但更慢）
scale = 1 / downsample_factor;
A_down = imresize3(A, scale, 'Method', 'cubic'); % 可换成 'cubic' 以获得更平滑效果
A_down = permute(A_down, [3 2 1]);
A_down = flip(A_down, 3);
A_down(A_down == 0) = NaN;

% 获取降采样后尺寸
[ny, nx, nz] = size(A_down); % ny≈481/down, nx≈493/down, nz≈481/down

% 定义点的位置：原位置需缩放以匹配新坐标系（假设原坐标1:481,1:493,1:481）
% 缩放位置：新位置 = 原位置 / downsample_factor（取整或插值，这里用ceil向上取整）
X_orig1 = repmat(598, 1, 11);   %(对应每一页流道中心点位置)
Y_orig1 = repmat(25, 1, 11);   %（对应y在第几页）
Z_orig1 = 737:-9:(737 - 9*(11-1));  %（对应z的坐标，每10个箭头算一个平均）,顶部减5，反向1024-

X_orig2 = repmat(602, 1, 11);   %(对应每一页流道中心点位置)
Y_orig2 = repmat(50, 1, 11);   %（对应y在第几页）
Z_orig2 = 736:-9:(736 - 9*(11-1));  %（对应z的坐标，每10个箭头算一个平均）,顶部减5，反向1024-

X_orig3 = repmat(601, 1, 11);   %(对应每一页流道中心点位置)
Y_orig3 = repmat(75, 1, 11);   %（对应y在第几页）
Z_orig3 = 736:-9:(736 - 9*(11-1));  %（对应z的坐标，每10个箭头算一个平均）,顶部减5，反向1024-

X_orig4 = repmat(590, 1, 11);   %(对应每一页流道中心点位置)
Y_orig4 = repmat(100, 1, 11);   %（对应y在第几页）
Z_orig4 = 735:-9:(735 - 9*(11-1));  %（对应z的坐标，每10个箭头算一个平均）,顶部减5，反向1024-

X_orig5 = repmat(585, 1, 11);   
Y_orig5 = repmat(125, 1, 11);   
Z_orig5 = 737:-9:(737 - 9*(11-1));  

X_orig6 = repmat(571, 1, 11);   
Y_orig6 = repmat(150, 1, 11);   
Z_orig6 = 736:-9:(736 - 9*(11-1));  

X_orig7 = repmat(559, 1, 11);   
Y_orig7 = repmat(175, 1, 11);   
Z_orig7 = 737:-9:(737 - 9*(11-1)); 

X_orig8 = repmat(540, 1, 11);   
Y_orig8 = repmat(200, 1, 11);   
Z_orig8 = 736:-9:(736 - 9*(11-1)); 

X_orig9 = repmat(520, 1, 11);   
Y_orig9 = repmat(225, 1, 11);   
Z_orig9 = 738:-9:(738 - 9*(11-1)); 

X_orig10 = repmat(496, 1, 11);   
Y_orig10 = repmat(250, 1, 11);   
Z_orig10 = 738:-9:(738 - 9*(11-1)); 

X_orig11_L = repmat(469, 1, 11);   
Y_orig11_L = repmat(275, 1, 11);   
Z_orig11_L = 740:-9:(740 - 9*(11-1)); 

X_orig11_R = repmat(980, 1, 11);   
Y_orig11_R = repmat(275, 1, 11);   
Z_orig11_R = 751:-9:(751 - 9*(11-1)); 

X_orig12_L = repmat(447, 1, 11);   
Y_orig12_L = repmat(300, 1, 11);   
Z_orig12_L = 741:-9:(741 - 9*(11-1));

X_orig12_R = repmat(937, 1, 11);   
Y_orig12_R = repmat(300, 1, 11);   
Z_orig12_R = 750:-9:(750 - 9*(11-1));

X_orig13_L = repmat(413, 1, 11);   
Y_orig13_L = repmat(325, 1, 11);   
Z_orig13_L = 742:-9:(742 - 9*(11-1));

X_orig13_R = repmat(901, 1, 11);   
Y_orig13_R = repmat(325, 1, 11);   
Z_orig13_R = 750:-9:(750 - 9*(11-1));

X_orig14_L = repmat(380, 1, 11);   
Y_orig14_L = repmat(350, 1, 11);   
Z_orig14_L = 743:-9:(743 - 9*(11-1));

X_orig14_R = repmat(864, 1, 11);   
Y_orig14_R = repmat(350, 1, 11);   
Z_orig14_R = 751:-9:(751 - 9*(11-1));

X_orig15_L = repmat(340, 1, 11);   
Y_orig15_L = repmat(375, 1, 11);   
Z_orig15_L = 744:-9:(744 - 9*(11-1));

X_orig15_R = repmat(830, 1, 11);   
Y_orig15_R = repmat(375, 1, 11);   
Z_orig15_R = 750:-9:(750 - 9*(11-1));

X_orig16_L = repmat(300, 1, 11);   
Y_orig16_L = repmat(400, 1, 11);   
Z_orig16_L = 745:-9:(745 - 9*(11-1));

X_orig16_R = repmat(799, 1, 11);   
Y_orig16_R = repmat(400, 1, 11);   
Z_orig16_R = 750:-9:(750 - 9*(11-1));

X_orig17_L = repmat(261, 1, 11);   
Y_orig17_L = repmat(425, 1, 11);   
Z_orig17_L = 747:-9:(747 - 9*(11-1));

X_orig17_R = repmat(770, 1, 11);   
Y_orig17_R = repmat(425, 1, 11);   
Z_orig17_R = 751:-9:(751 - 9*(11-1));

X_orig18_L = repmat(215, 1, 11);   
Y_orig18_L = repmat(450, 1, 11);   
Z_orig18_L = 747:-9:(747 - 9*(11-1));

X_orig18_R = repmat(745, 1, 11);   
Y_orig18_R = repmat(450, 1, 11);   
Z_orig18_R = 750:-9:(750 - 9*(11-1));

X_orig19_L = repmat(173, 1, 11);   
Y_orig19_L = repmat(475, 1, 11);   
Z_orig19_L = 747:-9:(747 - 9*(11-1));

X_orig19_R = repmat(722, 1, 11);   
Y_orig19_R = repmat(475, 1, 11);   
Z_orig19_R = 750:-9:(750 - 9*(11-1));



X_orig = [X_orig1, X_orig2, X_orig3, X_orig4, X_orig5, X_orig6, X_orig7, X_orig8, X_orig9, X_orig10, X_orig11_L, X_orig11_R, X_orig12_L, X_orig12_R, X_orig13_L, X_orig13_R, X_orig14_L, X_orig14_R, X_orig15_L, X_orig15_R, X_orig16_L, X_orig16_R, X_orig17_L, X_orig17_R, X_orig18_L, X_orig18_R, X_orig19_L, X_orig19_R];
Y_orig = [Y_orig1, Y_orig2, Y_orig3, Y_orig4, Y_orig5, Y_orig6, Y_orig7, Y_orig8, Y_orig9, Y_orig10, Y_orig11_L, Y_orig11_R, Y_orig12_L, Y_orig12_R, Y_orig13_L, Y_orig13_R, Y_orig14_L, Y_orig14_R, Y_orig15_L, Y_orig15_R, Y_orig16_L, Y_orig16_R, Y_orig17_L, Y_orig17_R, Y_orig18_L, Y_orig18_R, Y_orig19_L, Y_orig19_R];
Z_orig = [Z_orig1, Z_orig2, Z_orig3, Z_orig4, Z_orig5, Z_orig6, Z_orig7, Z_orig8, Z_orig9, Z_orig10, Z_orig11_L, Z_orig11_R, Z_orig12_L, Z_orig12_R, Z_orig13_L, Z_orig13_R, Z_orig14_L, Z_orig14_R, Z_orig15_L, Z_orig15_R, Z_orig16_L, Z_orig16_R, Z_orig17_L, Z_orig17_R, Z_orig18_L, Z_orig18_R, Z_orig19_L, Z_orig19_R];


X = ceil(X_orig / downsample_factor);
Y = ceil(Y_orig / downsample_factor);
Z = ceil(Z_orig / downsample_factor);

% 箭头数据：速度 r，经度角 phi (度)，纬度角 theta (度)     (根据流向判定：左负右正)
r1 = vf_mean_9_10';
phi_deg1 = -gama_mean_9_10';
theta_deg1 = -theta_mean_9_10';

r2 = vf_mean_19_20';
phi_deg2 = -gama_mean_19_20';
theta_deg2 = -theta_mean_19_20';

r3 = vf_mean_29_30';
phi_deg3 = -gama_mean_29_30';
theta_deg3 = -theta_mean_29_30';

r4 = vf_mean_39_40';
phi_deg4 = -gama_mean_39_40';
theta_deg4 = -theta_mean_39_40';

r5 = vf_mean_49_50';
phi_deg5 = -gama_mean_49_50';
theta_deg5 = -theta_mean_49_50';

r6 = vf_mean_59_60';
phi_deg6 = -gama_mean_59_60';
theta_deg6 = -theta_mean_59_60';

r7 = vf_mean_69_70';
phi_deg7 = -gama_mean_69_70';
theta_deg7 = -theta_mean_69_70';

r8 = vf_mean_79_80';
phi_deg8 = -gama_mean_79_80';
theta_deg8 = -theta_mean_79_80';

r9 = vf_mean_89_90';
phi_deg9 = -gama_mean_89_90';
theta_deg9 = -theta_mean_89_90';

r10 = vf_mean_99_100';
phi_deg10 = -gama_mean_99_100';
theta_deg10 = -theta_mean_99_100';

r11_L = vf_mean_109_110_L';
phi_deg11_L = -gama_mean_109_110_L';
theta_deg11_L = -theta_mean_109_110_L';

r11_R = vf_mean_109_110_R';
phi_deg11_R = gama_mean_109_110_R';
theta_deg11_R = theta_mean_109_110_R';

r12_L = vf_mean_119_120_L';
phi_deg12_L = -gama_mean_119_120_L';
theta_deg12_L = -theta_mean_119_120_L';

r12_R = vf_mean_119_120_R';
phi_deg12_R = gama_mean_119_120_R';
theta_deg12_R = theta_mean_119_120_R';

r13_L = vf_mean_129_130_L';
phi_deg13_L = -gama_mean_129_130_L';
theta_deg13_L = -theta_mean_129_130_L';

r13_R = vf_mean_129_130_R';
phi_deg13_R = gama_mean_129_130_R';
theta_deg13_R = theta_mean_129_130_R';

r14_L = vf_mean_139_140_L';
phi_deg14_L = -gama_mean_139_140_L';
theta_deg14_L = -theta_mean_139_140_L';

r14_R = vf_mean_139_140_R';
phi_deg14_R = gama_mean_139_140_R';
theta_deg14_R = theta_mean_139_140_R';

r15_L = vf_mean_149_150_L';
phi_deg15_L = -gama_mean_149_150_L';
theta_deg15_L = -theta_mean_149_150_L';

r15_R = vf_mean_149_150_R';
phi_deg15_R = gama_mean_149_150_R';
theta_deg15_R = theta_mean_149_150_R';

r16_L = vf_mean_159_160_L';
phi_deg16_L = -gama_mean_159_160_L';
theta_deg16_L = -theta_mean_159_160_L';

r16_R = vf_mean_159_160_R';
phi_deg16_R = gama_mean_159_160_R';
theta_deg16_R = theta_mean_159_160_R';

r17_L = vf_mean_169_170_L';
phi_deg17_L = -gama_mean_169_170_L';
theta_deg17_L = -theta_mean_169_170_L';

r17_R = vf_mean_169_170_R';
phi_deg17_R = gama_mean_169_170_R';
theta_deg17_R = theta_mean_169_170_R';

r18_L = vf_mean_179_180_L';
phi_deg18_L = -gama_mean_179_180_L';
theta_deg18_L = -theta_mean_179_180_L';

r18_R = vf_mean_179_180_R';
phi_deg18_R = gama_mean_179_180_R';
theta_deg18_R = theta_mean_179_180_R';

r19_L = vf_mean_189_190_L';
phi_deg19_L = -gama_mean_189_190_L';
theta_deg19_L = -theta_mean_189_190_L';

r19_R = vf_mean_189_190_R';
phi_deg19_R = gama_mean_189_190_R';
theta_deg19_R = theta_mean_189_190_R';



r = [r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11_L, r11_R, r12_L, r12_R, r13_L, r13_R, r14_L, r14_R, r15_L, r15_R, r16_L, r16_R, r17_L, r17_R, r18_L, r18_R, r19_L, r19_R];
phi_deg = [phi_deg1, phi_deg2, phi_deg3, phi_deg4, phi_deg5, phi_deg6, phi_deg7, phi_deg8, phi_deg9, phi_deg10, phi_deg11_L, phi_deg11_R, phi_deg12_L, phi_deg12_R, phi_deg13_L, phi_deg13_R, phi_deg14_L, phi_deg14_R, phi_deg15_L, phi_deg15_R, phi_deg16_L, phi_deg16_R, phi_deg17_L, phi_deg17_R, phi_deg18_L, phi_deg18_R, phi_deg19_L, phi_deg19_R];
theta_deg = [theta_deg1, theta_deg2, theta_deg3, theta_deg4, theta_deg5, theta_deg6, theta_deg7, theta_deg8, theta_deg9, theta_deg10, theta_deg11_L, theta_deg11_R, theta_deg12_L, theta_deg12_R, theta_deg13_L, theta_deg13_R, theta_deg14_L, theta_deg14_R, theta_deg15_L, theta_deg15_R, theta_deg16_L, theta_deg16_R, theta_deg17_L, theta_deg17_R, theta_deg18_L, theta_deg18_R, theta_deg19_L, theta_deg19_R];

% 转换为弧度
phi = phi_deg * pi / 180;
theta = theta_deg * pi / 180;

% 计算笛卡尔分量 U, V, W（矢量方向和长度）
% 注意：箭头长度可能需缩放以匹配新坐标系（可选，用户可调整）
arrow_scale_adjust = 1 / downsample_factor; % 保持原物理比例
U = arrow_scale_adjust * r .* cos(theta) .* cos(phi);
V = arrow_scale_adjust * r .* cos(theta) .* sin(phi);
W = arrow_scale_adjust * r .* sin(theta);

% 创建figure
figure;
hold on;

% 设置背景为暗淡色系（深灰色）
set(gcf, 'Color', [0.2 0.2 0.2]);
set(gca, 'Color', [0.2 0.2 0.2]);
% 设置网格和轴标签颜色为白色以在暗背景上可见
set(gca, 'GridColor', [1 1 1]);
set(gca, 'XColor', [0 0 0]); %1 1 1
set(gca, 'YColor', [0 0 0]); %1 1 1
set(gca, 'ZColor', [0 0 0]); %1 1 1

% 先计算箭头颜色，使用jet colormap
temp_fig = figure('Visible','off');
colormap('jet');
cmap = colormap;
close(temp_fig);
min_r = 0;
max_r = 90;
r_clamped = r;
r_clamped(r_clamped > max_r) = max_r; % 超过80的设为80
r_clamped(r_clamped < min_r) = min_r; % 如果有负的设为0
norm_r = (r_clamped - min_r) / (max_r - min_r); % 归一化到0-1
color_indices = round(norm_r * (size(cmap,1) - 1)) + 1;
colors = cmap(color_indices, :);

% 设置主图colormap为gray，用于三维灰度图
% 设置主图 colormap 为浅蓝渐变
N = 256;
lightBlue = [0.3 0.6 1];   % 浅蓝色，可根据需要调整
white = [1 1 1];

cmap = [ ...
    linspace(lightBlue(1), white(1), N)', ...
    linspace(lightBlue(2), white(2), N)', ...
    linspace(lightBlue(3), white(3), N)' ...
];

colormap(cmap);
colorbar;


% colormap(gray);
% 自定义矩阵透明度
alpha = 0.02; % 用户可以修改此值来调整随机矩阵的透明度 (0-1)

% 显示降采样三维矩阵作为三维灰度图，使用多个切片表示体积（设置slice_steps=1以模拟完整体积）
[x, y, z] = meshgrid(1:nx, 1:ny, 1:nz);  % 调整meshgrid以匹配A_down尺寸
slice_steps = 1; % 设置为1以显示所有切片，模拟完整体积（可能稍慢，但降采样后可行）
h = slice(x, y, z, A_down, 1:slice_steps:nx, 1:slice_steps:ny, 1:slice_steps:nz);
set(h, 'FaceColor', 'interp', 'EdgeColor', 'none', 'FaceAlpha', alpha);

% 定义箭头参数
arrow_length_scale = 0.8; % 用户可调整箭头整体长度比例
body_radius = 0.5; % 箭体圆柱半径（用户可调整）
head_radius = 1; % 箭头圆锥底半径（用户可调整）
head_length_ratio = 0.2; % 箭头长度占总长度的比例
n_faces = 20; % 面数，用于平滑度

for i = 1:308  %（所有展示箭头的数量）
    % 起点
    start_pos = [X(i), Y(i), Z(i)];
    
    % 矢量（方向和长度）
    vec = arrow_length_scale * [U(i), V(i), W(i)];
    len = norm(vec);
    if len == 0
        continue; % 跳过零矢量
    end
    dir = vec / len; % 单位方向向量
    
    % 计算箭体和箭头长度
    body_len = len * (1 - head_length_ratio);
    head_len = len * head_length_ratio;
    
    % 箭体结束位置（箭头起始位置）
    body_end = start_pos + body_len * dir;
    
    % 绘制箭体：圆柱
    [xc, yc, zc] = cylinder(body_radius * ones(2,1), n_faces);
    zc = zc * body_len; % 沿z缩放为箭体长度（初始沿z轴）
    
    % 旋转圆柱到矢量方向
    [xc_rot, yc_rot, zc_rot] = rotate_to_direction(xc, yc, zc, dir);
    
    % 平移到起点
    xc_rot = xc_rot + start_pos(1);
    yc_rot = yc_rot + start_pos(2);
    zc_rot = zc_rot + start_pos(3);
    
    % 绘制箭体
    surf(xc_rot, yc_rot, zc_rot, 'FaceColor', colors(i,:), 'EdgeColor', 'none');
    
    % 绘制箭头：圆锥
    [xh, yh, zh] = cylinder(linspace(head_radius, 0, 2)', n_faces); % 从底到尖
    zh = zh * head_len; % 沿z缩放为箭头长度
    
    % 旋转圆锥到矢量方向
    [xh_rot, yh_rot, zh_rot] = rotate_to_direction(xh, yh, zh, dir);
    
    % 平移到箭体结束位置
    xh_rot = xh_rot + body_end(1);
    yh_rot = yh_rot + body_end(2);
    zh_rot = zh_rot + body_end(3);
    
    % 绘制箭头
    surf(xh_rot, yh_rot, zh_rot, 'FaceColor', colors(i,:), 'EdgeColor', 'none');
end

% 美化可视化
grid on;  % 关闭网格
set(gca, 'GridLineStyle', '--');  % ← 这里添加，将网格线改为虚线（也可以用 ':' 为点线，或 '-.' 为点划线，根据需要调整）
% 设置自定义刻度位置和标签（显示0-4 for X/Y, 0-5 for Z）
set(gca, 'XTick', linspace(0, nx, 5), 'XTickLabel', {'0', '1', '2', '3', '4'});  % X: 均匀分5点，标签0-4
set(gca, 'YTick', linspace(0, ny, 5), 'YTickLabel', {'0', '1', '2', '3', '4'});  % Y: 均匀分5点，标签0-4
set(gca, 'ZTick', linspace(0, nz, 5), 'ZTickLabel', {'', '3', '2', '1', '0'});  % Z: 均匀分7点（多一个空标签避免挤压），标签0-5
xlabel('X (mm)', 'FontName', 'Arial');  % 改成带(mm)，Arial字体
ylabel('Y (mm)', 'FontName', 'Arial');  % 改成带(mm)，Arial字体
zlabel('Z (mm)', 'FontName', 'Arial');  % 改成带(mm)，Arial字体
% title('3D Vector Velocity Visualization','Color', [0 0 0]);
% view(3); % 3D视角
% view(0, 0);  % XZ 平面视角（从正Y方向看）
view(0, 90);   % XY 平面视角（从正Z方向俯视）
axis([0 nx 0 ny 0 nz]); % 设置轴范围以匹配降采样矩阵尺寸
camlight; lighting gouraud; % 添加光照以提升美观

% 添加colorbar显示速度对应颜色 (使用jet)
% 先隐藏可能的gray colorbar
cb_gray = findobj(gcf, 'Type', 'ColorBar');
if ~isempty(cb_gray)
    set(cb_gray, 'Visible', 'off');
end
% 创建独立axes用于jet colorbar
cbax = axes('Position', [0.92 0.2 0.02 0.6], 'Visible', 'off');
colormap(cbax, 'jet');
caxis(cbax, [min_r max_r]);
cb = colorbar(cbax, 'Position', [0.92 0.2 0.02 0.6]);
% cb.Label.String = 'Vf';
set(cb, 'YAxisLocation', 'right'); % 确保数字在右侧
set(cb, 'Color', [0 0 0]); % 设置刻度线和数字颜色为白色
cb.Label.Color = [0 0 0]; % 设置'速度大小'字体为白色

cb.FontSize = 9;         % colorbar 数字字体大小
cb.Label.FontSize = 15;   % colorbar 标签字体大小
% 只显示 0,30,60,90
set(cb, 'Ticks', [0 30 60 90]);
hold off;

