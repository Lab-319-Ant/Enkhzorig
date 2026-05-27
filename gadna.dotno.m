%% Слайд 14 — UMa & InH График
%  MATLAB R2024b | Командыг өгөхөд шууд ажиллана
 
clc; clear; close all; rng(42);
 
%% ── Параметрүүд ──────────────────────────────────────────
fc_UMa    = 3.5e9;
d_gNB_RIS = 50;
d_RIS_UE  = 100;
P_tx_dBm  = 30;   P_tx = 10^((P_tx_dBm-30)/10);
P_n_dBm   = -94;  P_n  = 10^((P_n_dBm-30)/10);
nTx       = 64;
 
PL_UMa = @(d) max(13.54+39.08*log10(max(d,10))+20*log10(fc_UMa/1e9), ...
                   28   +22   *log10(max(d,10))+20*log10(fc_UMa/1e9));
b_dir          = 10^(-PL_UMa(d_gNB_RIS+d_RIS_UE)/10);
SNR_noRIS_dB   = 10*log10(b_dir * P_tx * nTx / P_n);
 
%% ── Слайдын утгууд ───────────────────────────────────────
slide_M_UMa   = [32,  64, 128, 256, 512, 1024];
slide_SNR_UMa = [ 0,   5,  11,  16,  21,   25];
 
M_InH    = {'RIS-гүй','M=64','M=128','M=256'};
cov_pct  = [35, 79, 95, 100];
tput     = [215, 650, 1200, 1847];
latency  = [12.4, 6.0, 3.2, 1.9];
 
%% ── Figure ───────────────────────────────────────────────
figure('Name','Слайд 14', ...
    'Position',[80 80 1250 540], 'Color','white');
 
%% ══ ЗҮҮН: UMa SNR vs M ════════════════════════════════════
ax1 = subplot(1,2,1);
 
plot(slide_M_UMa, slide_SNR_UMa, '-o', ...
    'Color',[0.85 0.25 0.10], 'LineWidth',2.5, ...
    'MarkerSize',9, 'MarkerFaceColor',[0.85 0.25 0.10], ...
    'DisplayName','RIS-assisted SNR');
hold on;
 
yline(SNR_noRIS_dB, '--', ...
    'Color',[0.5 0.5 0.5], 'LineWidth',1.8, ...
    'DisplayName', sprintf('RIS-гүй (%.1f дБ)', SNR_noRIS_dB));
 
% Утгын шошго
for i = 1:length(slide_M_UMa)
    text(slide_M_UMa(i), slide_SNR_UMa(i)+1.5, ...
        num2str(slide_SNR_UMa(i)), ...
        'HorizontalAlignment','center', ...
        'FontSize',11, 'FontWeight','bold', ...
        'Color',[0.85 0.25 0.10]);
end
 
% +18.4 дБ тэмдэглэгээ
annotation('textarrow',[0.235 0.215],[0.60 0.70], ...
    'String','+18.4 дБ','FontSize',9, ...
    'HeadStyle','vback2','Color',[0.2 0.5 0.2]);
 
set(ax1, 'XTick', slide_M_UMa, ...
    'XTickLabel',{'32','64','128','256','512','1024'}, ...
    'FontSize',11, 'Box','off', 'YGrid','on', 'GridAlpha',0.4);
xlim([20 1200]); ylim([-5 30]); yticks(-5:5:30);
xlabel('M (RIS элемент)', 'FontSize',12, 'FontWeight','bold');
ylabel('SNR (дБ)',         'FontSize',12, 'FontWeight','bold');
title({'Хотын Гадна Орчин (UMa)','SNR vs M (d=150м, NLoS)'}, ...
    'FontSize',12, 'FontWeight','bold');
legend('Location','northwest','FontSize',9);
grid on; box on;
 
%% ══ БАРУУН: InH Coverage Ratio ════════════════════════════
ax2 = subplot(1,2,2);
 
bar_colors = {[0.65 0.65 0.75],[0.45 0.65 0.90], ...
              [0.25 0.50 0.85],[0.15 0.35 0.75]};
 
for i = 1:4
    bar(i, cov_pct(i), 0.65, ...
        'FaceColor', bar_colors{i}, 'EdgeColor','none');
    hold on;
 
    % % шошго — баганын ДЭЭР (хэвийн байршил)
    text(i, cov_pct(i)+1.8, [num2str(cov_pct(i)) '%'], ...
        'HorizontalAlignment','center', ...
        'FontSize',12, 'FontWeight','bold', ...
        'Color', bar_colors{i});
 
    % Throughput & latency — баганын ДОТОР, доод хэсэгт
    text(i, cov_pct(i)*0.38, ...
        sprintf('%d Mbps\n%.1f ms', tput(i), latency(i)), ...
        'HorizontalAlignment','center', ...
        'VerticalAlignment','middle', ...
        'FontSize',8, 'Color',[0.98 0.98 0.98], ...
        'FontWeight','bold');
end
 
yline(99.7,'--','Color',[0 0.7 0.3],'LineWidth',1.5, ...
    'Label','99.7% (зорилт)', ...
    'LabelHorizontalAlignment','right', ...
    'FontSize',9,'FontWeight','bold');
 
set(ax2,'XTick',1:4,'XTickLabel',M_InH,'FontSize',11);
xlabel('RIS тохиргоо',     'FontSize',12,'FontWeight','bold');
ylabel('Хамрах Хүрээ (%)', 'FontSize',12,'FontWeight','bold');
title({'Дотор Орчин (InH)','Coverage Ratio (20×30 м оффис)'}, ...
    'FontSize',12,'FontWeight','bold');
ylim([0 115]); grid on; box on;
 
sgtitle('5. Симуляцийн үр дүн  —  Слайд 14', ...
    'FontSize',14,'FontWeight','bold','Color',[0.08 0.20 0.50]);