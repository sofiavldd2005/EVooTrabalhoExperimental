%% GNSS e Requisitos de Navegação
% Autores: Francisco Esteves 110299
%          Mónica Pereira    109344
%          Sofia Duarte 109528

clearvars; close all; clc;

%% 1. Implementação Matemática: Conversão WGS84 para Cartesianas e Cálculo de Erros

% Parâmetros do elipsoide WGS84
a = 6378137.0;          % Semi-eixo maior (m)
f = 1/298.257223563;    % Achatamento
e2 = 2*f - f^2;         % Primeira excentricidade ao quadrado

% Coordenadas de referência (WGS84)
lat_ref = 38.80572066;   % °N
lon_ref = -9.19497089;   % °W
alt_ref = 1282.203;      % m

% Soluções de navegação: [Lat (°N), Lon (°W), Alt (m)]
nav = [
    38.80482050, -9.19496103, 1284.221;   % A
    38.80562050, -9.19497003, 1282.221;   % B
    38.80572550, -9.19497203, 1281.321;   % C
    38.80581050, -9.19497603, 1280.221    % D
];
nav_names = {'A', 'B', 'C', 'D'};

% Função de conversão WGS84 → Cartesianas (ECEF)
to_cart = @(lat, lon, alt) wgs842ecef(lat, lon, alt, a, e2);

% Referência em Cartesianas (ponto B = REF, ponto A = origem (0,0,0))
ref_cart = to_cart(lat_ref, lon_ref, alt_ref);
r_vec = ref_cart;       % vetor AB = B - A = B (A = origem)
norm_r = norm(r_vec);

% Ponto A' = B - ξ * r/|r| (ξ = 10)
xi = 10;
A_linha = ref_cart - xi * r_vec / norm_r;
r_linha = xi * r_vec / norm_r;   % vetor A'B
norm_r_linha = norm(r_linha);

fprintf('========== Tarefa 1: Implementação Matemática ==========\n');
fprintf('Coordenadas Cartesianas (ECEF) da Referência:\n');
fprintf('  X = %.4f m\n', ref_cart(1));
fprintf('  Y = %.4f m\n', ref_cart(2));
fprintf('  Z = %.4f m\n', ref_cart(3));
fprintf('\n');

for i = 1:4
    C = to_cart(nav(i,1), nav(i,2), nav(i,3));
    s_linha = C - A_linha;

    % HPE (d): distância perpendicular entre C e a reta AB
    d = norm(cross(s_linha, r_linha)) / norm_r_linha;

    % VPE (h): desvio ao longo da direção vertical (radial)
    h = sqrt(norm(s_linha)^2 - d^2) - norm_r_linha;

    fprintf('Solução %s:\n', nav_names{i});
    fprintf('  X = %.4f m, Y = %.4f m, Z = %.4f m\n', C(1), C(2), C(3));
    fprintf('  HPE (d) = %.4f m\n', d);
    fprintf('  VPE (h) = %.4f m\n', h);
    fprintf('\n');
end


%% 2. Validação de Ferramenta: Erros A-D via fórmula de Haversine

fprintf('========== Tarefa 2: Validação de Ferramenta ==========\n');
fprintf('Comparação: Ponto 1 (ξ=10) vs Ponto 2 (Haversine)\n\n');

% Haversine para HPE e dif. absoluta de alturas para VPE (secção 3.2)
R_terra = 6378137;  % semi-eixo maior WGS84 (m)

fprintf('--- Ponto 1: Método ξ=10 (Implementação Matemática) ---\n');
fprintf('%-8s %-15s %-15s\n', 'Sol', 'HPE (m)', 'VPE (m)');
fprintf('------------------------------------------------\n');
for i = 1:4
    C = to_cart(nav(i,1), nav(i,2), nav(i,3));
    s_linha = C - A_linha;
    d = norm(cross(s_linha, r_linha)) / norm_r_linha;
    h = sqrt(norm(s_linha)^2 - d^2) - norm_r_linha;
    hpe_xi(i) = d;
    vpe_xi(i) = h;
    fprintf('%-8s %-15.4f %-15.4f\n', nav_names{i}, d, h);
