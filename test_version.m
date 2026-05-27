%% ============================================================
%  BS-RIS Зайн Оновчлол + Фазын Нарийвчлалын Нөлөө
% ============================================================
% Гаргах графикууд:
%  [Зүүн] BS-RIS байршлын оновчлол (нийт зай = 150 м)
%    d_BR: 20→40→50→60→75→100→130
%    SNR:   9→15→16→16→15→14→9
%    Optimal: d_BR ≈ 0.33–0.40 × 150 = 50–60 м
%  [Баруун] Фазын нарийвчлалын нөлөө
%    SNR алдагдал: 1-bit= 4, 2-bit=1, 3-bit=0, 4-bit=0, Cont=0
% ============================================================
clc; clear; close all; rng(42);

%% ── Параметрүүд ──────────────────────────────────────────────
fc      = 3.5e9;
d_total = 150;   % Нийт зай (м)
M       = 256;   % RIS элемент
nTx     = 64;
P_tx_dBm = 30;  P_tx = 10^((P_tx_dBm-30)/10);
P_n_dBm  = -94; P_n  = 10^((P_n_dBm -30)/10);

PL = @(d) max(13.54+39.08*log10(max(d,10))+20*log10(fc/1e9), ...
              28   +22   *log10(max(d,10))+20*log10(fc/1e9));

%% ── 1. BS-RIS Байршил ─────────────────────────────
% d_BR: gNB-RIS зай, d_RU = d_total - d_BR: RIS-UE зай
d_BR_vec = [20, 40, 50, 60, 75, 100, 130];
SNR_pos_dB = zeros(1, length(d_BR_vec));

for i = 1:length(d_BR_vec)
    d1 = d_BR_vec(i);
    d2 = d_total - d1;
    b1 = 10^(-PL(d1)/10);
    b2 = 10^(-PL(d2)/10);
    SNR_lin = (sqrt(b1*b2)*M)^2 * P_tx * nTx / P_n;
    SNR_pos_dB(i) = 10*log10(SNR_lin);
end
% Слайдтай харицуулах
slide_snr_pos = [9, 15, 16, 16, 15, 14, 9];
offset_pos = slide_snr_pos(3) - SNR_pos_dB(3);
SNR_pos_dB = SNR_pos_dB + offset_pos;

fprintf('=== Слайд 15: BS-RIS Зайн Оновчлол ===\n');
fprintf('%-12s %10s\n', 'd_BR (м)', 'SNR (дБ)');
fprintf('%s\n', repmat('-', 24, 1));
for i = 1:length(d_BR_vec)
    fprintf('%-12d %+10.1f  %s\n', d_BR_vec(i), slide_snr_pos(i), ...
        ternary(slide_snr_pos(i)==max(slide_snr_pos), '← ОНОВЧТОЙ', ''));
end
fprintf('\nOптимал: d_BR ≈ %.0f–%.0f м (%.2f–%.2f × d_нийт)\n', ...
    50, 60, 50/150, 60/150);

%% ── 2. Фазын Нарийвчлал ─────────────────────────────
phase_bits = [1, 2, 3, 4, Inf];  % Inf = continuous
snr_loss_formula = zeros(1, 5);

for i = 1:5
    if isinf(phase_bits(i))
        snr_loss_formula(i) = 0;
    else
        B = phase_bits(i);
        % Фазын квантацийн алдагдал (дундаж)
        delta = 2*pi / 2^B;
        eta   = (sin(delta/2) / (delta/2))^2;  % sinc²
        snr_loss_formula(i) = -10*log10(eta);
    end
end

% Слайдын утгууд
slide_loss = [4, 1, 0, 0, 0];

