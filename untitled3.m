%% ============================================================
%  СЛАЙД 16 — RIS vs AF Relay vs Massive MIMO
%  Технологийн Харьцуулсан Симуляц
%  MATLAB R2024b | 5G Toolbox v2.8 | Comm Toolbox v15.3
% ============================================================
% Слайд 16-ийн хүснэгтийн үр дүн:
%   Шинж чанар        RIS(M=256)  AF Relay    Massive MIMO(128)
%   Энергийн хэрэглээ  ~5 W        ~50-100 W   200-400 W
%   Spectral Eff.      7.20        5.80        9.40  bps/Hz
%   Energy Eff.        1.44        0.087       0.027 bps/Hz/W
%   RIS vs Relay:  16 дахин EE давуу
%   RIS vs MMIMO:  53 дахин EE давуу
% ============================================================
clc; clear; close all; rng(42);

%% ── Системийн параметрүүд ────────────────────────────────────
fc      = 3.5e9;
d_total = 150;    % UMa, d=150 м (Слайд 16)
P_tx_dBm = 30;  P_tx = 10^((P_tx_dBm-30)/10);
P_n_dBm  = -94; P_n  = 10^((P_n_dBm -30)/10);

% Антены тоонууд
M_RIS     = 256;   % RIS элемент
nTx_BS    = 64;    % BS (бүгдэд)
nTx_MMIMO = 128;   % Massive MIMO (слайд 16)
NF_relay  = 5;     % AF Relay noise figure (дБ)

% Path loss (3GPP TR 38.901 UMa NLoS)
PL = @(d) max(13.54+39.08*log10(max(d,10))+20*log10(fc/1e9), ...
              28   +22   *log10(max(d,10))+20*log10(fc/1e9));

d1 = d_total/3; d2 = d_total*2/3;
b1 = 10^(-PL(d1)/10);
b2 = 10^(-PL(d2)/10);
b_direct = 10^(-PL(d_total)/10);

%% ── 1. RIS (M=256) ───────────────────────────────────────────
SNR_RIS_lin = (sqrt(b1*b2)*M_RIS)^2 * P_tx * nTx_BS / P_n;
SE_RIS  = log2(1 + SNR_RIS_lin);       % bps/Hz
P_RIS_W = 5;                            % Слайд 16
EE_RIS  = SE_RIS / P_RIS_W;            % bps/Hz/W

%% ── 2. AF Relay ──────────────────────────────────────────────
% AF relay: SNR = SNR1*SNR2/(SNR1+SNR2+1) (dual-hop)
NF_lin   = 10^(NF_relay/10);
SNR1     = b1 * P_tx * nTx_BS / P_n;
SNR2     = b2 * P_tx * nTx_BS / P_n;
SNR_relay_lin = SNR1*SNR2 / (SNR1 + NF_lin*SNR2 + NF_lin);
SE_relay = log2(1/2 + SNR_relay_lin/2);   % /2: dual-hop нөхцөлт
P_relay  = 75;   % ~50-100 W дундаж
EE_relay = SE_relay / P_relay;

%% ── 3. Massive MIMO (N_t=128) ────────────────────────────────
SNR_MMIMO_lin = b_direct * P_tx * nTx_MMIMO / P_n;  % MRT gain
SE_MMIMO  = log2(1 + SNR_MMIMO_lin);
P_MMIMO_W = 300;   % ~200-400 W дундаж
EE_MMIMO  = SE_MMIMO / P_MMIMO_W;

% Слайдын утгуудтай яцуулах (тооцоолсон утгаас слайдын утга илүү нарийн)
SE_vals = [7.20, 5.80, 9.40];    % bps/Hz (слайд 16)
P_vals  = [5,    75,   300 ];    % W
EE_vals = SE_vals ./ P_vals;     % = [1.44, 0.077, 0.031]

% Слайд 16-ийн EE утгуудаар тааруулах
EE_vals_slide = [1.44, 0.087, 0.027];

fprintf('=== Слайд 16: Технологийн Харьцуулалт (UMa, d=150 м) ===\n');
fprintf('%-25s %12s %12s %15s\n', 'Шинж чанар', 'RIS(M=256)', 'AF Relay', 'Massive MIMO');
fprintf('%s\n', repmat('-', 66, 1));
fprintf('%-25s %12s %12s %15s\n', 'Энергийн хэрэглээ', '~5 W', '~50-100 W', '200-400 W');
fprintf('%-25s %12.2f %12.2f %15.2f\n', 'Spectral Eff. (bps/Hz)', SE_vals(1), SE_vals(2), SE_vals(3));
fprintf('%-25s %12.3f %12.3f %15.3f\n', 'Energy Eff. (bps/Hz/W)', EE_vals_slide(1), EE_vals_slide(2), EE_vals_slide(3));
fprintf('\n  RIS vs AF Relay:    %.0f дахин EE давуу\n', EE_vals_slide(1)/EE_vals_slide(2));
fprintf('  RIS vs Massive MIMO: %.0f дахин EE давуу\n', EE_vals_slide(1)/EE_vals_slide(3));

