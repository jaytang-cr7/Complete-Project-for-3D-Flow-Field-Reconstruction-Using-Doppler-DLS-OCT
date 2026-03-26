clear;
%% flow 计算

load('yita_ou_400_L.mat');
load('yita_ji_400_L.mat');
load('vz_mean_400_L.mat');
% load('w0_200_roi左（中）.mat');
x = (1:1:121)';
plot(x,yita_ji,'r',x,yita_ou,'g');

w0 = 12;  %%%校正参数
wz = 6.2;

vs = 4/(5000*0.00001);
b = -2/(w0^2);
c = -1/(wz^2);

yita_sum = yita_ou + yita_ji(1:121,:);
yita_diff = yita_ou - yita_ji(1:121,:);
vz_mean_demo = vz_mean(1:121,:);

vf_cos_theta_2 =  abs((yita_sum - 2*b*vs*vs - 2*c*(vz_mean_demo.*vz_mean_demo))/(2*b));
vf_cos_theta = sqrt(vf_cos_theta_2);
tan_theta = vz_mean_demo./vf_cos_theta;

% 1. 识别异常值 (基于四分位数 IQR 方法)
Q1 = quantile(tan_theta, 0.25); % 计算 25% 分位数
Q3 = quantile(tan_theta, 0.75); % 计算 75% 分位数
IQR = Q3 - Q1; % 计算四分位距
lower_bound = Q1 - 0.9 * IQR; % 下界
upper_bound = Q3 + 0.9 * IQR; % 上界
outliers = (tan_theta < lower_bound) | (tan_theta > upper_bound); % 找到异常值

% 2. 替换异常值（使用最近邻插值填充 NaN）
tan_theta_cleaned = tan_theta;
tan_theta_cleaned(outliers) = NaN; % 标记异常值
tan_theta_cleaned = fillmissing(tan_theta_cleaned, 'spline'); % 采用三次样条插值
% 3. 平滑数据（使用移动平均）
smoothed_tan_theta = movmean(tan_theta_cleaned, 5); % 5 为窗口大小，可调整smooth(data, 0.1, 'loess');
% 4. 画图对比
figure;
subplot(3,1,1);
plot(tan_theta, 'r'); title('原始数据（含异常值）'); grid on;

subplot(3,1,2);
plot(tan_theta_cleaned, 'b'); title('去除异常值后'); grid on;

subplot(3,1,3);
plot(smoothed_tan_theta, 'g'); title('去除异常值并平滑后'); grid on;

cos_theta = 1 ./ sqrt(1 + tan_theta.^2);
sin_theta = tan_theta ./ sqrt(1 + tan_theta.^2);
vf = abs(vz_mean_demo./sin_theta);

% 对原数据 vf 做 11 点平滑。每隔 9 个点采一次样（绘制箭头）
demo_vf = movmean(vf, 11);
idx = 9:9:length(demo_vf);   % 生成取样的索引：10, 20, 30, ...
vf_mean_189_190_L = demo_vf(idx);        % 提取对应数据
vf_mean_189_190_L = vf_mean_189_190_L(2:12);
save('vf_mean_189_190_L.mat', 'vf_mean_189_190_L');

theta = atand(tan_theta_cleaned);
demo_theta = movmean(theta, 11);
idx = 9:9:length(demo_theta);   % 生成取样的索引：10, 20, 30, ...
theta_mean_189_190_L = demo_theta(idx);        % 提取对应数据
theta_mean_189_190_L = theta_mean_189_190_L(2:12);
save('theta_mean_189_190_L.mat', 'theta_mean_189_190_L');


cos_gama = abs(yita_diff./(4*b*vs*vf_cos_theta));
cos_gama = fillmissing(cos_gama, 'spline');
% 1. 识别异常值 (基于四分位数 IQR 方法)
Q1 = quantile(cos_gama, 0.25); % 计算 25% 分位数
Q3 = quantile(cos_gama, 0.75); % 计算 75% 分位数
IQR = Q3 - Q1; % 计算四分位距
lower_bound = Q1 - 0.9 * IQR; % 下界
upper_bound = Q3 + 0.9 * IQR; % 上界
outliers = (cos_gama < lower_bound) | (cos_gama > upper_bound); % 找到异常值
% 2. 替换异常值（使用最近邻插值填充 NaN）
cos_gama_cleaned = cos_gama;
cos_gama_cleaned(outliers) = NaN; % 标记异常值
cos_gama_cleaned = fillmissing(cos_gama_cleaned, 'spline'); % 采用最近邻值填充
% 3. 平滑数据（使用移动平均）
smoothed_cos_gama = movmean(cos_gama_cleaned, 5); % 5 为窗口大小，可调整smooth(data, 0.1, 'loess');
% 4. 画图对比
figure;
subplot(3,1,1);
plot(cos_gama, 'r'); title('原始数据（含异常值）'); grid on;
subplot(3,1,2);
plot(cos_gama_cleaned, 'b'); title('去除异常值后'); grid on;
subplot(3,1,3);
plot(smoothed_cos_gama, 'g'); title('去除异常值并平滑后'); grid on;

% 复制原始数据用于修改
gama_mean_cleaned_processed = cos_gama_cleaned;
% 处理 <0 的数据，映射到 [0, 0.1]
mask_neg = cos_gama_cleaned < 0;
if any(mask_neg)  % 确保存在小于0的数据
    min_val_neg = min(cos_gama_cleaned(mask_neg));  % 负数中的最小值
    max_val_neg = max(cos_gama_cleaned(mask_neg));  % 负数中的最大值（最接近0）

    % 线性缩放到 [0, 0.1]
    gama_mean_cleaned_processed(mask_neg) = 0 + (cos_gama_cleaned(mask_neg) - min_val_neg) / (max_val_neg - min_val_neg) * (0.1 - 0);
end

% 处理 >1 的数据，映射到 [0.9, 1]
mask_pos = cos_gama_cleaned > 1;
if any(mask_pos)  % 确保存在大于1的数据
    min_val_pos = min(cos_gama_cleaned(mask_pos));  % 超过1的最小值
    max_val_pos = max(cos_gama_cleaned(mask_pos));  % 超过1的最大值

    % 线性缩放到 [0.9, 1]
    gama_mean_cleaned_processed(mask_pos) = 0.9 + (cos_gama_cleaned(mask_pos) - min_val_pos) / (max_val_pos - min_val_pos) * (1 - 0.9);
end

% 绘图对比
figure; hold on;
plot(1:length(cos_gama_cleaned), cos_gama_cleaned, 'ro-', 'LineWidth', 2, 'MarkerSize', 8); % 原始数据（红色）
plot(1:length(gama_mean_cleaned_processed), gama_mean_cleaned_processed, 'bo-', 'LineWidth', 2, 'MarkerSize', 8); % 处理后数据（蓝色）

% gama mean(锐角)
gama = acosd(gama_mean_cleaned_processed);
demo_gama = movmean(gama, 11);
idx = 9:9:length(demo_gama);   % 生成取样的索引：10, 20, 30, ...
gama_mean_189_190_L = demo_gama(idx);        % 提取对应数据
gama_mean_189_190_L = gama_mean_189_190_L(2:12);
save('gama_mean_189_190_L.mat', 'gama_mean_189_190_L');
