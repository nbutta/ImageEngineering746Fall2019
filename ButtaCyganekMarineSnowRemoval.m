%% Intialize Workspace
close all   % close all figure windows
clear all   % clear MATLAB workspace
clc         % Command Line Clear

videoFileReader = VideoReader('trash_full.mp4');
%Skip ahead to the chair
videoFileReader.CurrentTime = (5300-1)/videoFileReader.FrameRate;

% filteredVideo = VideoWriter('chair_filtered_hd_c5.avi');
% detectionsVideo = VideoWriter('chair_detections_hd_c5.avi');
% greyscaleVideo = VideoWriter('chair_greyscale_hd_c5.avi');
% marinesnowVideo = VideoWriter('chair_marinesnow_hd_c5.avi');
% 
% open(filteredVideo);
% open(detectionsVideo);
% open(greyscaleVideo);
% open(marinesnowVideo);

%720 x 1280 - titanic
%360 x 640 - coral
%360 x 640 - trash
%360 x 640 - crab
cols_per_frame = videoFileReader.Width;
rows_per_frame = videoFileReader.Height;
pixels_per_frame = cols_per_frame * rows_per_frame;

%% Control parameters
%Greyscale neighborhood 32 x 32
q = 32;
%Greyscale threshold - RGB_p - min RGB in q x q for N-1/N+1 < c
c = 5;

%Movement neighborhood 7 x 7
s = 6;
%Movement threshold - I_p - Max I in s x s for N-1/N+1 > d
d = 0;

%% Statistics
%total_frames = floor(videoFileReader.Duration * videoFileReader.FrameRate);
%total_frames = 10;
total_frames = 320;

%Don't process the first and last frames
num_frames_processed = total_frames - 2;
frames_processed = 2:total_frames-1;

gs_per_frame = zeros(1, num_frames_processed);
ms_per_frame = zeros(1, num_frames_processed);

