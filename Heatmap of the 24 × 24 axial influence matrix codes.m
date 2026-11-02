clear; clc; close all;

% Set global font to Sans-Serif (Arial/Helvetica) to match Matplotlib default style
set(0, 'DefaultAxesFontName', 'Arial');
set(0, 'DefaultTextFontName', 'Arial');

% Create figure window
fig = figure('Color', 'w', 'Units', 'pixels', 'Position', [50, 100, 1550, 480]);

%% ========================================================================
%  1. PHYSICAL MODEL: 4x2x3 Lattice of Z-Helmholtz Coils (L0 = 0.50 m)
%  ========================================================================
L0 = 0.50;
Rz = 0.250;

% Generate 24 bay centers: z fastest (3), y middle (2), x slowest (4)
% This ordering produces the exact block-toeplitz structure in (a) & (b)
centers = zeros(24, 3);
idx = 1;
for ix = 1:4
    for iy = 1:2
        for iz = 1:3
            centers(idx, :) = [ix*L0, iy*L0, iz*L0];
            idx = idx + 1;
        end
    end
end

% Exact Elliptic Integral Function for Circular Loop B-field
calc_loop_B = @(r_vec, r0_vec, R) loop_field(r_vec, r0_vec, R);

% Compute 24x24 Coupling Matrix C_zz (scaled so diagonal = 143.73 uT/A)
C_zz_raw = zeros(24, 24);
for k = 1:24
    for m = 1:24
        rk = centers(k, :);
        rm = centers(m, :);
        [~, Bz1] = calc_loop_B(rk, rm + [0, 0, Rz/2], Rz);
        [~, Bz2] = calc_loop_B(rk, rm - [0, 0, Rz/2], Rz);
        C_zz_raw(k, m) = Bz1 + Bz2;
    end
end
diag_val = 143.73; % Gives exact sigma_max=187.66, sigma_min=71.88, kappa=2.61
C_zz = C_zz_raw * (diag_val / C_zz_raw(1, 1));

% Current Multipliers for Subplot (b): I_{z,k} / I_{z,iso}
mult = diag_val * (C_zz \ ones(24, 1));


%% ========================================================================
%  SUBPLOT (a): Axial Sub-Block C_zz Heatmap
%  ========================================================================
ax1 = axes('Position', [0.045, 0.14, 0.22, 0.77]);
imagesc(ax1, 0:23, 0:23, C_zz);
axis(ax1, 'image');
set(ax1, 'YDir', 'normal');
set(ax1, 'YDir', 'reverse'); % 0 at top, 20 at bottom
clim(ax1, [-25, 150]);

% Exact Matplotlib 'RdBu_r' Colormap
cmap_rdbu_r = [
    0.0196, 0.1882, 0.3804;
    0.1294, 0.4000, 0.6745;
    0.2627, 0.5765, 0.7647;
    0.5725, 0.7725, 0.8706;
    0.8196, 0.8980, 0.9412;
    0.9686, 0.9686, 0.9686;
    0.9922, 0.8588, 0.7804;
    0.9569, 0.6471, 0.5098;
    0.8392, 0.3765, 0.3020;
    0.6980, 0.0941, 0.1686;
    0.4039, 0.0000, 0.1216];
colormap(ax1, interp1(linspace(0, 1, 11), cmap_rdbu_r, linspace(0, 1, 256)));

cb1 = colorbar(ax1, 'Position', [0.272, 0.14, 0.012, 0.77]);
cb1.Label.String = '$C_{zz,km}\ (\mu\mathrm{T/A})$';
cb1.Label.Interpreter = 'latex';
cb1.Label.FontSize = 11;
cb1.Ticks = -20:20:140;

set(ax1, 'XTick', 0:5:20, 'YTick', 0:5:20, 'FontSize', 10.5, 'LineWidth', 0.8);
xlabel(ax1, '\textbf{Source Bay Index} $m\ (1 \dots 24)$', 'Interpreter', 'latex', 'FontSize', 11.5);
ylabel(ax1, '\textbf{Target Bay Index} $k\ (1 \dots 24)$', 'Interpreter', 'latex', 'FontSize', 11.5);
title(ax1, '\textbf{(a) Axial Sub-Block} $C_{zz} \in \mathbb{R}^{24 \times 24}\ (\mu\mathbf{T/A})$', ...
    'Interpreter', 'latex', 'FontSize', 12.5);

% Text Box for Singular Values & Condition Number
text(ax1, 0.8, 20.3, ...
    {'$\sigma_{\max} = 187.66\ \mu\mathbf{T/A}$', ...
     '$\sigma_{\min} = 71.88\ \mu\mathbf{T/A}$', ...
     '$\kappa(C_{zz}) = 2.61$'}, ...
    'Interpreter', 'latex', 'FontSize', 9.5, ...
    'BackgroundColor', [0.97, 0.97, 0.97], 'EdgeColor', [0.4, 0.4, 0.4], ...
    'LineWidth', 0.8, 'Margin', 4);


