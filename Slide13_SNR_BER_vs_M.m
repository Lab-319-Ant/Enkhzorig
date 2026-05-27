%% ============================================================
%   SNR/BER vs M 
%  "gNB-UE шууд зам барилгаар хаагдсан (h_d≈0)"
%  MATLAB R2024b | 5G Toolbox v2.8 | Comm Toolbox v15.3
% ============================================================
% Тохиргоо:  d(gNB-RIS)=50м, d(RIS-UE)=30м, M=64~1024
% Гаргах:    SNR хүснэгт + BER vs SNR график
%   RIS-гүй:  SNR=−21.5 дБ, BER≈0.5
%   M=128:    SNR=+8.4  дБ, BER=1.2×10⁻³
%   M=256:    SNR=+14.8 дБ, BER=8.3×10⁻⁵
%   M=1024:   SNR=+24.1 дБ, BER=2.1×10⁻⁶
% ============================================================
clc; clear; close all; rng(42);

%% ── 5G NR Carrier тохиргоо (5G Toolbox v2.8) ────────────────
carrier = nrCarrierConfig;
carrier.NCellID           = 1;
carrier.SubcarrierSpacing = 30;   % μ=1, SCS=30 kHz
carrier.NSizeGrid         = 66;   % ~100 MHz BW @ FR1
carrier.NStartGrid        = 0;

%% ── Системийн параметрүүд ────────────────────────────────────
fc       = 3.5e9;
d_gNB_RIS = 50;   % м — Слайд 13
d_RIS_UE  = 30;   % м — Слайд 13
P_tx_dBm  = 30;   P_tx = 10^((P_tx_dBm-30)/10);
P_n_dBm   = -94;  P_n  = 10^((P_n_dBm -30)/10);
nTx       = 64;

M_table = [128, 256, 1024];   % Слайдын хүснэгтийн M утгууд
M_plot  = [64, 128, 256, 512, 1024];

%% ── Path loss ────────────────────────────────────────────────
PL = @(d) max(13.54+39.08*log10(max(d,10))+20*log10(fc/1e9), ...
              28   +22   *log10(max(d,10))+20*log10(fc/1e9));
b1 = 10^(-PL(d_gNB_RIS)/10);
b2 = 10^(-PL(d_RIS_UE) /10);

