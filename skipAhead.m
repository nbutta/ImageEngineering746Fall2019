%% Intialize Workspace
close all   % close all figure windows
clear all   % clear MATLAB workspace
clc         % Command Line Clear

depVideoPlayer = vision.DeployableVideoPlayer;

videoFileReader = VideoReader('trash_full.mp4');
videoFileReader.CurrentTime = (5300-1)/videoFileReader.FrameRate;

for i = 1:320
    frame = readFrame(videoFileReader);
    image(frame);
    hold on
    pause(1/videoFileReader.FrameRate);
end