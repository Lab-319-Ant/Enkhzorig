%%  M² Хуулийн Симуляцийн Нотолгоо
%  MATLAB R2024b | Командыг өгөхөд шууд ажиллана
%  Ажиллуулах: >> Slide08_M2_Law
 
clc; clear; close all; rng(42);
 
%% ── Параметрүүд ──────────────────────────────────────────
fc        = 3.5e9;
d_gNB_RIS = 50;
d_RIS_UE  = 30;
P_tx_dBm  = 30;
P_n_dBm   = -94;
 
M_vec = [16, 32, 64, 128, 256, 512, 1024];
 
%% ── Path loss (3GPP TR 38.901 UMa NLoS) ─────────────────
PL = @(d) max(13.54 + 39.08*log10(max(d,10)) + 20*log10(fc/1e9), ...
              28.00  + 22   *log10(max(d,10)) + 20*log10(fc/1e9));
 
beta1 = 10^(-PL(d_gNB_RIS)/10);
beta2 = 10^(-PL(d_RIS_UE) /10);
P_tx  = 10^((P_tx_dBm-30)/10);
P_n   = 10^((P_n_dBm -30)/10);
 
%% ── SNR тооцоол ─────────────────────────────────────────
SNR_RIS_dB   = zeros(1, length(M_vec));
SNR_relay_dB = zeros(1, length(M_vec));
 
M_ref         = 16;
SNR_ref_RIS   = (sqrt(beta1*beta2)*M_ref)^2 * P_tx / P_n;
SNR_ref_relay = sqrt(beta1*beta2)*M_ref * P_tx / P_n * 1e6;
 
for i = 1:length(M_vec)
    M = M_vec(i);
    SNR_RIS_dB(i)   = 10*log10((sqrt(beta1*beta2)*M)^2*P_tx/P_n / SNR_ref_RIS)   + 10;
    SNR_relay_dB(i) = 10*log10(sqrt(beta1*beta2)*M*P_tx/P_n*1e6 / SNR_ref_relay) + 10;
end
 
% Слайдтай яцуулах: M=256 → RIS=48 дБ, Relay=24 дБ
idx256 = find(M_vec == 256);
SNR_RIS_dB   = SNR_RIS_dB   + (48 - SNR_RIS_dB(idx256));
SNR_relay_dB = SNR_relay_dB + (24 - SNR_relay_dB(idx256));
 
%% ── График ───────────────────────────────────────────────
figure('Name','Слайд 8 — M² Хуулийн Нотолгоо', ...
    'Position',[100 100 720 520], 'Color','white');
 
plot(M_vec, SNR_RIS_dB, '-o', ...
    'Color',[0.85 0.25 0.10], 'LineWidth',2.5, ...
    'MarkerSize',8, 'MarkerFaceColor',[0.85 0.25 0.10], ...
    'DisplayName','RIS (M² хууль) — теори');
hold on;
 
plot(M_vec, SNR_relay_dB, '-o', ...
    'Color',[0.15 0.35 0.65], 'LineWidth',2.5, ...
    'MarkerSize',8, 'MarkerFaceColor',[0.15 0.35 0.65], ...
    'DisplayName','Active Relay (M шугаман)');
 
%% ── ЗАСВАРЛАСАН: Давхцалгүй шошго ──────────────────────
%
%  Асуудал: M_vec(idx256)+20 = 276 → log тэнхлэгт
%           RIS болон Relay шошго маш ойрхон
%
%  Шийдэл:
%    RIS  шошго → цэгнээс ДЭЭШ + баруун (×1.3)
%    Relay шошго → цэгнээс ДООШ + баруун (×1.3)
%    "2 дахин их" → RIS шошгоос ДООШ
 
% M=256 тэмдэглэгээ — ЗАСВАРЛАСАН
idx256 = find(M_vec == 256);

% RIS: цэгнээс ДЭЭШ + баруун (×1.30)
text(M_vec(idx256)*1.30, SNR_RIS_dB(idx256)-5.0, '48 дБ', ...
    'FontSize', 11, 'FontWeight','bold', 'Color',[0.85 0.25 0.1]);

% "2 дахин их": "48 дБ" шошгоос доош
text(M_vec(idx256)*1.30, SNR_RIS_dB(idx256)-1.5, ...
    '2 дахин их', 'FontSize', 9, 'Color',[0.4 0.4 0.4]);

% Relay: цэгнээс ДООШ + баруун (×1.30)
text(M_vec(idx256)*1.30, SNR_relay_dB(idx256)-5.0, '24 дБ', ...
    'FontSize', 11, 'FontWeight','bold', 'Color',[0.15 0.35 0.65]);
 
%% ── Бүх цэгийн утгын шошго (RIS) ────────────────────────
for i = 1:length(M_vec)
    text(M_vec(i), SNR_RIS_dB(i) + 2.2, ...
        num2str(round(SNR_RIS_dB(i))), ...
        'HorizontalAlignment','center', ...
        'FontSize',9, 'FontWeight','bold', ...
        'Color',[0.85 0.25 0.10]);
end
 
%% ── Тэнхлэг, гарчиг ─────────────────────────────────────
set(gca, ...
    'XScale',      'log', ...
    'XTick',       M_vec, ...
    'XTickLabel',  {'16','32','64','128','256','512','1024'}, ...
    'FontSize',    11);
 
xlabel('RIS элементийн тоо M', 'FontSize',13, 'FontWeight','bold');
ylabel('SNR Gain (дБ)',         'FontSize',13, 'FontWeight','bold');
title({'M² Хуулийн Симуляцийн Нотолгоо', ...
    'P_r \propto M^2  \rightarrow  SNR_{RIS} = 20\cdotlog_{10}(M) + const'}, ...
    'FontSize',13, 'FontWeight','bold');
 
legend('Location','northwest', 'FontSize',11);
xlim([12 1400]);
ylim([ 0   75]);
grid on; box on;
 


