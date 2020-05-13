% Intialize Workspace
close all   % close all figure windows
clear all   % clear MATLAB workspace
clc         % Command Line Clear

name = "chair";

set(gcf, 'Position',  [10, 25, 600, 400])
%set(gcf, 'Position',  [10, 100, 1500, 300])
%set(gcf, 'Position',  [10, 100, 500, 500])

%while true

    originalVideo = VideoReader('trash_full.mp4');
    %Skip ahead to the chair 
    originalVideo.CurrentTime = (5300-1)/originalVideo.FrameRate;

    %originalVideo = VideoReader(name + "_Trim.mp4");
    
    greyscaleVideo = VideoReader(name + "_greyscale_hd_c5.avi");
    detectionsVideo = VideoReader(name + "_detections_hd_c5.avi");
    filteredVideo = VideoReader(name + "_filtered_hd_c5.avi");
    marinesnowVideo = VideoReader(name + "_marinesnow_hd_c5.avi");
    
    frame = 1;
    
    while hasFrame(filteredVideo)
        
        % read video frames
        ogFrame = readFrame(originalVideo);
        detFrame = readFrame(detectionsVideo);
        filtFrame = readFrame(filteredVideo);
        greyFrame = readFrame(greyscaleVideo);
        msFrame = readFrame(marinesnowVideo);
        
        subplot(2,2,1);
        image(ogFrame);
        title('Original Frame');
        subplot(2,2,2);
        image(filtFrame);
        title('Filtered Frame');
        subplot(2,2,3);
        image(msFrame);
        title('Marine Snow Detections');
        subplot(2,2,4);
        image(detFrame);        
        title('Overlayed Frame');
        
        hold on;
        
        %pause(1/filteredVideo.FrameRate);
        %depVideoPlayer(currFrame);
        pause
    end
%end