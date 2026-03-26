# Complete-Project-for-3D-Flow-Field-Reconstruction-Using-Doppler-DLS-OCT

# Doppler + DLS OCT 流场三维重建完整项目

**项目作者：** YUN TANG（唯一完成人）  
**完成时间：** 2025年  
**语言：** MATLAB  
**核心技术：** 多普勒光学相干层析成像（Doppler OCT） + 动态光散射（DLS） + 3D矢量场可视化  

本项目由我独立完成，实现了**完整的多普勒OCT相位差速度测量 + DLS自相关扩散系数提取 + 流场三维矢量重建**的全流程方案。成功处理了5000 A-line × 200 B-scan × 50+重复帧的超大数据量(≈100G)，提取了三维流速场（v_f）、流动方向角（θ、γ），并生成高精度3D箭头可视化结果。

---

## 项目亮点

- **双模态融合**：Doppler OCT提供轴向速度v_z，DLS提供横向流动信息，通过公式解耦得到完整三维流速矢量。
- **批处理能力**：支持1~50文件夹批量处理，支持奇/偶帧分离、单帧重复采集数据整理。
- **高性能计算**：GPU加速相位差计算 + 向量化自相关 + 非线性拟合。
- **3D可视化**：真实物理坐标系下的3D箭头流场（使用自定义圆柱+圆锥箭头 + 旋转矩阵），支持暗背景、jet速度着色、透明OCT体积渲染。
- **鲁棒后处理**：异常值剔除、样条插值、移动平均平滑，保证流场数据平滑可信。

---

## 文件结构与功能说明

| 文件名 | 功能说明 |
|--------|----------|
| **`ODT_DLSOCT.m`** | **核心主处理脚本**。读取`.raw`原始光谱数据 → 插值+色散补偿+FFT → 生成`volume_complex`（复信号）和`volume`（强度图像）。对偶数帧进行fliplr翻转；计算窗口相位差`fai_z`并转为v_z；生成`faiz`和`vz`文件夹。 |
| **`single_frame_repetition_complex.m`** | 批量复制复信号数据（faiz1_xxx.mat）到`doppler_OCT`目标文件夹（2:2:200），用于后续Doppler平均处理。 |
| **`single_frame_repetition_intensity.m`** | 批量复制强度图像（volume_data_0xxx.mat）到`ROI_DLS_OCT`目标文件夹（189:1:190），用于DLS自相关计算。 |
| **`mean_faiz_all.m`** | 遍历所有Doppler文件夹，计算50帧平均相位差 → v_z彩图，并保存PNG结果（自定义蓝-青-黑-橙-红colormap）。 |
| **`mean_intensity_single.m`** | DLS核心脚本。从ROI强度图像提取奇数帧，计算Pearson自相关系数 → 非线性指数拟合 → 输出黏度`yita_ji`/`yita_ou`、扩散系数`D`。包含图像旋转、截取、去噪等预处理。 |
| **`flow189_190_L.m`**（示例） | 流场解耦计算脚本。融合yita（奇/偶帧）、v_z_mean，解算横向流速`v_f`、倾角`θ`、方位角`γ`。包含异常值剔除、平滑、取样（每9~11点平均一次）。同系列脚本可扩展到其他ROI。 |
| **`demo_volme.m`** | 将二维切片序列（.tif）堆叠为3D体积`volData_segmentation.mat`，供后续可视化使用。 |
| **`demo_quiver.m`** | **3D流场可视化主脚本**。加载所有ROI的平均流速/角度数据 + OCT体积 → 降采样 + 自定义箭头（圆柱体+圆锥头） + 旋转到真实方向 → 生成暗背景3D矢量图（jet速度着色）。支持多流道中心点位置自定义。 |
| **`rotate_to_direction.m`** | 辅助函数。将箭头（圆柱+圆锥）从z轴旋转到任意3D方向向量。 |

---

## 完整处理流程（推荐运行顺序）

1. **原始数据预处理**  
   运行 `ODT_DLSOCT.m`（循环1:50.raw文件）→ 生成`volume_complex/faiz`和`volume`文件夹。

2. **Doppler数据整理**  
   运行 `single_frame_repetition_complex.m` → 将faiz数据复制到`doppler_OCT/2,4,...,200`。

3. **DLS数据整理**  
   运行 `single_frame_repetition_intensity.m` → 将强度图像复制到`ROI_DLS_OCT/189,190`。

4. **Doppler平均与成图**  
   运行 `mean_faiz_all.m` → 得到所有文件夹的平均v_z彩图。

5. **DLS自相关与拟合**  
   进入对应ROI文件夹，运行 `mean_intensity_single.m` → 输出`yita_ji_400_*.mat`、`D_ji_400_*.mat`。

6. **流场解耦计算**  
   运行 `flow189_190_L.m`（或其他ROI脚本）→ 输出`vf_mean_xxx.mat`、`theta_mean_xxx.mat`、`gama_mean_xxx.mat`。

7. **3D可视化**  
   运行 `demo_quiver.m` → 生成最终3D流场图（可切换视角：俯视、侧视）。

---

## 依赖环境

- MATLAB R2020b 或更高版本（推荐R2022b+）
- Image Processing Toolbox
- Parallel Computing Toolbox（GPU加速，可选）
- 数据文件：`.raw`原始光谱 + `k.mat`、`kEven.mat`、`dispComp.mat`（系统校准文件）

---

## 结果示例

- 每2帧Doppler平均v_z彩图（PNG）
- 3D体积渲染 + 彩色箭头流场（暗背景，速度jet着色）
- 矢量流速、流向角统计图
- 自动保存的`.mat`中间结果，便于二次分析

---

## 如何使用

1. 将本仓库克隆到本地。
2. 把原始`.raw`文件和校准文件（k.mat等）放入工作目录。
3. 按上述**完整处理流程**依次运行脚本。
4. 修改`demo_quiver.m`中的流道中心点坐标（X_orig、Y_orig、Z_orig）即可适配不同实验几何。

---

## 特别说明/感谢

本项目由我（YUN TANG）独立设计、编码、调试与验证，所有代码均为原创。欢迎同行交流、引用或二次开发！
感谢导师Zhihua Ding对本研究的理论指导，感谢女友JiaNing Shen的支持与陪伴！