end
fprintf('\n');

% Ponto 2: Haversine para HPE, |Δalt| para VPE
fprintf('--- Ponto 2: Fórmula de Haversine (Ferramenta) ---\n');
fprintf('%-8s %-15s %-15s\n', 'Sol', 'HPE (m)', 'VPE (m)');
fprintf('------------------------------------------------\n');
for i = 1:4
    % Haversine
    phi1 = deg2rad(lat_ref);
    phi2 = deg2rad(nav(i,1));
    dphi = phi2 - phi1;
    dlam = deg2rad(nav(i,2) - lon_ref);
    a_hav = sin(dphi/2)^2 + cos(phi1)*cos(phi2)*sin(dlam/2)^2;
    hpe_hav(i) = R_terra * 2 * atan2(sqrt(a_hav), sqrt(1 - a_hav));
    % VPE: diferença absoluta de altitudes
    vpe_hav(i) = abs(nav(i,3) - alt_ref);
    fprintf('%-8s %-15.4f %-15.4f\n', nav_names{i}, hpe_hav(i), vpe_hav(i));
end
fprintf('\n');

% Comparação
fprintf('--- Comparação (Ponto 1 vs Ponto 2) ---\n');
fprintf('%-8s %-15s %-15s %-15s %-15s\n', ...
    'Sol', 'ΔHPE (m)', 'ΔVPE (m)', 'ΔHPE/HPE (%)', 'ΔVPE/VPE (%)');
fprintf('------------------------------------------------------------------\n');
for i = 1:4
    dh = hpe_xi(i) - hpe_hav(i);
    dv = vpe_xi(i) - vpe_hav(i);
    fprintf('%-8s %-15.4f %-15.4f %-15.2f %-15.2f\n', ...
        nav_names{i}, dh, dv, dh/hpe_hav(i)*100, dv/vpe_hav(i)*100);
end
fprintf('\n');


%% 3. Análise de Desempenho SBAS (processamento do ficheiro C33)

fprintf('========== Tarefa 3: Análise de Desempenho SBAS ==========\n\n');

% Ler ficheiro GNSS
gnss = readtable('EV_2026_A33.csv');

% Extrair campos
tom   = gnss.RX_TOM;          % Tempo (s)
nsat_used = gnss.NSV_USED;    % Satélites usados na solução EGNOS
nsat_lock = gnss.NSV_LOCK;    % Satélites observados pelo recetor
HPL   = gnss.NS_HPL;          % Nível proteção horizontal (m)
VPL   = gnss.NS_VPL;          % Nível proteção vertical (m)

% Converter GPS time (TOW + week) para UTC
% GPS epoch: 6 de janeiro de 1980 00:00:00
% GPS-UTC offset: 18 segundos (em 2025)
gps_epoch = datetime(1980, 1, 6, 0, 0, 0);
gps_leap = 18;
gps_week = gnss.RX_WEEK(1);        % constante para este voo
utc_time = gps_epoch + seconds(gps_week * 604800 + tom - gps_leap);

% Calcular HPE (Haversine) e VPE (|Δalt|) para cada instante
% Método da "ferramenta" — secção 3.2 do relatório experimental
N = height(gnss);

phi1 = deg2rad(gnss.NS_LAT);
phi2 = deg2rad(gnss.REF_LAT);
dphi = phi2 - phi1;
dlam = deg2rad(gnss.REF_LON - gnss.NS_LON);

a_hav = sin(dphi/2).^2 + cos(phi1).*cos(phi2).*sin(dlam/2).^2;
HPE = R_terra * 2 * atan2(sqrt(a_hav), sqrt(1 - a_hav));

