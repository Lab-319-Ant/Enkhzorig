%% Slide17_Direct.m
%% Ажиллуулах: >> Slide17_Direct

clc; clear; close all;


% X тэнхлэгийн шошго
papers = {
    sprintf('Sang et al.(2022)'), ...
    sprintf('Wang et al.(2023)'), ...
    sprintf('Yuan et al.(2024)'), ...
    sprintf('Yang et al.(2024) mmWave'), ...
    sprintf('Ramos et al.(2025) mmWave')
};

% Бодит туршилт (хар хөх баган)
actual = [22, 15, 18, 22, 18];

% Манай симуляц (улбар баган)
sim    = [21, 17, 18, 20, 19];


figure('Name','Slide 17', 'Position',[100 100 900 560], 'Color','white');

x   = 1:5;
w   = 0.30;
off = 0.17;

% Бодит туршилт — хар хөх
b1 = bar(x - off, actual, w, 'FaceColor',[0.13 0.22 0.40], 'EdgeColor','none');
hold on;

% Манай симуляц — улбар улаан
b2 = bar(x + off, sim,    w, 'FaceColor',[0.85 0.33 0.10], 'EdgeColor','none');

% Утгын шошго — бодит (дээр)
for i = 1:5
    text(x(i)-off, actual(i)+0.6, num2str(actual(i)), ...
        'HorizontalAlignment','center', ...
        'FontSize',12, 'FontWeight','bold', ...
        'Color',[0.13 0.22 0.40]);
end

% Утгын шошго — симуляц (дээр)
for i = 1:5
    text(x(i)+off, sim(i)+0.6, num2str(sim(i)), ...
        'HorizontalAlignment','center', ...
        'FontSize',12, 'FontWeight','bold', ...
        'Color',[0.85 0.33 0.10]);
end

% Тэнхлэг, гарчиг, домог
set(gca, 'XTick', x, 'XTickLabel', papers, 'FontSize', 10, ...
    'Box','off', 'YGrid','on', 'GridAlpha',0.3);

ylim([-2 30]);
yticks(-2:5:28);
ylabel('RSRP Gain (дБ)', 'FontSize', 13, 'FontWeight', 'bold');

title({'Бодит туршилт  ■  Манай симуляц  ■'}, ...
    'FontSize', 12, 'FontWeight', 'bold');

legend([b1, b2], {'Бодит туршилт (дБ)', 'Манай симуляц (дБ)'}, ...
    'FontSize', 11, 'Location', 'northeast');



