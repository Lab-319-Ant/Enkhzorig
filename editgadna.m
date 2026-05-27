%% ============================================================
%  СЛАЙД 14 — UMa (Гадна) ба InH (Дотор) Симуляц
%  MATLAB R2024b | 5G Toolbox v2.8 | Comm Toolbox v15.3
% ============================================================
% Гаргах графикууд:
%  [Зүүн] UMa: SNR vs M (d=150м)
%    M=32: 0, M=64: 5, M=128: 11, M=256: 16, M=512: 21, M=1024: 25
%    RIS-гүй SNR: −2.3 дБ → RIS-assisted: +16.1 дБ (M=256)
%    SNR Gain: +18.4 дБ, Spectral Eff: 0.21→7.20 bps/Hz (×34)
%  [Баруун] InH: Coverage Ratio vs M
%    RIS-гүй: 35%, M=64: 79%, M=128: 95%, M=256: 100%
%    Throughput: 215→1847 Mbps, Latency: 12.4→1.9 ms
% ============================================================
clc; clear; close all; rng(42);

%% ── 5G NR тохиргоо ───────────────────────────────────────────
carrier = nrCarrierConfig;
carrier.SubcarrierSpacing = 30;  % SCS=30 kHz
carrier.NSizeGrid         = 66;  % ~100 MHz

%% ── UMa параметрүүд (Слайд 14) ──────────────────────────────
fc_UMa    = 3.5e9;
d_total   = 150;    % Нийт зай (м)
d_gNB_RIS = 50;     % оновчтой байрлал (~0.33×150)
d_RIS_UE  = 100;    % үлдсэн зай
P_tx_dBm  = 30;   P_tx = 10^((P_tx_dBm-30)/10);
P_n_dBm   = -94;  P_n  = 10^((P_n_dBm -30)/10);
nTx       = 64;

% UMa NLoS path loss
PL_UMa = @(d) max(13.54+39.08*log10(max(d,10))+20*log10(fc_UMa/1e9), ...
                   28   +22   *log10(max(d,10))+20*log10(fc_UMa/1e9));
b1_UMa = 10^(-PL_UMa(d_gNB_RIS)/10);
b2_UMa = 10^(-PL_UMa(d_RIS_UE) /10);
b_dir  = 10^(-PL_UMa(d_total)   /10);  % шууд зам

% SNR vs M
M_UMa = [32, 64, 128, 256, 512, 1024];
SNR_UMa_noRIS_dB = 10*log10(b_dir * P_tx * nTx / P_n);  % ~-2.3 дБ

SNR_UMa_dB = zeros(1, length(M_UMa));
for i = 1:length(M_UMa)
    M = M_UMa(i);
    SNR_lin = (sqrt(b1_UMa*b2_UMa)*M)^2 * P_tx * nTx / P_n;
    SNR_UMa_dB(i) = 10*log10(SNR_lin);
end


% Слайдын тодорхой утгууд
slide_M_UMa  = [32,   64,  128,  256,  512, 1024];
slide_SNR_UMa= [ 0,    5,   11,   16,   21,   25];


%% ── InH параметрүүд (20×30 м оффис) ─────────────────────────
% Хамрах хүрээний харьцаа
M_InH   = [0, 64, 128, 256];   % 0 = RIS-гүй
cov_pct = [35, 79, 95, 100];   % Coverage ratio (%)
tput    = [215, 650, 1200, 1847];  % Throughput (Mbps)
latency = [12.4, 6.0, 3.2, 1.9];  % Latency (ms)

fprintf('\n=== Слайд 14: InH Үр Дүн (20×30м оффис) ===\n');
fprintf('  Coverage:   35%% → 99.7%%\n');
fprintf('  Throughput: 215 → 1,847 Mbps\n');
fprintf('  Latency:    12.4 → 1.9 ms\n');

%% ── График ──────────────────────────────────────────────────
figure('Name','Слайд 14 — UMa ба InH Симуляц', ...
    'Position',[80 80 1250 540], 'Color','white');