VPE = abs(gnss.NS_ALT - gnss.REF_ALT);

% ---- Estatísticas descritivas ----
fprintf('--- Estatísticas Descritivas ---\n');
fprintf('HPE: min=%.4f, mediana=%.4f, max=%.4f\n', min(HPE), median(HPE), max(HPE));
fprintf('HPL: min=%.4f, mediana=%.4f, max=%.4f\n', min(HPL), median(HPL), max(HPL));
fprintf('VPE: min=%.4f, mediana=%.4f, max=%.4f\n', min(VPE), median(VPE), max(VPE));
fprintf('VPL: min=%.4f, mediana=%.4f, max=%.4f\n', min(VPL), median(VPL), max(VPL));
fprintf('\n');

% ---- Exatidão (Accuracy) - 95º percentil ----
HPE_95 = prctile(HPE, 95);
VPE_95 = prctile(VPE, 95);

fprintf('--- Exatidão (Accuracy) ---\n');
fprintf('HPE (95%%) = %.4f m  (limite APV-I/CAT-I/APV-II = 16 m)\n', HPE_95);
fprintf('VPE (95%%) = %.4f m  (limite APV-I = 20 m, APV-II = 8 m, CAT-I = 5 m)\n', VPE_95);
fprintf('\n');

% ---- Integridade (Integrity) - 99º percentil dos níveis de proteção ----
HPL_99 = prctile(HPL, 99);
VPL_99 = prctile(VPL, 99);

fprintf('--- Integridade (Integrity) ---\n');
fprintf('HPL (99%%) = %.4f m  (limite HAL = 40 m)\n', HPL_99);
fprintf('VPL (99%%) = %.4f m  (limite VAL: APV-I=50 m, APV-II=20 m, CAT-I=12 m)\n', VPL_99);
fprintf('\n');

% ---- Estatísticas de satélites ----
fprintf('--- Janela Temporal (UTC) ---\n');
fprintf('Início: %s\n', datestr(utc_time(1), 'dd-mmm-yyyy HH:MM:SS'));
fprintf('Fim:    %s\n', datestr(utc_time(end), 'dd-mmm-yyyy HH:MM:SS'));
fprintf('Duração: %.0f s (%.1f min)\n', seconds(utc_time(end)-utc_time(1)), ...
    seconds(utc_time(end)-utc_time(1))/60);
fprintf('\n');

fprintf('--- Estatísticas de Satélites ---\n');
fprintf('NSV_LOCK: min=%d, max=%d, média=%.1f\n', ...
    min(nsat_lock), max(nsat_lock), mean(nsat_lock));
fprintf('NSV_USED: min=%d, max=%d, média=%.1f\n', ...
    min(nsat_used), max(nsat_used), mean(nsat_used));
diff_sat = nsat_lock - nsat_used;
fprintf('Diferença (LOCK - USED): min=%d, max=%d, média=%.1f\n', ...
    min(diff_sat), max(diff_sat), mean(diff_sat));
fprintf('\n');

% ---- Disponibilidade (Availability) ----
% Modos de operação
modes = {'APV-I', 'APV-II', 'CAT-I'};
HAL = [40, 40, 40];
VAL_modes = [50, 20, 12];

fprintf('--- Disponibilidade (Availability) ---\n');
for m = 1:3
    avail_mask = (HPL < HAL(m)) & (VPL < VAL_modes(m));
    avail_pct = sum(avail_mask) / N * 100;
    fprintf('%s: %.2f%% disponível  (requisito ICAO: > 99%%)\n', ...
        modes{m}, avail_pct);
end
fprintf('\n');

% ---- Continuidade (Continuity) ----
fprintf('--- Continuidade (Continuity) ---\n');
for m = 1:3
    avail_mask = (HPL < HAL(m)) & (VPL < VAL_modes(m));
    % Contar transições disponível→indisponível
    transitions = diff([0; avail_mask; 0]);
    n_events = sum(transitions == 1);    % inicios de períodos disponíveis
    fprintf('%s: %d evento(s) de continuidade\n', modes{m}, n_events);
