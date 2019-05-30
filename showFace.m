
function [] = showFace(window, screenYpixels)
    %add the image path so it can find images
    %addpath('C:\Users\orang\Documents\PhD\CBM_Human\images\new_faces\random\images');
    
    faceChoice = imread('happyface.jpg');

    %Get the size of the image
    [s1, s2, s3] = size(faceChoice);

    % Here we check if the image is too big to fit on the screen and abort if
    % it is. See ImageRescaleDemo to see how to rescale an image.
    if s1 > screenYpixels || s2 > screenYpixels
        disp('ERROR! Image is too big to fit on the screen');
        sca;
        return;
    end

    % Make the image into a texture
    imageTexture = Screen('MakeTexture', window, faceChoice);

    % Draw the image to the screen, unless otherwise specified PTB will draw
    % the texture full size in the center of the screen. We first draw the
    % image in its correct orientation.
    Screen('DrawTexture', window, imageTexture, [], [], 0);
