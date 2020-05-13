%% Intialize Workspace
close all   % close all figure windows
clc         % Command Line Clear

load('chair_hd_c5');

%% Pies

gs_avg = mean(gs_per_frame, 'all');
gs_pie = [gs_avg pixels_per_frame-avg];

ms_avg = mean(ms_per_frame, 'all');
ms_pie = [ms_avg gs_avg-ms_avg];

gs_labels = {'Average "Greyscale" Pixels per Frame', 'Non-greyscale Pixels'};
ms_labels = {'Average Marine Snow Pixels per Frame', 'Non-marine snow, greyscale Pixels'};

subplot(2, 1, 1);
pie(gs_pie)
legend(gs_labels);

subplot(2, 1, 2);
pie(ms_pie)
legend(ms_labels);


%% Plots
% plot(frames_processed, gs_per_frame/pixels_per_frame)
% title('Greyscale pixels per frame');
% xlabel('Frame #')
% ylabel('# GS pixels / Total pixels')
% 
% figure
% 
% plot(frames_processed, ms_per_frame)
% title('Marine Snow pixels per frame');
% xlabel('Frame #')
% ylabel('# MS pixels')