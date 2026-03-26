% 辅助函数：旋转表面到指定方向（从z轴到dir）
function [x_rot, y_rot, z_rot] = rotate_to_direction(x, y, z, dir)
    % 初始方向：z轴 [0 0 1]
    init_dir = [0 0 1];
    
    % 计算旋转轴和角度
    if all(dir == init_dir)
        x_rot = x;
        y_rot = y;
        z_rot = z;
        return;
    end
    axis = cross(init_dir, dir);
    axis = axis / norm(axis);
    angle = acos(dot(init_dir, dir));
    
    % 旋转矩阵
    c = cos(angle);
    s = sin(angle);
    t = 1 - c;
    ux = axis(1); uy = axis(2); uz = axis(3);
    R = [t*ux^2 + c,    t*ux*uy - uz*s, t*ux*uz + uy*s;
         t*uy*ux + uz*s, t*uy^2 + c,    t*uy*uz - ux*s;
         t*uz*ux - uy*s, t*uz*uy + ux*s, t*uz^2 + c];
    
    % 应用旋转到每个点
    [m, n] = size(x);
    x_rot = zeros(m, n);
    y_rot = zeros(m, n);
    z_rot = zeros(m, n);
    for i = 1:m
        for j = 1:n
            pt = [x(i,j); y(i,j); z(i,j)];
            pt_rot = R * pt;
            x_rot(i,j) = pt_rot(1);
            y_rot(i,j) = pt_rot(2);
            z_rot(i,j) = pt_rot(3);
        end
    end
end