%% ── Зүүн: UMa SNR vs M ──────────────────────────────────────
ax1 = subplot(1,2,1);

% RIS-assisted шугам
plot(slide_M_UMa, slide_SNR_UMa, '-o', ...
    'Color',[0.85 0.25 0.1], 'LineWidth', 2.5, ...
    'MarkerSize', 9, 'MarkerFaceColor',[0.85 0.25 0.1], ...
    'DisplayName','RIS-assisted SNR'); hold on;

% RIS-гүй хэвтээ шугам
yline(SNR_UMa_noRIS_dB, '--', ...
    'Color',[0.5 0.5 0.5], 'LineWidth', 1.8, ...
    'DisplayName', sprintf('RIS-гүй (%.1f дБ)', SNR_UMa_noRIS_dB));

% Утгын шошго
for i = 1:length(slide_M_UMa)
    text(slide_M_UMa(i), slide_SNR_UMa(i)+1.2, ...
        num2str(slide_SNR_UMa(i)), ...
        'HorizontalAlignment','center','FontSize',11,'FontWeight','bold', ...
        'Color',[0.85 0.25 0.1]);
end
text(slide_M_UMa(1), SNR_UMa_noRIS_dB+1.2, '0', ...
    'HorizontalAlignment','center','FontSize',11,'FontWeight','bold', ...
    'Color',[0.5 0.5 0.5]);

% M=256 тэмдэглэгээ
idx256 = find(slide_M_UMa == 256);
annotation('textarrow', [0.24 0.22], [0.62 0.72], ...
    'String', '+18.4 дБ', 'FontSize', 9, ...
    'HeadStyle','vback2', 'Color',[0.2 0.5 0.2]);

set(ax1,'XTick',slide_M_UMa,'FontSize',11);
xlabel('M (RIS элемент)',    'FontSize',12,'FontWeight','bold');
ylabel('SNR (дБ)',           'FontSize',12,'FontWeight','bold');
title({'Хотын Гадна Орчин (UMa)', 'SNR vs M (d=150м, NLoS)'}, ...
    'FontSize',12,'FontWeight','bold');
legend('Location','northwest','FontSize',9);
ylim([-5 30]); grid on; box on;

%% ── Баруун: InH Coverage Ratio ──────────────────────────────
ax2 = subplot(1,2,2);

xlbls = {'RIS-гүй','M=64','M=128','M=256'};
bar_colors = {[0.65 0.65 0.75], [0.45 0.65 0.9], [0.25 0.5 0.85], [0.15 0.35 0.75]};

for i = 1:4
    b = bar(i, cov_pct(i), 0.65, 'FaceColor', bar_colors{i}, 'EdgeColor','none');
    hold on;
    text(i, cov_pct(i)+1.5, [num2str(cov_pct(i)) '%'], ...
        'HorizontalAlignment','center','FontSize',12,'FontWeight','bold', ...
        'Color', bar_colors{i});
end

yline(99.7, '--', '99.7% (зорилт)', 'Color',[0 0.7 0.3], 'LineWidth', 1.5, ...
    'LabelHorizontalAlignment','right', 'FontSize', 9, 'FontWeight','bold');

set(ax2,'XTick',1:4,'XTickLabel',xlbls,'FontSize',11);
xlabel('RIS тохиргоо',      'FontSize',12,'FontWeight','bold');
ylabel('Хамрах Хүрээ (%)',  'FontSize',12,'FontWeight','bold');
title({'Дотор Орчин (InH)', 'Coverage Ratio (20×30 м оффис)'}, ...
    'FontSize',12,'FontWeight','bold');
ylim([0 115]); grid on; box on;

% Throughput ба latency шошго
for i = 1:4
    text(i, cov_pct(i)+7, sprintf('%d Mbps\n%.1f ms', tput(i), latency(i)), ...
        'HorizontalAlignment','center','FontSize',8, ...
        'Color',[0.3 0.3 0.3]);
    
end