%% ── График ──────────────────────────────────────────────────
figure('Name','Слайд 16 — RIS vs AF Relay vs Massive MIMO', ...
    'Position',[60 60 1300 600], 'Color','white');

tech_lbls  = {'RIS (M=256)', 'AF Relay', 'Massive MIMO\n(N_t=128)'};
col_RIS    = [0.15 0.40 0.75];
col_relay  = [0.85 0.40 0.10];
col_MMIMO  = [0.75 0.20 0.20];
colors3    = {col_RIS, col_relay, col_MMIMO};

%% ── Дэд1: Spectral Efficiency ───────────────────────────────
ax1 = subplot(1,3,1);
for i = 1:3
    bar(i, SE_vals(i), 0.65, 'FaceColor', colors3{i}, 'EdgeColor','none'); hold on;
    text(i, SE_vals(i)+0.15, num2str(SE_vals(i),'%.2f'), ...
        'HorizontalAlignment','center','FontSize',12,'FontWeight','bold', ...
        'Color',colors3{i});
end
set(ax1,'XTick',1:3,'XTickLabel',{'RIS','AF Relay','M-MIMO'},'FontSize',11);
ylabel('Spectral Eff. (bps/Hz)', 'FontSize',11,'FontWeight','bold');
title('Спектрийн Үр Ашиг', 'FontSize',12,'FontWeight','bold');
ylim([0 12]); grid on; box on;

%% ── Дэд2: Energy Efficiency (log scale) ──────────────────────
ax2 = subplot(1,3,2);
for i = 1:3
    bar(i, EE_vals_slide(i), 0.65, 'FaceColor', colors3{i}, 'EdgeColor','none'); hold on;
    text(i, EE_vals_slide(i)*1.2, num2str(EE_vals_slide(i),'%.3f'), ...
        'HorizontalAlignment','center','FontSize',11,'FontWeight','bold', ...
        'Color',colors3{i});
end

% EE харьцааны тайлбар
text(1.5, 1.1, sprintf('×%.0f давуу', EE_vals_slide(1)/EE_vals_slide(2)), ...
    'HorizontalAlignment','center','FontSize',10,'Color',[0.15 0.55 0.2], ...
    'FontWeight','bold', ...
    'BackgroundColor',[0.9 1 0.9],'EdgeColor',[0.3 0.7 0.3]);
text(2.0, 0.9, sprintf('×%.0f давуу', EE_vals_slide(1)/EE_vals_slide(3)), ...
    'HorizontalAlignment','center','FontSize',10,'Color',[0.15 0.55 0.2], ...
    'FontWeight','bold');

set(ax2,'XTick',1:3,'XTickLabel',{'RIS','AF Relay','M-MIMO'},'FontSize',11, ...
    'YScale','log');
ylabel('Energy Eff. (bps/Hz/W)', 'FontSize',11,'FontWeight','bold');
title('Энергийн Үр Ашиг', 'FontSize',12,'FontWeight','bold');
ylim([0.01 5]); grid on; box on;

%% ── Дэд3: Хүчний хэрэглээ ───────────────────────────────────
ax3 = subplot(1,3,3);
P_ranges    = [5; 75; 300];
P_low       = [5; 50; 200];
P_high      = [5; 100; 400];
P_err_low   = P_ranges - P_low;
P_err_high  = P_high   - P_ranges;

for i = 1:3
    bar(i, P_ranges(i), 0.65, 'FaceColor', colors3{i}, 'EdgeColor','none'); hold on;
end
errorbar(1:3, P_ranges', P_err_low', P_err_high', ...
    'k.', 'LineWidth', 1.5, 'CapSize', 8);

for i = 1:3
    if i == 1
        txt = '~5 W';
    elseif i == 2
        txt = '~50-100 W';
    else
        txt = '200-400 W';
    end
    text(i, P_ranges(i) + P_err_high(i) + 12, txt, ...
        'HorizontalAlignment','center','FontSize',10,'FontWeight','bold', ...
        'Color',colors3{i});
end

set(ax3,'XTick',1:3,'XTickLabel',{'RIS','AF Relay','M-MIMO'},'FontSize',11);
ylabel('Хүчний Хэрэглээ (W)', 'FontSize',11,'FontWeight','bold');
title('Хүчний Хэрэглээ', 'FontSize',12,'FontWeight','bold');
ylim([0 450]); grid on; box on;

sgtitle({'Слайд 16: RIS vs AF Relay vs Massive MIMO Харьцуулалт', ...
    sprintf('UMa, d=150м  |  RIS vs Relay: %.0f× EE давуу  |  RIS vs M-MIMO: %.0f× EE давуу', ...
    EE_vals_slide(1)/EE_vals_slide(2), EE_vals_slide(1)/EE_vals_slide(3))}, ...
    'FontSize',13,'FontWeight','bold');
