clear; clc; close all;

% Set global font to Serif to match the publication style
set(0, 'DefaultAxesFontName', 'Times New Roman');
set(0, 'DefaultTextFontName', 'Times New Roman');

% Create figure window
fig = figure('Color', 'w', 'Units', 'pixels', 'Position', [80, 80, 1400, 580]);

%% ========================================================================
%  SUBPLOT (a): Nested Orthogonal Helmholtz Unit Cell (L_0 = 0.50 m)
%  ========================================================================
% Adjusted position so 3D box sits slightly lower, leaving room for title & legend
ax1 = axes('Position', [0.03, 0.11, 0.39, 0.68]);
hold(ax1, 'on');

% Exact Colors from Image
c_outer_z = [0.082, 0.302, 0.451]; % Dark Navy Blue (#154D73)
c_inner_x = [0.710, 0.200, 0.165]; % Brick Red (#B5332A)
c_sphere  = [0.165, 0.588, 0.506]; % Teal (#2A9681)
c_gold    = [0.831, 0.627, 0.090]; % Gold Marker (#D4A017)
c_gold_tx = [0.545, 0.412, 0.078]; % Dark Gold Text (#8B6914)

theta = linspace(0, 2*pi, 300);

% 1. Outer Z-Helmholtz Coils (Rz = 0.250 m, z = +/- Rz/2)
Rz = 0.250;
z_pos = Rz / 2;
x_z = Rz * cos(theta);
y_z = Rz * sin(theta);
p_z1 = plot3(ax1, x_z, y_z,  z_pos * ones(size(theta)), 'Color', c_outer_z, 'LineWidth', 3.0);
       plot3(ax1, x_z, y_z, -z_pos * ones(size(theta)), 'Color', c_outer_z, 'LineWidth', 3.0);

% 2. Inner X-Helmholtz Coils (Rx = 0.235 m, x = +/- Rx/2)
Rx = 0.235;
x_pos = Rx / 2;
y_x = Rx * cos(theta);
z_x = Rx * sin(theta);
p_x1 = plot3(ax1,  x_pos * ones(size(theta)), y_x, z_x, 'Color', c_inner_x, 'LineWidth', 3.0);
       plot3(ax1, -x_pos * ones(size(theta)), y_x, z_x, 'Color', c_inner_x, 'LineWidth', 3.0);

% 3. Core Canopy Sphere (r = 10 cm = 0.10 m)
r_s = 0.10;
[Xs, Ys, Zs] = sphere(18);
surf(ax1, r_s*Xs, r_s*Ys, r_s*Zs, ...
    'FaceColor', c_sphere, 'FaceAlpha', 0.08, ...
    'EdgeColor', c_sphere, 'EdgeAlpha', 0.45, 'LineWidth', 0.6);

% Dummy line for exact legend representation of the sphere
p_sph = plot3(ax1, [NaN NaN], [NaN NaN], [NaN NaN], '-', ...
    'Color', [c_sphere, 0.6], 'LineWidth', 1.0);

% 4. 3D Clearance Marker & Text (d_min = 16.8 mm) on front-right intersection
pt_clear = [0.1175, sqrt(Rz^2 - 0.1175^2), 0.125];
plot3(ax1, pt_clear(1), pt_clear(2), pt_clear(3), 'o', ...
    'MarkerSize', 8, 'MarkerFaceColor', c_gold, 'MarkerEdgeColor', c_gold);

text(ax1, pt_clear(1) - 0.01, pt_clear(2) + 0.015, pt_clear(3) + 0.045, ...
    {'$d_{\min} = 16.8\ \mathrm{mm}$', '\textbf{3D Clearance}'}, ...
    'Interpreter', 'latex', 'Color', c_gold_tx, 'FontSize', 10.5, ...
    'HorizontalAlignment', 'left');

% Axes Formatting & Exact 3D View matching Python/Matplotlib
grid(ax1, 'on');
ax1.GridLineStyle = '--';
ax1.GridAlpha = 0.45;
ax1.FontSize = 11;
ax1.TickLabelInterpreter = 'latex';
axis(ax1, 'equal');
xlim(ax1, [-0.28, 0.28]);
ylim(ax1, [-0.28, 0.28]);
zlim(ax1, [-0.28, 0.28]);

ticks_3d = -0.2:0.1:0.2;
tick_labels_3d = {'$-0.2$', '$-0.1$', '$0.0$', '$0.1$', '$0.2$'};
set(ax1, 'XTick', ticks_3d, 'XTickLabel', tick_labels_3d, ...
         'YTick', ticks_3d, 'YTickLabel', tick_labels_3d, ...
         'ZTick', ticks_3d, 'ZTickLabel', tick_labels_3d);

% Correct view so y(m) is on the left (-0.2 to 0.2) and x(m) is on the right (0.2 to -0.2)
view(ax1, [-38, 22]);
set(ax1, 'YDir', 'reverse');

xlabel(ax1, '$x\ (\mathrm{m})$', 'Interpreter', 'latex', 'FontSize', 12, 'Position', [0.02, 0.36, -0.32]);
ylabel(ax1, '$y\ (\mathrm{m})$', 'Interpreter', 'latex', 'FontSize', 12, 'Position', [-0.36, -0.02, -0.32]);
zlabel(ax1, '$z\ (\mathrm{m})$', 'Interpreter', 'latex', 'FontSize', 12);

% Use normalized title position to prevent any collision with 3D box or legend
t1 = title(ax1, '\textbf{(a) Nested Orthogonal Helmholtz Unit Cell ($L_0 = 0.50\ \mathbf{m}$)}', ...
    'Interpreter', 'latex', 'FontSize', 13.5);
set(t1, 'Units', 'normalized', 'Position', [0.52, 1.20, 0]);

% Place legend neatly below the title on the top-left without overlapping
leg1 = legend(ax1, [p_z1, p_x1, p_sph], ...
    {'Outer Z-Helmholtz ($R_z = 0.250\ \mathrm{m}$)', ...
     'Inner X-Helmholtz ($R_x = 0.235\ \mathrm{m}$)', ...
     'Core Canopy Sphere ($r = 10\ \mathrm{cm}$)'}, ...
    'Interpreter', 'latex', 'FontSize', 10.5);
set(leg1, 'Units', 'normalized', 'Position', [0.055, 0.77, 0.23, 0.13]);
leg1.BoxFace.ColorType = 'truecoloralpha';
leg1.BoxFace.ColorData = uint8(255 * [1; 1; 1; 0.92]);
leg1.EdgeColor = [0.8 0.8 0.8];


%% ========================================================================
%  SUBPLOT (b): Conductor Mass-Power Invariance & ESM Trade-Off
%  ========================================================================
ax2 = axes('Position', [0.50, 0.12, 0.47, 0.79]);
hold(ax2, 'on');

% Exact Colors from Image (b)
c_nom  = [0.082, 0.302, 0.451]; % Dark Navy Blue (#154D73)
c_leo  = [0.161, 0.478, 0.710]; % Medium Blue (#297AB5)
c_peak = [0.710, 0.200, 0.165]; % Brick Red (#B5332A)
c_esm  = [0.275, 0.353, 0.412]; % Dark Slate Grey (#465A69)
c_awg  = [0.075, 0.475, 0.376]; % Dark Teal Green (#137960)

M_z = linspace(0.08, 0.65, 500);

% Constants c_{1,z} (kg*W)
c1_nom  = 0.287;
c1_leo  = 0.830;
c1_peak = 1.103;
alpha   = 0.15; % kg/W

% Hyperbolic Curves: P_z = c_{1,z} / M_z
P_nom  = c1_nom  ./ M_z;
P_leo  = c1_leo  ./ M_z;
P_peak = c1_peak ./ M_z;

% ESM Optimum Locus: M_z* = alpha * P_z*  =>  P_z = M_z / alpha
P_esm  = M_z / alpha;

% Plot Curves
h_nom  = plot(ax2, M_z, P_nom,  '-',  'Color', c_nom,  'LineWidth', 2.4);
h_leo  = plot(ax2, M_z, P_leo,  '--', 'Color', c_leo,  'LineWidth', 2.4);
h_peak = plot(ax2, M_z, P_peak, '-.', 'Color', c_peak, 'LineWidth', 2.4);
h_esm  = plot(ax2, M_z, P_esm,  ':',  'Color', c_esm,  'LineWidth', 1.6);

% ESM Optimum Intersection Dots: M_z* = sqrt(alpha * c_{1,z}), P_z* = sqrt(c_{1,z} / alpha)
M_opt_nom  = sqrt(alpha * c1_nom);  P_opt_nom  = c1_nom  / M_opt_nom;
M_opt_leo  = sqrt(alpha * c1_leo);  P_opt_leo  = c1_leo  / M_opt_leo;
M_opt_peak = sqrt(alpha * c1_peak); P_opt_peak = c1_peak / M_opt_peak;

plot(ax2, M_opt_nom,  P_opt_nom,  'o', 'MarkerSize', 8.5, 'MarkerFaceColor', c_nom,  'MarkerEdgeColor', c_nom);
plot(ax2, M_opt_leo,  P_opt_leo,  'o', 'MarkerSize', 8.5, 'MarkerFaceColor', c_leo,  'MarkerEdgeColor', c_leo);
plot(ax2, M_opt_peak, P_opt_peak, 'o', 'MarkerSize', 8.5, 'MarkerFaceColor', c_peak, 'MarkerEdgeColor', c_peak);

% Selected 24 AWG Z-Winding Triangles (M_{z,24} = 0.230 kg)
M_24 = 0.230;
h_awg = plot(ax2, M_24, c1_nom/M_24, '^', 'MarkerSize', 9.5, ...
    'MarkerFaceColor', c_awg, 'MarkerEdgeColor', c_awg);
plot(ax2, M_24, c1_leo/M_24,  '^', 'MarkerSize', 9.5, ...
    'MarkerFaceColor', c_awg, 'MarkerEdgeColor', c_awg);
plot(ax2, M_24, c1_peak/M_24, '^', 'MarkerSize', 9.5, ...
    'MarkerFaceColor', c_awg, 'MarkerEdgeColor', c_awg);

% Annotation Callout Box & Arrow
plot(ax2, [0.308, 0.235], [1.18, 1.25], '-', 'Color', c_awg, 'LineWidth', 1.3);
plot(ax2, 0.235, 1.25, '<', 'MarkerSize', 6, 'MarkerFaceColor', c_awg, 'MarkerEdgeColor', c_awg);

text(ax2, 0.308, 1.05, ...
    {'\textbf{ESM Opt (0.208 kg, 1.38 W)}', '\textbf{24 AWG (0.230 kg, 1.25 W)}'}, ...
    'Interpreter', 'latex', 'Color', c_awg, 'FontSize', 10.5, ...
    'BackgroundColor', [0.95, 0.98, 0.97], 'EdgeColor', c_awg, ...
    'LineWidth', 1.1, 'Margin', 5);

% Axes Formatting
grid(ax2, 'on');
ax2.GridLineStyle = '--';
ax2.GridAlpha = 0.35;
box(ax2, 'on');
ax2.LineWidth = 0.9;
ax2.FontSize = 11;
ax2.TickLabelInterpreter = 'latex';

xlim(ax2, [0.08, 0.65]);
ylim(ax2, [0, 9]);
set(ax2, 'XTick', 0.1:0.1:0.6, 'YTick', 0:1:9);

xlabel(ax2, '\textbf{Z-Pair Copper Conductor Mass $M_z$ (kg)}', 'Interpreter', 'latex', 'FontSize', 12.5);
ylabel(ax2, '\textbf{Ohmic Joule Dissipation $P_z$ (W)}', 'Interpreter', 'latex', 'FontSize', 12.5);
title(ax2, '\textbf{(b) Conductor Mass-Power Invariance \& ESM Trade-Off}', 'Interpreter', 'latex', 'FontSize', 13.5);

% Legend
leg2 = legend(ax2, [h_nom, h_leo, h_peak, h_esm, h_awg], ...
    {'Nominal $B_z = 50\ \mu\mathrm{T}\ (c_{1,z} = 0.287\ \mathrm{kg\cdot W})$', ...
     'LEO $35\ \mu\mathrm{T}$ Comp. $B_z = 85\ \mu\mathrm{T}\ (c_{1,z} = 0.830\ \mathrm{kg\cdot W})$', ...
     'Peak $48\ \mu\mathrm{T}$ Comp. $B_z = 98\ \mu\mathrm{T}\ (c_{1,z} = 1.103\ \mathrm{kg\cdot W})$', ...
     'ESM Optimum Locus ($M_z^* = \alpha P_z^*,\ \alpha = 0.15\ \mathrm{kg/W}$)', ...
     'Selected 24 AWG Z-Winding ($M_{z,24} = 0.230\ \mathrm{kg}$)'}, ...
    'Interpreter', 'latex', 'FontSize', 10.5, 'Location', 'northeast');
leg2.EdgeColor = [0.8 0.8 0.8];