%% Cyganek/Gongola algorithm
for it = 1:num_frames_processed 
    
    %Number of Greyscale and Marine Snow pixels per frame
    gs_pixel_count = 0;
    ms_pixel_count = 0;
        
    %Get 3 frames from the video
    if (it == 1)
        %First time around, read 3 new frames at once
        prevFrame = readFrame(videoFileReader);
        currFrame = readFrame(videoFileReader);
        nextFrame = readFrame(videoFileReader);
        
        %Equation (1)
        %Compute RGB distance for all pixels of each frame
        prevFrameRgbDistance = abs(int16(prevFrame(:,:,1))-int16(prevFrame(:,:,2))) + abs(int16(prevFrame(:,:,2))-int16(prevFrame(:,:,3))) + abs(int16(prevFrame(:,:,1))-int16(prevFrame(:,:,3)));
        currFrameRgbDistance = abs(int16(currFrame(:,:,1))-int16(currFrame(:,:,2))) + abs(int16(currFrame(:,:,2))-int16(currFrame(:,:,3))) + abs(int16(currFrame(:,:,1))-int16(currFrame(:,:,3)));
        nextFrameRgbDistance = abs(int16(nextFrame(:,:,1))-int16(nextFrame(:,:,2))) + abs(int16(nextFrame(:,:,2))-int16(nextFrame(:,:,3))) + abs(int16(nextFrame(:,:,1))-int16(nextFrame(:,:,3)));
    else
        %Therefafter, read only a single new frame
        prevFrame = currFrame;
        currFrame = nextFrame;
        nextFrame = readFrame(videoFileReader);
        
        %Equation (1)
        %Compute RGB distance for all pixels of each frame
        prevFrameRgbDistance = currFrameRgbDistance;
        currFrameRgbDistance = nextFrameRgbDistance;
        nextFrameRgbDistance = abs(int16(nextFrame(:,:,1))-int16(nextFrame(:,:,2))) + abs(int16(nextFrame(:,:,2))-int16(nextFrame(:,:,3))) + abs(int16(nextFrame(:,:,1))-int16(nextFrame(:,:,3)));
    end
    
    %Make a copy of the current frame
    filteredCopy   = currFrame;
    detectionsCopy = currFrame;
    greyscaleCopy  = currFrame;
    marinesnowCopy = uint8(zeros(rows_per_frame, cols_per_frame, 3));
    connectionFrame = zeros(rows_per_frame, cols_per_frame);
   
    %Go through every pixel in the current frame...
    for row = 1:rows_per_frame
        for col = 1:cols_per_frame

            %Get the pixel's Q(p) neighborhood (32x32) *really 33x33
            %For border pixels, use as many pixels before reaching the edge
            QStartRow = max(1, row-q/2);
            QStopRow = min(rows_per_frame, row+q/2-1);
            QStartCol = max(1, col-q/2);
            QStopCol = min(cols_per_frame, col+q/2-1);

            %Equation (2)
            %RGB distance averages of neighborhoods
            prevNeighborhood = mean(prevFrameRgbDistance(QStartRow:QStopRow, QStartCol:QStopCol), 'all');
            nextNeighborhood = mean(nextFrameRgbDistance(QStartRow:QStopRow, QStartCol:QStopCol), 'all');

            %Equation (3) 
            %Check for pixels with low saturation (greyscale)
            %Compare the RGB distance of the current pixel with the
            %neighborhood average RGB distances. c from (0 to 70)
            if (currFrameRgbDistance(row,col) - min(prevNeighborhood, nextNeighborhood) < c)
                
                %Greyscale Pixel Detected!
                gs_pixel_count = gs_pixel_count + 1;
                
                %Continue processing these pixels
                %Detections
                greyscaleCopy(row,col,1) = 128;
                greyscaleCopy(row,col,2) = 128;
                greyscaleCopy(row,col,3) = 128;

                %Get the pixel's s x s neighborhood (7x7)
                %Check if the pixel has a value greater than previous and next frames
                sStartRow = max(1, row-s/2);
                sStopRow = min(rows_per_frame, row+s/2-1);
                sStartCol = max(1, col-s/2);
                sStopCol = min(cols_per_frame, col+s/2-1);
                
                prevSPatch_R = prevFrame(sStartRow:sStopRow, sStartCol:sStopCol, 1);
                prevSPatch_G = prevFrame(sStartRow:sStopRow, sStartCol:sStopCol, 2);
                prevSPatch_B = prevFrame(sStartRow:sStopRow, sStartCol:sStopCol, 3 );
                
                nextSPatch_R = nextFrame(sStartRow:sStopRow, sStartCol:sStopCol, 1);
                nextSPatch_G = nextFrame(sStartRow:sStopRow, sStartCol:sStopCol, 2);
                nextSPatch_B = nextFrame(sStartRow:sStopRow, sStartCol:sStopCol, 3);

                %Equation (5)
                %Using the max operator (most reliable) instead of median or average
                maxPrevFrame_R = max(prevSPatch_R,[],'all');
                maxPrevFrame_G = max(prevSPatch_G,[],'all');
                maxPrevFrame_B = max(prevSPatch_B,[],'all');

                maxNextFrame_R = max(nextSPatch_R,[],'all');
                maxNextFrame_G = max(nextSPatch_G,[],'all');
                maxNextFrame_B = max(nextSPatch_B,[],'all');

                %Equation (7)
                %Check for fast moving pixels
                if ((currFrame(row,col,1) - maxPrevFrame_R > d && currFrame(row,col,1) - maxNextFrame_R > d) && ...
                    (currFrame(row,col,2) - maxPrevFrame_G > d && currFrame(row,col,2) - maxNextFrame_G > d) && ...
                    (currFrame(row,col,3) - maxPrevFrame_B > d && currFrame(row,col,3) - maxNextFrame_B > d))

                  %Marine Snow Pixel Detected!
                  ms_pixel_count = ms_pixel_count + 1;
                  
                  %Equation (10)
                  %Removal
                  med_R = median([prevSPatch_R nextSPatch_R], 'all');
                  med_G = median([prevSPatch_G nextSPatch_G], 'all');
                  med_B = median([prevSPatch_B nextSPatch_B], 'all');
                  
                  filteredCopy(row,col,1) = med_R;
                  filteredCopy(row,col,2) = med_G;
                  filteredCopy(row,col,3) = med_B;
                  
                  detectionsCopy(row,col,1) = 0;
                  detectionsCopy(row,col,2) = 255;
                  detectionsCopy(row,col,3) = 0;
                  
                  greyscaleCopy(row,col,1) = 0;
                  greyscaleCopy(row,col,2) = 255;
                  greyscaleCopy(row,col,3) = 0;
                  
                  marinesnowCopy(row,col,1) = 0;
                  marinesnowCopy(row,col,2) = 255;
                  marinesnowCopy(row,col,3) = 0;
                  
                  connectionFrame(row, col) = 1;
                end
            end
        end
    end
    
    %Done processing the current frame;
    
    imshow(connectionFrame);
    CC = bwconncomp(connectionFrame);    
    numPixels = cellfun(@numel,CC.PixelIdxList);
    [biggest,idx] = max(numPixels);
    connectionFrame(CC.PixelIdxList{idx}) = .5;
    figure
    imshow(connectionFrame);
    
    gs_per_frame(1, it) = gs_pixel_count;
    ms_per_frame(1, it) = ms_pixel_count;
    
    %Write the new frames to the video outputs
%     writeVideo(filteredVideo, filteredCopy);
%     writeVideo(detectionsVideo, detectionsCopy);
%     writeVideo(greyscaleVideo, greyscaleCopy);
%     writeVideo(marinesnowVideo, marinesnowCopy);
end

% close(filteredVideo)
% close(detectionsVideo)
% close(greyscaleVideo)
% close(marinesnowVideo)