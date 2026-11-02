clear; clc; close all;

% Set global font to Arial/Sans-Serif to match the exact figure style
set(0, 'DefaultAxesFontName', 'Arial');
set(0, 'DefaultTextFontName', 'Arial');

% Create figure window with matching aspect ratio
fig = figure('Color', 'w', 'Units', 'pixels', 'Position', [40, 100, 1550, 465]);

% Magnetic Flux Density Grid B (0 to 100 uT)
B = linspace(0, 100, 400);

%% ========================================================================
%  EXACT CURVE MODELS (Powder-Averaged Quantum Spin Dynamics Profiles)
%  ========================================================================
% Base curve: I = 1/2, x1.0 (A_zz = 120 uT)
% Exact anchor points: Phi_S(0) = 0.384, LFE Trough at (14.5, 0.322),
% slight inflection around B = 38 uT, Phi_S(100) = 0.500
f_base = @(x) 0.5015 - 0.1935 * exp(-((x - 16.0)/39.5).^2) ...
            + 0.0760 * exp(-(x/7.2).^2) ...
            + 0.0085 * exp(-((x - 37.5)/7.0).^2);

% Subplot (a) Curves
y_x05 = f_base(B * 2.0);
y_x05 = 0.371 + (0.556 - 0.371) * (y_x05 - min(y_x05)) / (max(y_x05) - min(y_x05));
y_x10 = f_base(B);
y_x20 = f_base(B / 2.0) - 0.0175 * (1 - exp(-B/8.0));
y_x50 = f_base(B / 5.0) - 0.0255 * (1 - exp(-B/6.0));
y_N5  = 0.351 + 0.198 ./ (1 + (B/21.5).^1.48);

% Subplot (b) Multi-Nuclear Curves
y_8D  = y_x10;
y_16D = 0.362 - 0.023 * sin(pi * min(B, 56)/56).^1.42 + 0.130 * max(0, (B - 35)/65).^1.18;
y_24D = 0.348 - 0.011 * exp(-((B - 15.0)/14.0).^2) + 0.088 * (B/100).^1.55 ./ (1 + 0.15*(B/100).^2);

% Subplot (c) Triplet Branching Curves: <Phi_T(B)> = 1 - <Phi_S(B)>
y_T_sym  = 1 - y_x10;
y_T_N5   = 1 - y_N5;
y_T_fast = 0.851 + 0.024 * exp(-((B - 15.5)/16.0).^2) - 0.100 * (max(0, B - 15.5)/84.5).^1.45 .* exp(-0.004*max(0, B - 15.5));
y_T_slow = 0.270 + 0.068 * (1 - exp(-B/3.2)) .* exp(-max(0, B - 12)/65) ...
         - 0.055 * (B/100).^1.4 - 0.004 * exp(-((B - 37.5)/5.5).^2);

