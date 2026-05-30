%% Processamento de sinal e instrumentação
% Autores: Francisco Esteves 110299
%          Mónica Pereira    109344
%          Sofia Duarte 109528
%
clearvars; close all; clc;

%% Visualização Temporal das acelerações

% 1. Read the data
data = readtable('EV_2026_B33.csv');

% 2. Create a single, large figure window
fig = figure('Name', 'High-Resolution Accelerations Analysis', ...
    'Units', 'normalized', 'Position', [0.1, 0.1, 0.9, 0.9], ...
    'NumberTitle', 'off');

% 3. Create the tab container group inside the figure
tabGroup = uitabgroup(fig);


% ==========================================
% Tab 1: Acceleration 1
% ==========================================
tab1 = uitab(tabGroup, 'Title', 'Acceleration 1 (a1)');
ax1 = axes(tab1); % Create the plotting area inside this specific tab

plot(ax1, data.t, data.a1, 'b-', 'LineWidth', 1.2);
xlabel(ax1, 'Time (s)'); 
ylabel(ax1, 'a1'); 
title(ax1, 'Acceleration 1 vs Time');

xlim(ax1, [0, 10]);             % Lock time window to 0-10s
xticks(ax1, 0:0.25:10);          % Main tick marks every 0.5s
grid(ax1, 'on');                % Main grid
grid(ax1, 'minor');             % High-resolution minor grid


% ==========================================
% Tab 2: Acceleration 2
% ==========================================
tab2 = uitab(tabGroup, 'Title', 'Acceleration 2 (a2)');
ax2 = axes(tab2);

plot(ax2, data.t, data.a2, 'r-', 'LineWidth', 1.2);
xlabel(ax2, 'Time (s)'); 
ylabel(ax2, 'a2'); 
title(ax2, 'Acceleration 2 vs Time');

xlim(ax2, [0, 10]);
xticks(ax2, 0:0.25:10);
grid(ax2, 'on');
grid(ax2, 'minor');


% ==========================================
% Tab 3: Acceleration 3
% ==========================================
tab3 = uitab(tabGroup, 'Title', 'Acceleration 3 (a3)');
ax3 = axes(tab3);

plot(ax3, data.t, data.a3, 'g-', 'LineWidth', 1.2);
xlabel(ax3, 'Time (s)'); 
ylabel(ax3, 'a3'); 
title(ax3, 'Acceleration 3 vs Time');

xlim(ax3, [0, 10]);
xticks(ax3, 0:0.25:10);
grid(ax3, 'on');
grid(ax3, 'minor');


% ==========================================
% Tab 4: Acceleration 4
% ==========================================
tab4 = uitab(tabGroup, 'Title', 'Acceleration 4 (a4)');
ax4 = axes(tab4);

plot(ax4, data.t, data.a4, 'k-', 'LineWidth', 1.2);
xlabel(ax4, 'Time (s)'); 
ylabel(ax4, 'a4'); 
title(ax4, 'Acceleration 4 vs Time');

xlim(ax4, [0, 10]);
xticks(ax4, 0:0.25:10);
grid(ax4, 'on');
grid(ax4, 'minor');


% ==========================================
% Keep Zooming Synchronized
% ==========================================
% This links the X-axes of all 4 tabs together. If you use the zoom tool 
% to closely inspect a sharp spike in Tab 1, when you click over to Tab 2, 
% Tab 3, or Tab 4, they will automatically be zoomed into that exact same time window!
linkaxes([ax1, ax2, ax3, ax4], 'x');


%% Análise Espetral (FFT) e Caracterização de Picos

% Parâmetros de amostragem
fs = 1000;          % Frequência de amostragem (Hz)

% Sinais e cores (consistentes com a secção anterior)
sig_names = {'a1', 'a2', 'a3', 'a4'};
sig_colors = {'b', 'r', 'g', 'k'};
signals = {data.a1, data.a2, data.a3, data.a4};
t = data.t;

% Criar figura com layout 4x2 (coluna esquerda: tempo, direita: espetro)
fig2 = figure('Name', 'Spectral Analysis of Accelerations', ...
    'Units', 'normalized', 'Position', [0.1, 0.1, 0.9, 0.9], ...
    'NumberTitle', 'off');