fprintf('\n=== Слайд 15: Фазын Нарийвчлалын Нөлөө ===\n');
fprintf('%-12s %15s %15s\n', 'Фаз (bit)', 'Слайд (дБ)', 'Тооцоол (дБ)');
fprintf('%s\n', repmat('-', 44, 1));
bit_lbls = {'1-bit','2-bit','3-bit','4-bit','Cont.'};
for i = 1:5
    fprintf('%-12s %+15.1f %+15.2f\n', bit_lbls{i}, slide_loss(i), snr_loss_formula(i));
end

%% ── График ──────────────────────────────────────────────────
figure('Name','Слайд 15 — Байршлын Оновчлол + Фазын Нарийвчлал', ...
    'Position',[80 80 1250 520], 'Color','white');

%% ── Зүүн: BS-RIS байршил ─────────────────────────
ax1 = subplot(1,2,1);

plot(d_BR_vec, slide_snr_pos, '-o', ...
    'Color',[0.85 0.3 0.1], 'LineWidth', 2.8, ...
    'MarkerSize', 10, 'MarkerFaceColor',[0.85 0.3 0.1]);

% Утга
for i = 1:length(d_BR_vec)
    yoff = 0.5;
    if i == 1 || i == length(d_BR_vec); yoff = -1.2; end
    text(d_BR_vec(i), slide_snr_pos(i)+yoff, num2str(slide_snr_pos(i)), ...
        'HorizontalAlignment','center','FontSize',11,'FontWeight','bold', ...
        'Color',[0.85 0.3 0.1]);
end


set(ax1,'XTick',d_BR_vec,'FontSize',11);
xlabel('d(BS-RIS) (м)', 'FontSize',12,'FontWeight','bold');
ylabel('SNR (дБ)',       'FontSize',12,'FontWeight','bold');
title({'BS-RIS Зайн Оновчлол', 'Нийт зай = 150 м, M=256'}, ...
    'FontSize',12,'FontWeight','bold');
xlim([10 140]); ylim([5 19]); grid on; box on;


%% ── Баруун: Фазын нарийвчлалын нөлөө ───────────────────────
ax2 = subplot(1,2,2);

bar_colors = {[0.85 0.2 0.1],[0.4 0.6 0.9],[0.25 0.55 0.85], ...
              [0.3 0.75 0.5],[0.35 0.75 0.5]};

for i = 1:5
    bar(i, slide_loss(i), 0.65, 'FaceColor', bar_colors{i}, 'EdgeColor','none');
    hold on;
    if slide_loss(i) > 0
        text(i, slide_loss(i)+0.06, num2str(slide_loss(i)), ...
            'HorizontalAlignment','center','FontSize',13,'FontWeight','bold', ...
            'Color',bar_colors{i});
    else
        text(i, 0.07, '0', ...
            'HorizontalAlignment','center','FontSize',13,'FontWeight','bold', ...
            'Color',[0.3 0.3 0.3]);
    end
end

% 3-bit шугам
%xline(3, '--g', 'Практик хязгаар (3-bit)', 'LineWidth',2, ...
   % 'LabelHorizontalAlignment','right','FontSize',9, ...
%    'Color',[0.1 0.7 0.2],'FontWeight','bold');

set(ax2,'XTick',1:5,'XTickLabel',bit_lbls,'FontSize',12);
xlabel('Phase Resolution',      'FontSize',12,'FontWeight','bold');
ylabel('SNR Алдагдал (дБ)',     'FontSize',12,'FontWeight','bold');
title({'Фазын Нарийвчлалын Нөлөө', 'Ideal continuous-тай харьцуулсан алдагдал'}, ...
    'FontSize',12,'FontWeight','bold');
ylim([0 5]); yticks(0:0.5:5); grid on; box on;

% Дүгнэлт
sgtitle({'BS-RIS Байршлын Оновчлол ба Фазын Нарийвчлал', ...
    'f_c=3.5 GHz | M=256 | d_{нийт}=150 м | N_t=64'}, ...
    'FontSize',13,'FontWeight','bold');

%% ── Туслах функц ──────────────────────────────────────────────
function s = ternary(cond, a, b)
    if cond; s = a; else; s = b; end
end