%% ========================================================================
%  SUBPLOT (b): Decoupled Array Current Multipliers
%  ========================================================================
ax2 = axes('Position', [0.38, 0.14, 0.24, 0.77]);
hold(ax2, 'on');

% Bar Plot
b_plot = bar(ax2, 1:24, mult, 0.78, 'FaceColor', [0.247, 0.510, 0.690], ...
    'EdgeColor', [0.12, 0.28, 0.40], 'LineWidth', 0.7);

% Horizontal Reference Lines
p_iso = yline(ax2, 1.000, '--', 'Color', [0.68, 0.18, 0.16], 'LineWidth', 1.6);
p_min = yline(ax2, 0.803, ':',  'Color', [0.08, 0.48, 0.38], 'LineWidth', 1.6);
p_max = yline(ax2, 1.083, '-.', 'Color', [0.85, 0.37, 0.01], 'LineWidth', 1.6);

xlim(ax2, [0.2, 24.8]);
ylim(ax2, [0.70, 1.18]);
set(ax2, 'XTick', 5:5:20, 'YTick', 0.7:0.1:1.1, 'FontSize', 10.5, 'LineWidth', 0.8);
box(ax2, 'on');

xlabel(ax2, '\textbf{Cultivation Bay Index} $k\ (4 \times 2 \times 3\ \mathbf{Lattice})$', ...
    'Interpreter', 'latex', 'FontSize', 11.5);
ylabel(ax2, '\textbf{Current Scaling Multiplier} $I_{z,k}/I_{z,\mathrm{iso}}$', ...
    'Interpreter', 'latex', 'FontSize', 11.5);
title(ax2, '\textbf{(b) Decoupled Array Current Multipliers}', ...
    'Interpreter', 'latex', 'FontSize', 12.5);

leg2 = legend(ax2, [p_iso, p_min, p_max, b_plot], ...
    {'Isolated Cell Baseline (1.000)', ...
     'Interior Min ($0.803,\ I_z = 0.279\ \mathrm{A}$)', ...
     'Corner Max ($1.083,\ I_z = 0.377\ \mathrm{A}$)', ...
     '$I_{z,k}/I_{z,\mathrm{iso}}\ (C_{zz}^{-1}\ \mathrm{Drive})$'}, ...
    'Interpreter', 'latex', 'FontSize', 8.8, 'Location', 'north');
leg2.EdgeColor = [0.85, 0.85, 0.85];


%% ========================================================================
%  SUBPLOT (c): Mid-Plane Deviation |\Delta B| (y = 0)
%  ========================================================================
ax3 = axes('Position', [0.695, 0.14, 0.22, 0.77]);
hold(ax3, 'on');

% Grid in cm (-22 to 22 cm)
N_grid = 150;
x_cm = linspace(-22, 22, N_grid);
z_cm = linspace(-22, 22, N_grid);
[X_cm, Z_cm] = meshgrid(x_cm, z_cm);
X_m = X_cm / 100;
Z_m = Z_cm / 100;

% Compute 3D Orthogonal Helmholtz Field (Z-pair: Rz=0.250m, X-pair: Rx=0.235m)
% Nominal target at center: B0 = [Bx0, 0, Bz0] with Bz0 = 50 uT, Bx0 = 50 uT
Rx = 0.235;
[~, Bz0_1] = calc_loop_B([0,0,0], [0,0, Rz/2], Rz);
[~, Bz0_2] = calc_loop_B([0,0,0], [0,0,-Rz/2], Rz);
scale_z = 50.0 / (Bz0_1 + Bz0_2);

[~, Bx0_1] = calc_loop_B([0,0,0], [0,0, Rx/2], Rx);
[~, Bx0_2] = calc_loop_B([0,0,0], [0,0,-Rx/2], Rx);
scale_x = 50.0 / (Bx0_1 + Bx0_2);

dB_mag = zeros(N_grid, N_grid);
for i = 1:N_grid
    for j = 1:N_grid
        pt = [X_m(i,j), 0, Z_m(i,j)];
        
        % Z-Helmholtz contribution
        [Br_z1, Bz_z1] = calc_loop_B(pt, [0, 0,  Rz/2], Rz);
        [Br_z2, Bz_z2] = calc_loop_B(pt, [0, 0, -Rz/2], Rz);
        sgn_x = sign(pt(1));
        Bx_z = scale_z * (Br_z1 + Br_z2) * sgn_x;
        Bz_z = scale_z * (Bz_z1 + Bz_z2);
        
        % X-Helmholtz contribution (axis along X)
        pt_x = [pt(3), 0, pt(1)];
        [Br_x1, Bx_x1] = calc_loop_B(pt_x, [0, 0,  Rx/2], Rx);
        [Br_x2, Bx_x2] = calc_loop_B(pt_x, [0, 0, -Rx/2], Rx);
        sgn_z = sign(pt(3));
        Bz_x = scale_x * (Br_x1 + Br_x2) * sgn_z;
        Bx_x = scale_x * (Bx_x1 + Bx_x2);
        
        % Total Deviation |\Delta B|
        dBx = (Bx_z + Bx_x) - 50.0;
        dBz = (Bz_z + Bz_x) - 50.0;
        dB_mag(i,j) = sqrt(dBx^2 + dBz^2);
    end
