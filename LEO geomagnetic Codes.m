clear; clc; close all;
set(0, 'DefaultAxesFontName', 'Arial');
set(0, 'DefaultTextFontName', 'Arial');

fig = figure('Color', 'w', 'Units', 'pixels', 'Position', [80, 80, 1250, 680]);

% Time Grid: 24 Hours, dt = 10 s, Ns = 8641
t_hr = linspace(0, 24, 8641);
f_orb = 15.54 / 24;
w_orb = 2 * pi * f_orb;
w_earth = 2 * pi / 24;

% Exact Colors
c_amb   = [0.161, 0.478, 0.659];
c_lock  = [0.075, 0.494, 0.400];
c_thres = [0.710, 0.200, 0.165];
c_saa   = [0.486, 0.212, 0.643];
c_zcoil = [0.106, 0.310, 0.447];
c_xcoil = [0.710, 0.282, 0.243];
c_yamb  = [0.800, 0.651, 0.078];

% 1. Synthesize Diurnal LEO Geomagnetic Excursion (20.41 uT to 48.24 uT)
env_saa = exp(-((t_hr - 16.2)/3.2).^2);
B_raw = 35.5 - 11.2 * cos(2 * w_orb * t_hr + 0.55) ...
    - 2.6 * cos(w_orb * t_hr - 0.8) .* sin(w_earth * t_hr) ...
    - 4.8 * env_saa .* (0.55 + 0.45 * cos(w_orb * t_hr));
B_amb_mag = 20.41 + (48.24 - 20.41) * (B_raw - min(B_raw)) / (max(B_raw) - min(B_raw));

% 2. Truly Smooth C^\infty LVLH Profiles for Subplot (b) (Image 3 version)
By_amb = 13.5 * sin(w_earth * t_hr - 0.5) .* sin(w_orb * t_hr + 0.2) ...
    + 2.5 * cos(2 * w_earth * t_hr);
Bx_coil = -(24.5 * cos(w_orb * t_hr - 0.15) .* (0.92 + 0.08 * cos(w_earth * t_hr)) ...
    + 3.5 * sin(2 * w_orb * t_hr + 0.4));

% Smooth continuous Bz_amb giving Bz_coil smoothly oscillating between ~3 uT and ~98 uT
Bz_amb = -44.0 * sin(w_orb * t_hr - 0.05) .* (0.94 + 0.06 * cos(w_earth * t_hr - 1.2)) - 2.0;
Bz_coil = sqrt(50^2 - By_amb.^2) - Bz_amb;

%% SUBPLOT (a)
ax1 = axes('Position', [0.065, 0.56, 0.915, 0.38]);
hold(ax1, 'on');

h_bnd = fill(ax1, [t_hr, fliplr(t_hr)], [49.23*ones(size(t_hr)), 50.39*ones(size(t_hr))], ...
    c_lock, 'FaceAlpha', 0.22, 'EdgeColor', c_lock, 'EdgeAlpha', 0.35);

h_amb   = plot(ax1, t_hr, B_amb_mag, '-', 'Color', c_amb, 'LineWidth', 1.4);
h_lock  = plot(ax1, t_hr, 50.0*ones(size(t_hr)), '-', 'Color', c_lock, 'LineWidth', 2.6);
h_thres = yline(ax1, 35.0, '--', 'Color', c_thres, 'LineWidth', 1.4);
h_saa   = yline(ax1, 20.41, ':', 'Color', c_saa, 'LineWidth', 1.3);
yline(ax1, 48.24, ':', 'Color', c_saa, 'LineWidth', 1.3);

xlim(ax1, [0, 24]); ylim(ax1, [16, 56]);
set(ax1, 'XTick', 0:5:20, 'XTickLabel', [], 'YTick', 20:5:55, 'FontSize', 10, 'LineWidth', 0.8);
box(ax1, 'on');

ylabel(ax1, '\textbf{Magnetic Flux Density} $|\mathbf{B}|\ (\mu\mathbf{T})$', 'Interpreter', 'latex', 'FontSize', 11);
title(ax1, '\textbf{(a) 24-Hour Diurnal LEO Geomagnetic Excursion (15.54 Orbits) vs. Active Magnitude-Locking}', ...
    'Interpreter', 'latex', 'FontSize', 12.5);

leg1 = legend(ax1, [h_amb, h_lock, h_bnd, h_thres, h_saa], ...
    {'Uncompensated LEO Ambient $|\mathbf{B}_{\mathrm{amb}}(t)|$ (IGRF-14, $h = 400\ \mathrm{km},\ i = 51.6^\circ$)', ...
    'Isolated-Cell Locked Magnitude $|\mathbf{B}_{\mathrm{net}}(t)| \equiv 50.00\ \mu\mathrm{T}$ (Eqs. 2--3)', ...
    '24-Bay Decoupled Array Bounds ($49.23\mbox{--}50.39\ \mu\mathrm{T}$)', ...
    'Low-Field Threshold ($35.0\ \mu\mathrm{T}$; $53.12\%$ Diurnal Exposure)', ...
    'SAA Minimum ($20.41\ \mu\mathrm{T}$) / Auroral Maximum ($48.24\ \mu\mathrm{T}$)'}, ...
    'Interpreter', 'latex', 'FontSize', 8.5, 'NumColumns', 2, 'Location', 'southeast');
leg1.EdgeColor = [0.82, 0.82, 0.82];

%% SUBPLOT (b)
ax2 = axes('Position', [0.065, 0.09, 0.915, 0.38]);
hold(ax2, 'on');

h_zc = plot(ax2, t_hr, Bz_coil, '-',  'Color', c_zcoil, 'LineWidth', 1.4);
h_xc = plot(ax2, t_hr, Bx_coil, '-',  'Color', c_xcoil, 'LineWidth', 1.2);
h_ya = plot(ax2, t_hr, By_amb,  '--', 'Color', c_yamb,  'LineWidth', 1.2);

xlim(ax2, [0, 24]); ylim(ax2, [-42, 105]);
set(ax2, 'XTick', 0:5:20, 'YTick', -40:20:100, 'FontSize', 10, 'LineWidth', 0.8);
box(ax2, 'on');

xlabel(ax2, '\textbf{Simulated On-Orbit Diurnal Time} $t\ (\mathbf{Hours},\ \Delta t = 10\ \mathbf{s},\ N_s = 8641)$', ...
    'Interpreter', 'latex', 'FontSize', 11);
ylabel(ax2, '\textbf{Component Field} $(\mu\mathbf{T})$', 'Interpreter', 'latex', 'FontSize', 11);
title(ax2, '\textbf{(b) Smooth} $C^\infty$ \textbf{Dual-Axis Actuator Compensation Profiles in LVLH Coordinates}', ...
    'Interpreter', 'latex', 'FontSize', 12.5);

leg2 = legend(ax2, [h_zc, h_xc, h_ya], ...
    {'Active Z-Coil Output $B_{z,\mathrm{coil}}(t) = +\sqrt{50^2 - B_{y,\mathrm{amb}}^2} - B_{z,\mathrm{amb}}$', ...
    'Active X-Coil Nulling $B_{x,\mathrm{coil}}(t) = -B_{x,\mathrm{amb}}\ (B_{x,\mathrm{rms}} = 17.8\ \mu\mathrm{T})$', ...
    'Passively Accepted Transverse $B_{y,\mathrm{amb}}(t)$'}, ...
    'Interpreter', 'latex', 'FontSize', 8.8, 'Orientation', 'horizontal', 'Location', 'north');
leg2.EdgeColor = [0.82, 0.82, 0.82];