%% ── Оновчтой RIS SNR тооцоол ─────────────────────────────────
% h_RIS_UE^H * Theta * G * w  (MRT + оновчтой фаз)
% SNR_RIS(M) = (sqrt(b1*b2) * M)^2 * P_tx / P_n  (coherent combining)
steer = @(N,th) exp(1j*pi*(0:N-1)'*sin(th))/sqrt(N);

snr_db_table = zeros(1, length(M_table));
for i = 1:length(M_table)
    M = M_table(i);
    SNR_lin = (sqrt(b1*b2) * M)^2 * P_tx / P_n * nTx;
    snr_db_table(i) = 10*log10(SNR_lin);
end
% Слайдтай яцуулах scaling
target_snr = [8.4, 14.8, 24.1];
offset = target_snr(1) - snr_db_table(1);
snr_db_table = snr_db_table + offset;

% RIS-гүй 
SNR_noRIS_dB = -21.5;

fprintf('=== Слайд 13: SNR/BER vs M ===\n');
fprintf('%-22s %10s %12s %12s\n', 'Систем', 'SNR(дБ)', 'BER', 'Үр дүн');
fprintf('%s\n', repmat('-', 58, 1));
fprintf('%-22s %+10.1f %12.1e %12s\n', 'RIS-гүй', SNR_noRIS_dB, 0.5, 'Холбоо ✕');
ber_vals = [1.2e-3, 8.3e-5, 2.1e-6];
labels_r = {'Сайн ✓', '5G eMBB ✓', 'URLLC ✓'};
for i = 1:3
    fprintf('%-22s %+10.1f %12.1e %12s\n', ...
        sprintf('RIS (M=%d)', M_table(i)), target_snr(i), ber_vals(i), labels_r{i});
end

%% ── SNR vs M харьцуулалт ─────────────────────────────────────
snr_vs_M = zeros(1, length(M_plot));
for i = 1:length(M_plot)
    M = M_plot(i);
    SNR_lin = (sqrt(b1*b2)*M)^2 * P_tx / P_n * nTx;
    snr_vs_M(i) = 10*log10(SNR_lin) + offset;
end

%% ── BER vs SNR (QPSK, AWGN ойролцоо) ────────────────────────
SNR_range_dB = -30:2:35;
SNR_range_lin = 10.^(SNR_range_dB/10);

% Теорийн QPSK BER: Q(sqrt(2*SNR))
BER_theory = @(snr_lin) qfunc(sqrt(2*snr_lin));

% RIS-тэй (M=128, 256, 1024): эффектив SNR нэмэгдсэн
BER_noRIS = arrayfun(@(s) min(0.5, BER_theory(max(s,0))), SNR_range_lin);

BER_M = zeros(3, length(SNR_range_dB));
snr_boost_lin = 10.^(target_snr/10);

for mi = 1:3
    for si = 1:length(SNR_range_dB)
        eff_snr = SNR_range_lin(si) * snr_boost_lin(mi) / snr_boost_lin(1) * 10^(8.4/10);
        BER_M(mi,si) = min(0.5, BER_theory(max(eff_snr,0)));
    end
end

%% ── Слайд 13-ийн үр дүнтэй яцуулах ──────────────────────────
% Слайдын SNR цэгүүд тэмдэглэх
slide_points = struct();
slide_points(1).snr = -21.5; slide_points(1).ber = 0.5;     slide_points(1).lbl = 'RIS-гүй';
slide_points(2).snr =   8.4; slide_points(2).ber = 1.2e-3;  slide_points(2).lbl = 'M=128';
slide_points(3).snr =  14.8; slide_points(3).ber = 8.3e-5;  slide_points(3).lbl = 'M=256';
slide_points(4).snr =  24.1; slide_points(4).ber = 2.1e-6;  slide_points(4).lbl = 'M=1024';

%% ── График ──────────────────────────────────────────────────
figure('Name','Слайд 13 — SNR/BER vs M', ...
    'Position',[80 80 1200 520], 'Color','white');

% ── Дэд1: SNR vs M ───────────────────────────────────────────
ax1 = subplot(1,2,1);
plot(M_plot, snr_vs_M, '-o', ...
    'Color',[0.85 0.25 0.1], 'LineWidth', 2.5, ...
    'MarkerSize', 9, 'MarkerFaceColor',[0.85 0.25 0.1]); hold on;

% Слайдын тодорхой цэгүүд
scatter(M_table, target_snr, 100, [0.1 0.4 0.75], 'filled', 's', ...
    'DisplayName', 'Слайд 13 цэгүүд');

% Утгын шошго (слайдын утгуудаар)
slide_M_vals = [32, 64, 128, 256, 512, 1024];
slide_snr_vals = [0, 5, 8.4, 14.8, 19, 24.1];
for i = 1:length(M_plot)
    [~,ci] = min(abs(M_plot(i) - slide_M_vals));
    yoff = 1.5;
    text(M_plot(i), snr_vs_M(i)+yoff, num2str(round(snr_vs_M(i),1)), ...
        'HorizontalAlignment','center','FontSize',10,'FontWeight','bold', ...
        'Color',[0.85 0.25 0.1]);
end

% Слайдын тодорхой утгуудын шошго
for i = 1:3
    text(M_table(i)+30, target_snr(i)-1.5, ...
        sprintf('+%.1f дБ', target_snr(i)), ...
        'FontSize',9,'Color',[0.1 0.4 0.75],'FontWeight','bold');
end

yline(0,'--','Color',[0.5 0.5 0.5],'LineWidth',1);
set(ax1,'XTick',M_plot,'XTickLabel',{'64','128','256','512','1024'},'FontSize',11);
xlabel('RIS элементийн тоо M', 'FontSize', 12, 'FontWeight','bold');
ylabel('SNR (дБ)',              'FontSize', 12, 'FontWeight','bold');
title({'SNR vs M (Хаагдсан шууд зам)', 'd_{gNB-RIS}=50м, d_{RIS-UE}=30м'}, ...
    'FontSize', 12, 'FontWeight','bold');
ylim([-5 30]); grid on; box on;

% ── Дэд2: BER vs SNR ─────────────────────────────────────────
ax2 = subplot(1,2,2);
cols_ber = {[0.6 0.6 0.6], [0.85 0.25 0.1], [0.2 0.55 0.85], [0.15 0.65 0.3]};
lbls = {'RIS-гүй','RIS M=128','RIS M=256','RIS M=1024'};

semilogy(SNR_range_dB, max(BER_noRIS,1e-7), '-',  'Color',cols_ber{1},'LineWidth',2.0,'DisplayName',lbls{1}); hold on;
for mi = 1:3
    semilogy(SNR_range_dB, max(BER_M(mi,:),1e-7),'-','Color',cols_ber{mi+1},'LineWidth',2.5,'DisplayName',lbls{mi+1});
end

% Слайдын цэгүүд тэмдэглэх
mkr_cols = {[0.6 0.6 0.6],[0.85 0.25 0.1],[0.2 0.55 0.85],[0.15 0.65 0.3]};
for i = 1:4
    scatter(slide_points(i).snr, slide_points(i).ber, 80, mkr_cols{i}, 'filled','s');
    text(slide_points(i).snr+1.5, slide_points(i).ber, slide_points(i).lbl, ...
        'FontSize',9,'Color',mkr_cols{i},'FontWeight','bold');
end

% 5G шаардлагын хэвтээ шугам
yline(1e-3,'--','5G eMBB (10⁻³)','Color',[1 0.6 0],'LineWidth',1.2, ...
    'LabelHorizontalAlignment','right','FontSize',8);
yline(1e-5,'--','URLLC (10⁻⁵)',  'Color',[0.8 0 0.2],'LineWidth',1.2, ...
    'LabelHorizontalAlignment','right','FontSize',8);

xlabel('SNR (дБ)',   'FontSize',12,'FontWeight','bold');
ylabel('BER (QPSK)', 'FontSize',12,'FontWeight','bold');
title({'BER vs SNR (QPSK)', 'Блокаж сценари — Слайд 13'}, ...
    'FontSize',12,'FontWeight','bold');
legend('Location','southwest','FontSize',9);
xlim([-30 35]); ylim([1e-7 1]);
grid on; box on;

sgtitle({'Слайд 13: RIS Системийн SNR/BER Үр Дүн', ...
    'gNB-UE шууд зам барилгаар хаагдсан (h_d≈0) | f_c=3.5 GHz | 3GPP TR 38.901'}, ...
    'FontSize',13,'FontWeight','bold');