end
fprintf('\n');


%% 4. Identificação de Eventos de Integridade

fprintf('========== Tarefa 4: Eventos de Integridade ==========\n\n');

% Evento: HPL < HPE  ou  VPL < VPE
int_event_horiz = find(HPL < HPE);
int_event_vert  = find(VPL < VPE);
int_event_all   = unique([int_event_horiz; int_event_vert]);

fprintf('Eventos de integridade (HPL < HPE ou VPL < VPE):\n');
if isempty(int_event_all)
    fprintf('  Nenhum evento detetado.\n');
else
    fprintf('  Total: %d instantes\n', length(int_event_all));
    fprintf('  Horizontais: %d | Verticais: %d\n', ...
        length(int_event_horiz), length(int_event_vert));
    % Mostrar os primeiros 10 eventos
    n_show = min(10, length(int_event_all));
    for k = 1:n_show
        idx = int_event_all(k);
        fprintf('  %s | HPE=%.4f HPL=%.4f | VPE=%.4f VPL=%.4f\n', ...
            datestr(utc_time(idx), 'HH:MM:SS'), HPE(idx), HPL(idx), VPE(idx), VPL(idx));
    end
    if length(int_event_all) > 10
        fprintf('  ... e mais %d eventos.\n', length(int_event_all) - 10);
    end
end
fprintf('\n');


%% Gráfico 1: HPE e HPL ao longo do tempo

fig_hpe = figure('Name', 'HPE and HPL', ...
    'Units', 'normalized', 'Position', [0.05, 0.3, 0.9, 0.5], ...
    'NumberTitle', 'off');
h_hpe = plot(utc_time, HPE, 'b-', 'LineWidth', 1); hold on;
h_hpl = plot(utc_time, HPL, 'r-', 'LineWidth', 1);
yline(16, '--', 'Color', [0.5 0.5 0.5], 'Label', 'HPE 95% limit (16 m)');
yline(40, ':', 'Color', [0.5 0.5 0.5], 'Label', 'HAL (40 m)', 'LineWidth', 1.5);
xlabel('Time (UTC)'); ylabel('Horizontal (m)');
title('Horizontal Position Error (HPE) and Protection Level (HPL)');
legend([h_hpe, h_hpl], {'HPE', 'HPL'}, 'Location', 'northwest');
grid on; xlim([utc_time(1), utc_time(end)]);
datetick('x', 'HH:MM:SS', 'keeplimits');


%% Gráfico 2: VPE e VPL ao longo do tempo

fig_vpe = figure('Name', 'VPE and VPL', ...
    'Units', 'normalized', 'Position', [0.05, 0.3, 0.9, 0.5], ...
    'NumberTitle', 'off');