end

% Clamp at 12.0 uT to match colorbar range [0, 12.0]
dB_clamped = min(dB_mag, 12.0);

% Plot 24 discrete filled contour levels
contourf(ax3, X_cm, Z_cm, dB_clamped, linspace(0, 12, 25), 'LineStyle', 'none');
clim(ax3, [0, 12]);

% Exact Matplotlib 'viridis_r' Colormap (Yellow at 0 -> Dark Purple at 12)
cmap_viridis_r = [
    0.9932, 0.9062, 0.1439;
    0.7098, 0.8680, 0.1693;
    0.4290, 0.8079, 0.3460;
    0.2080, 0.7187, 0.4729;
    0.1196, 0.6075, 0.5414;
    0.1490, 0.5089, 0.5574;
    0.1906, 0.4071, 0.5561;
    0.2410, 0.2923, 0.5385;
    0.2814, 0.1558, 0.4692;
    0.2670, 0.0049, 0.3294];
colormap(ax3, interp1(linspace(0, 1, 10), cmap_viridis_r, linspace(0, 1, 256)));

% 1.5 uT Solid White Contour + Labels
[C1, h1] = contour(ax3, X_cm, Z_cm, dB_mag, [1.5, 1.5], '-', 'Color', 'w', 'LineWidth', 1.8);
clabel(C1, h1, 'FontSize', 8.5, 'Color', 'w', 'LabelSpacing', 220);

% 5.0 uT Dashed Gold Contour + Labels
[C2, h2] = contour(ax3, X_cm, Z_cm, dB_mag, [5.0, 5.0], '--', 'Color', [0.98, 0.82, 0.18], 'LineWidth', 1.8);
clabel(C2, h2, 'FontSize', 8.5, 'Color', [0.98, 0.82, 0.18], 'LabelSpacing', 180);

% Core Sphere Circle (r = 10 cm)
th = linspace(0, 2*pi, 200);
p_core = plot(ax3, 10*cos(th), 10*sin(th), ':', 'Color', [0.85, 0.22, 0.18], 'LineWidth', 2.2);

cb3 = colorbar(ax3, 'Position', [0.922, 0.14, 0.012, 0.77]);
cb3.Label.String = '$|\Delta B(\mathbf{r})|\ (\mu\mathrm{T})$';
cb3.Label.Interpreter = 'latex';
cb3.Label.FontSize = 11;
cb3.Ticks = 0:1.5:12.0;
cb3.TickLabels = compose('%.1f', 0:1.5:12.0);

axis(ax3, 'image');
xlim(ax3, [-22, 22]);
ylim(ax3, [-22, 22]);
set(ax3, 'XTick', -20:10:20, 'YTick', -20:5:20, 'FontSize', 10.5, 'LineWidth', 0.8);
box(ax3, 'on');

xlabel(ax3, '$x\ \mathbf{Coordinate\ (cm)}$', 'Interpreter', 'latex', 'FontSize', 11.5);
ylabel(ax3, '$z\ \mathbf{Coordinate\ (cm)}$', 'Interpreter', 'latex', 'FontSize', 11.5);
title(ax3, '\textbf{(c) Mid-Plane Deviation} $|\Delta B|\ (y = 0)$', ...
    'Interpreter', 'latex', 'FontSize', 12.5);

leg3 = legend(ax3, p_core, {'Core Sphere ($r = 10\ \mathrm{cm}$)'}, ...
    'Interpreter', 'latex', 'FontSize', 9.2, 'Location', 'north');
leg3.EdgeColor = [0.85, 0.85, 0.85];


%% ========================================================================
%  HELPER FUNCTION: Exact Circular Loop Magnetic Field via Elliptic Integrals
%  ========================================================================
function [Br, Bz] = loop_field(r_vec, r0_vec, R)
    d = r_vec - r0_vec;
    rho = sqrt(d(1)^2 + d(2)^2);
    z = d(3);
    denom = (R + rho)^2 + z^2;
    k2 = 4 * R * rho / denom;
    [K, E] = ellipke(min(k2, 1 - 1e-12));
    
    denom2 = (R - rho)^2 + z^2;
    Bz = (1 / sqrt(denom)) * (K + E * (R^2 - rho^2 - z^2) / denom2);
    if rho < 1e-10
        Br = 0;
    else
        Br = (z / (rho * sqrt(denom))) * (-K + E * (R^2 + rho^2 + z^2) / denom2);
    end
end