% Intialize Workspace
close all   % close all figure windows
clear all   % clear MATLAB workspace
clc         % Command Line Clear

name = "chair";

set(gcf, 'Position',  [10, 100, 1000, 300])
%set(gcf, 'Position',  [10, 100, 500, 500])

originalVideo = VideoReader(name + "_Trim.mp4");
greyscaleVideo_c0 = VideoReader(name + "_greyscale_c0.avi");
greyscaleVideo_c5 = VideoReader(name + "_greyscale_c5.avi");
greyscaleVideo_c10 = VideoReader(name + "_greyscale_c10.avi");

while hasFrame(greyscaleVideo_c0)
    
    % read video frames
    ogFrame = readFrame(originalVideo);    
    greyFrame_c0 = readFrame(greyscaleVideo_c0);
    greyFrame_c5 = readFrame(greyscaleVideo_c5);
    greyFrame_c10 = readFrame(greyscaleVideo_c10);
        
    subplot(1,4,1);
    image(ogFrame);
    subplot(1,4,2);
    image(greyFrame_c0);
    subplot(1,4,3);
    image(greyFrame_c5);
    subplot(1,4,4);
    image(greyFrame_c10);
    hold on;
    
    pause;
end