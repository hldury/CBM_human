

function myCTImage = getCTFace(~, imageNum)
    
    %get image folder. Directory will need to change depending on computer
    %used 
    directory = 'C:\Users\BBUser\Desktop\CBM_Human\images\real_random';
    CTImages = dir(fullfile(directory, '*.jpg'));
    
    %order the files
    CTImages = natsortfiles({CTImages.name});
    
    % get the corresponding name of the image, use braces as it is a cell
    myCTImage = CTImages{imageNum};


    