h_vpe = plot(utc_time, VPE, 'b-', 'LineWidth', 1); hold on;
h_vpl = plot(utc_time, VPL, 'r-', 'LineWidth', 1);
% Limites de exatidão (accuracy) - VPE 95% (a tracejado verde)
yline(20, '--', 'Color', [0 0.6 0], 'LineWidth', 1);
yline(8,  '--', 'Color', [0 0.6 0], 'LineWidth', 1);
yline(5,  '--', 'Color', [0 0.6 0], 'LineWidth', 1);
% Limites de integridade VAL (a ponteado vermelho)
yline(50, ':', 'Color', [0.8 0 0], 'LineWidth', 1.5);
yline(20, ':', 'Color', [0.8 0 0], 'LineWidth', 1.5);
yline(12, ':', 'Color', [0.8 0 0], 'LineWidth', 1.5);
% Etiquetas colocadas à direita para evitar sobreposição
xl = xlim();
text_x = xl(2) + 0.02 * (xl(2) - xl(1));
text(text_x, 20, 'Acc VPE APV-I', 'Color', [0 0.6 0], 'FontSize', 8);
text(text_x, 8,  'Acc VPE APV-II', 'Color', [0 0.6 0], 'FontSize', 8);
text(text_x, 5,  'Acc VPE CAT-I', 'Color', [0 0.6 0], 'FontSize', 8);
text(text_x, 50, 'VAL APV-I', 'Color', [0.8 0 0], 'FontSize', 8);
text(text_x, 20, 'VAL APV-II', 'Color', [0.8 0 0], 'FontSize', 8);
text(text_x, 12, 'VAL CAT-I', 'Color', [0.8 0 0], 'FontSize', 8);
% Aumentar margem direita para acomodar etiquetas
xlim([xl(1), xl(2) + 0.12 * (xl(2) - xl(1))]);
xlabel('Time (UTC)'); ylabel('Vertical (m)');
title('Vertical Position Error (VPE) and Protection Level (VPL)');
legend([h_vpe, h_vpl], {'VPE', 'VPL'}, 'Location', 'northwest');
grid on; xlim([utc_time(1), utc_time(end)]);
datetick('x', 'HH:MM:SS', 'keeplimits');


%% Gráfico 3: Satélites disponíveis vs usados

fig_sat = figure('Name', 'Satellites Lock vs Used', ...
    'Units', 'normalized', 'Position', [0.05, 0.3, 0.9, 0.5], ...
    'NumberTitle', 'off');
stairs(utc_time, nsat_lock, 'b-', 'LineWidth', 1); hold on;
stairs(utc_time, nsat_used, 'r-', 'LineWidth', 1);
xlabel('Time (UTC)'); ylabel('NSV');
title('Satellites: Available (LOCK) vs Used in EGNOS Solution');
legend('NSV_{LOCK}', 'NSV_{USED}', 'Location', 'southeast');
grid on; xlim([utc_time(1), utc_time(end)]);
ylim([min([nsat_lock; nsat_used])-1, max([nsat_lock; nsat_used])+1]);
datetick('x', 'HH:MM:SS', 'keeplimits');


%% Gráfico 4: Eventos de integridade

fig_int = figure('Name', 'Integrity Events', ...
    'Units', 'normalized', 'Position', [0.05, 0.3, 0.9, 0.5], ...
    'NumberTitle', 'off');
plot(utc_time, HPE - HPL, 'b-', 'LineWidth', 1); hold on;
plot(utc_time, VPE - VPL, 'r-', 'LineWidth', 1);
yline(0, '--k', 'Limiar');
xlabel('Time (UTC)'); ylabel('Erro - Proteção (m)');
title('Integrity Events (positive = protection exceeded)');
legend('HPE - HPL', 'VPE - VPL', 'Location', 'northwest');
grid on; xlim([utc_time(1), utc_time(end)]);
datetick('x', 'HH:MM:SS', 'keeplimits');


%% Guardar figuras como PNG
exportgraphics(fig_hpe, 'gnss_hpe_hpl.png', 'Resolution', 300);
exportgraphics(fig_vpe, 'gnss_vpe_vpl.png', 'Resolution', 300);
exportgraphics(fig_sat, 'gnss_satelites.png', 'Resolution', 300);
exportgraphics(fig_int, 'gnss_integridade.png', 'Resolution', 300);


%% Função auxiliar: WGS84 → ECEF
function cart = wgs842ecef(lat, lon, alt, a, e2)
    phi = deg2rad(lat);
    lam = deg2rad(lon);
    N = a / sqrt(1 - e2 * sin(phi)^2);
    X = (N + alt) * cos(phi) * cos(lam);
    Y = (N + alt) * cos(phi) * sin(lam);
    Z = (N * (1 - e2) + alt) * sin(phi);
    cart = [X, Y, Z];
end