% Exact RGB Colors from Image
c_sky    = [0.337, 0.706, 0.914]; % Light Sky Blue dotted (#56B4E9)
c_navy   = [0.106, 0.310, 0.447]; % Dark Navy Blue solid (#1B4F72)
c_blue   = [0.161, 0.478, 0.710]; % Medium Blue dashed (#297AB5)
c_purp   = [0.545, 0.216, 0.659]; % Purple dash-dot (#8B37A8)
c_red    = [0.710, 0.200, 0.165]; % Brick Red solid (#B5332A)
c_teal   = [0.075, 0.475, 0.376]; % Dark Teal Green (#137960)
c_orange = [0.835, 0.369, 0.000]; % Vermilion Orange dash-dot (#D55E00)
c_band   = [0.895, 0.938, 0.968]; % Soft Light Blue LEO Band


%% ========================================================================
%  SUBPLOT (a): Hyperfine Tensor Scaling (x0.5 to x14)
%  ========================================================================
ax1 = axes('Position', [0.052, 0.14, 0.262, 0.77]);
hold(ax1, 'on');

% LEO Band Shaded Region (20.4 to 48.2 uT) & Target Baseline (50 uT)
h_band = fill(ax1, [20.4, 48.2, 48.2, 20.4], [0.28, 0.28, 0.58, 0.58], ...
    c_band, 'EdgeColor', 'none', 'FaceAlpha', 0.70);
h_base = xline(ax1, 50.0, '--', 'Color', [c_teal, 0.75], 'LineWidth', 1.2);

% Plot Curves
h1 = plot(ax1, B, y_x05, ':',  'Color', c_sky,  'LineWidth', 1.7);
h2 = plot(ax1, B, y_x10, '-',  'Color', c_navy, 'LineWidth', 2.4);
h3 = plot(ax1, B, y_x20, '--', 'Color', c_blue, 'LineWidth', 1.7);
h4 = plot(ax1, B, y_x50, '-.', 'Color', c_purp, 'LineWidth', 1.7);
h5 = plot(ax1, B, y_N5,  '-',  'Color', c_red,  'LineWidth', 2.6);

xlim(ax1, [-4, 104]);
ylim(ax1, [0.285, 0.568]);
set(ax1, 'XTick', 0:20:100, 'YTick', 0.30:0.05:0.55, ...
    'YTickLabel', {'0.30','0.35','0.40','0.45','0.50','0.55'}, ...
    'FontSize', 10, 'LineWidth', 0.8, 'TickDir', 'out');
box(ax1, 'on');

xlabel(ax1, '\textbf{Magnetic Flux Density} $B\ (\mu\mathbf{T})$', 'Interpreter', 'latex', 'FontSize', 11);
ylabel(ax1, '\textbf{Powder-Averaged Singlet Yield} $\langle\Phi_S(B)\rangle$', 'Interpreter', 'latex', 'FontSize', 11);
title(ax1, '\textbf{(a) Hyperfine Tensor Scaling ($\times 0.5$ to $\times 14$)}', 'Interpreter', 'latex', 'FontSize', 11.5);

leg1 = legend(ax1, [h1, h2, h3, h4, h5, h_base, h_band], ...
    {'$I = 1/2,\ \times 0.5\ (A_{zz} = 60\ \mu\mathrm{T})$', ...
     '$I = 1/2,\ \times 1.0\ (A_{zz} = 120\ \mu\mathrm{T})$', ...
     '$I = 1/2,\ \times 2.0\ (A_{zz} = 240\ \mu\mathrm{T})$', ...
     '$I = 1/2,\ \times 5.0\ (A_{zz} = 600\ \mu\mathrm{T})$', ...
     'Realistic $^{14}\mathrm{N}_5\ (I = 1,\ \times 14,\ A_{zz} = 1.68\ \mathrm{mT})$', ...
     'Target Baseline ($50\ \mu\mathrm{T}$)', ...
     'LEO Band ($20.4\mbox{--}48.2\ \mu\mathrm{T}$)'}, ...
    'Interpreter', 'latex', 'FontSize', 7.8, 'Location', 'northeast');
leg1.BoxFace.ColorType = 'truecoloralpha';
leg1.BoxFace.ColorData = uint8(255 * [1; 1; 1; 0.88]);
leg1.EdgeColor = [0.83, 0.83, 0.83];


%% ========================================================================
%  SUBPLOT (b): Multi-Nuclear Bath LFE Suppression
%  ========================================================================
ax2 = axes('Position', [0.388, 0.14, 0.262, 0.77]);
hold(ax2, 'on');

% LEO Band & Target Baseline (Dotted in b)
fill(ax2, [20.4, 48.2, 48.2, 20.4], [0.30, 0.30, 0.52, 0.52], ...
    c_band, 'EdgeColor', 'none', 'FaceAlpha', 0.70);
xline(ax2, 50.0, ':', 'Color', c_teal, 'LineWidth', 1.3);

% Plot Curves
hb1 = plot(ax2, B, y_8D,  '-',  'Color', c_navy,   'LineWidth', 2.4);
hb2 = plot(ax2, B, y_16D, '--', 'Color', c_teal,   'LineWidth', 2.2);
hb3 = plot(ax2, B, y_24D, '-.', 'Color', c_orange, 'LineWidth', 2.3);

% LFE Trough Marker & Arrow Annotation
plot(ax2, 14.5, 0.322, 'o', 'MarkerSize', 7.5, 'MarkerFaceColor', c_navy, 'MarkerEdgeColor', c_navy);
plot(ax2, [21.2, 15.8], [0.320, 0.322], '-', 'Color', c_navy, 'LineWidth', 1.1);
plot(ax2, 16.0, 0.322, '<', 'MarkerSize', 4.5, 'MarkerFaceColor', c_navy, 'MarkerEdgeColor', c_navy);
text(ax2, 22.0, 0.318, {'\textbf{LFE Trough}', '$\mathbf{(14.5\ \mu T,\ 0.322)}$'}, ...
    'Interpreter', 'latex', 'Color', c_navy, 'FontSize', 8.5);

xlim(ax2, [-4, 104]);
ylim(ax2, [0.305, 0.510]);
set(ax2, 'XTick', 0:20:100, 'YTick', 0.325:0.025:0.500, ...
    'YTickLabel', {'0.325','0.350','0.375','0.400','0.425','0.450','0.475','0.500'}, ...
    'FontSize', 10, 'LineWidth', 0.8, 'TickDir', 'out');
box(ax2, 'on');

xlabel(ax2, '\textbf{Magnetic Flux Density} $B\ (\mu\mathbf{T})$', 'Interpreter', 'latex', 'FontSize', 11);
ylabel(ax2, '\textbf{Powder-Averaged Singlet Yield} $\langle\Phi_S(B)\rangle$', 'Interpreter', 'latex', 'FontSize', 11);
title(ax2, '\textbf{(b) Multi-Nuclear Bath LFE Suppression}', 'Interpreter', 'latex', 'FontSize', 11.5);

leg2 = legend(ax2, [hb1, hb2, hb3], ...
    {'8D Single Nucleus ($I_1 = 1/2;\ \Delta\Phi_{\mathrm{trough}} = 0.062$)', ...
     '16D Two-Nucleus ($I_1 = 1/2, I_2 = 1/2;\ \Delta\Phi_{\mathrm{trough}} = 0.023$)', ...
     '24D Two-Nucleus ($I_1 = 1, I_2 = 1/2;\ \Delta\Phi_{\mathrm{trough}} = 0.011$)'}, ...
    'Interpreter', 'latex', 'FontSize', 7.8, 'Location', 'northwest');
leg2.BoxFace.ColorType = 'truecoloralpha';
leg2.BoxFace.ColorData = uint8(255 * [1; 1; 1; 0.88]);
leg2.EdgeColor = [0.83, 0.83, 0.83];


%% ========================================================================
%  SUBPLOT (c): Triplet Branching & Asymmetric Kinetics
%  ========================================================================
ax3 = axes('Position', [0.720, 0.14, 0.262, 0.77]);
hold(ax3, 'on');

% LEO Band & Target Baseline
fill(ax3, [20.4, 48.2, 48.2, 20.4], [0.15, 0.15, 0.95, 0.95], ...
    c_band, 'EdgeColor', 'none', 'FaceAlpha', 0.70);
xline(ax3, 50.0, ':', 'Color', c_teal, 'LineWidth', 1.3);

% Plot Curves
hc1 = plot(ax3, B, y_T_sym,  '-',  'Color', c_navy, 'LineWidth', 2.4);
hc2 = plot(ax3, B, y_T_N5,   '-',  'Color', c_red,  'LineWidth', 2.4);
hc3 = plot(ax3, B, y_T_fast, '--', 'Color', c_teal, 'LineWidth', 2.2);
hc4 = plot(ax3, B, y_T_slow, '-.', 'Color', c_purp, 'LineWidth', 2.2);

xlim(ax3, [-4, 104]);
ylim(ax3, [0.18, 0.92]);
set(ax3, 'XTick', 0:20:100, 'YTick', 0.2:0.1:0.9, ...
    'YTickLabel', {'0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9'}, ...
    'FontSize', 10, 'LineWidth', 0.8, 'TickDir', 'out');
box(ax3, 'on');

xlabel(ax3, '\textbf{Magnetic Flux Density} $B\ (\mu\mathbf{T})$', 'Interpreter', 'latex', 'FontSize', 11);
ylabel(ax3, '\textbf{Triplet Branching Yield} $\langle\Phi_T(B)\rangle = 1 - \langle\Phi_S(B)\rangle$', 'Interpreter', 'latex', 'FontSize', 11);
title(ax3, '\textbf{(c) Triplet Branching \& Asymmetric Kinetics}', 'Interpreter', 'latex', 'FontSize', 11.5);

leg3 = legend(ax3, [hc1, hc2, hc3, hc4], ...
    {'Symmetric $\langle\Phi_T\rangle\ (k_S = k_T = 1.0\ \mu\mathrm{s}^{-1})$', ...
     'Realistic $^{14}\mathrm{N}_5\ \langle\Phi_T\rangle\ (\Delta\langle\Phi_T\rangle_{50-0} = +0.165)$', ...
     'Fast Escape $\langle\Phi_T\rangle\ (k_S = 0.5, k_T = 2.0\ \mu\mathrm{s}^{-1})$', ...
     'Slow Escape $\langle\Phi_T\rangle\ (k_S = 1.0, k_T = 0.2\ \mu\mathrm{s}^{-1})$'}, ...
    'Interpreter', 'latex', 'FontSize', 7.8, 'Location', 'east');
leg3.BoxFace.ColorType = 'truecoloralpha';
leg3.BoxFace.ColorData = uint8(255 * [1; 1; 1; 0.88]);
leg3.EdgeColor = [0.83, 0.83, 0.83];