for i = 1:4
    sig = signals{i};

    % ========== Gráfico Temporal (esquerda) ==========
    subplot(4, 2, 2*i-1);
    plot(t, sig, sig_colors{i}, 'LineWidth', 1);
    xlim([0, 10]);
    xlabel('Time (s)');
    ylabel('Amplitude');
    title(sprintf('Acceleration %s - Time Domain', sig_names{i}));
    grid on;

    % ========== Espetro de Amplitude Unilateral (direita) ==========
    subplot(4, 2, 2*i);

    % Remover componente DC
    sig_dc = sig - mean(sig);
    N = length(sig_dc);

    % FFT e espetro unilateral
    Y = fft(sig_dc);
    P2 = abs(Y / N);
    P1 = P2(1:ceil(N/2));
    f = fs * (0:ceil(N/2)-1) / N;
    P1(2:end) = 2 * P1(2:end);  % Escalar amplitudes (exceto DC)

    plot(f, P1, sig_colors{i}, 'LineWidth', 1);
    xlim([0, 500]);
    xlabel('Frequency (Hz)');
    ylabel('Amplitude');
    title(sprintf('%s - Amplitude Spectrum', sig_names{i}));
    grid on;

    % ========== Identificação de Picos ==========
    min_height = max(P1) * 0.1;       % Ignorar amplitudes < 10% do máximo
    min_dist = round(fs / 1);         % Distância mínima entre picos: 1 Hz

    [pks, locs] = findpeaks(P1, 'MinPeakHeight', min_height, ...
        'MinPeakDistance', min_dist);

    % Anotar picos no gráfico
    hold on;
    h_peaks = plot(f(locs), pks, 'ro', 'MarkerSize', 6, 'MarkerFaceColor', 'r');
    for j = 1:length(locs)
        text(f(locs(j)), pks(j), sprintf('%.1f Hz', f(locs(j))), ...
            'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', ...
            'FontSize', 8, 'Color', 'r');
    end
    hold off;
    legend(h_peaks, 'Significant peaks', 'Location', 'northeast');

    % ========== Imprimir resumo dos picos na consola ==========
    fprintf('\n========== %s - Peak Characterization ==========\n', sig_names{i});
    fprintf('%-15s %-15s\n', 'Frequency (Hz)', 'Amplitude');
    fprintf('----------------------------------------\n');
    for j = 1:length(locs)
        fprintf('%-15.2f %-15.4f\n', f(locs(j)), pks(j));
    end
    fprintf('===============================================\n');
end


%% Guardar figuras como PNG
% Figura 1 - cada separador temporal guardado individualmente
tab_handles = {tab1, tab2, tab3, tab4};
tab_names = {'a1', 'a2', 'a3', 'a4'};
for idx = 1:4
    tabGroup.SelectedTab = tab_handles{idx};
    drawnow;
    exportgraphics(tabGroup.SelectedTab, ...
        sprintf('visualizacao_%s_temporal.png', tab_names{idx}), ...
        'Resolution', 300);
end

% Figura 2 - análise espetral: 4 imagens (uma por sinal, cada uma com
% o gráfico temporal + respetivo espetro de amplitude lado a lado)
for i = 1:4
    sig = signals{i};

    f_row = figure('Visible', 'off', 'Units', 'normalized', ...
        'Position', [0.1, 0.3, 0.8, 0.4]);

    % Gráfico temporal
    subplot(1, 2, 1);
    plot(t, sig, sig_colors{i}, 'LineWidth', 1);
    xlim([0, 10]);
    xlabel('Time (s)');
    ylabel('Amplitude');
    title(sprintf('Acceleration %s - Time Domain', sig_names{i}));
    grid on;

    % Espetro de amplitude
    subplot(1, 2, 2);
    sig_dc = sig - mean(sig);
    N = length(sig_dc);
    Y = fft(sig_dc);
    P2 = abs(Y / N);
    P1 = P2(1:ceil(N/2));
    f = fs * (0:ceil(N/2)-1) / N;
    P1(2:end) = 2 * P1(2:end);
    plot(f, P1, sig_colors{i}, 'LineWidth', 1);
    xlim([0, 500]);
    xlabel('Frequency (Hz)');
    ylabel('Amplitude');
    title(sprintf('%s - Amplitude Spectrum', sig_names{i}));
    grid on;

    exportgraphics(f_row, sprintf('analise_espectral_%s.png', sig_names{i}), ...
        'Resolution', 300);
    close(f_row);
end