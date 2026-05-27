%% ============================================================
%  RUN_ALL_SLIDES.m — Бүх Слайдын Симуляцийг Нэгт Ажиллуулах
%  MATLAB R2024b | 5G Toolbox v2.8 | Comm Toolbox v15.3
% ============================================================
%  Илтгэлийн симуляцийн үр дүн бүхий слайдуудыг нэгт гаргана:
%
%  Слайд 08 → Slide08_M2_Law.m
%    M² хуулийн нотолгоо: SNR vs M, RIS vs Relay харьцуулалт
%
%  Слайд 10 → Slide10_Beamforming_Algorithms.m
%    SDR / AO(4,10) / DRL-DDPG / DRL-SAC SNR, үр ашиг, хурд
%
%  Слайд 13 → Slide13_SNR_BER_vs_M.m
%    Блокаж сценари: SNR/BER vs M, 5G eMBB/URLLC тал
%
%  Слайд 14 → Slide14_UMa_InH_Simulation.m
%    UMa SNR vs M (d=150м) + InH Coverage vs M (20×30м)
%
%  Слайд 15 → Slide15_Placement_PhaseResolution.m
%    BS-RIS байршлын оновчлол + фазын нарийвчлалын нөлөө
%
%  Слайд 16 → Slide16_RIS_vs_Relay_vs_MMIMO.m
%    RIS vs AF Relay vs Massive MIMO (SE, EE, хүч)
%
%  Слайд 17 → Slide17_Validation.m
%    Бодит 5G туршилтуудтай RSRP gain харьцуулалт
% ============================================================
%  Шаардлагатай Toolbox-ууд:
%    ✓ 5G Toolbox v2.8          (nrCarrierConfig, nrCDLChannel)
%    ✓ Communications Toolbox v15.3  (qfunc, qpsk)
%    ✓ Phased Array System Toolbox   (steering vector)
%    ✓ Optimization Toolbox          (SDR/SDP — fmincon)
% ============================================================

clc; clear; close all;

fprintf('╔══════════════════════════════════════════════════════════╗\n');
fprintf('║  RIS 5G NR Симуляц — Бүх Слайдын Үр Дүн                ║\n');
fprintf('║  MATLAB R2024b | 5G Toolbox v2.8                        ║\n');
fprintf('╚══════════════════════════════════════════════════════════╝\n\n');

slide_files = {
    'Slide08_M2_Law.m',                  'Слайд 8:  M² Хуулийн Нотолгоо';
    'Slide10_Beamforming_Algorithms.m',  'Слайд 10: Beamforming Алгоритм';
    'Slide13_SNR_BER_vs_M.m',            'Слайд 13: SNR/BER vs M (Блокаж)';
    'Slide14_UMa_InH_Simulation.m',      'Слайд 14: UMa ба InH Симуляц';
    'Slide15_Placement_PhaseResolution.m','Слайд 15: Байршил + Фазын Нарийвчлал';
    'Slide16_RIS_vs_Relay_vs_MMIMO.m',   'Слайд 16: RIS vs Relay vs M-MIMO';
    'Slide17_Validation.m',              'Слайд 17: Бодит Туршилттай Харьцуулалт';
};

n = size(slide_files, 1);
success = zeros(1, n);

for i = 1:n
    fname = slide_files{i,1};
    desc  = slide_files{i,2};
    fprintf('[%d/%d] %s\n', i, n, desc);
    try
        run(fname);
        fprintf('       ✓ Амжилттай\n\n');
        success(i) = 1;
    catch e
        fprintf('       ✗ Алдаа: %s\n\n', e.message);
    end
end

fprintf('══════════════════════════════════\n');
fprintf('Нийт: %d/%d файл амжилттай\n', sum(success), n);
for i = 1:n
    status = '✓'; if ~success(i); status = '✗'; end
    fprintf('  %s %s\n', status, slide_files{i,2});
end
fprintf('══════════════════════════════════\n');
