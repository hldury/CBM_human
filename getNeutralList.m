function myNeutralList = getNeutralList()
    
    %get image folder. Directory will need to change depending on computer
    %used 
    directory = 'C:\Users\BBUser\Desktop\CBM_Human\images\real_random';
    traceImages = dir(fullfile(directory, '*.jpg'));
    
    %order the files
    traceImages = natsortfiles({traceImages.name});
    numTraceImages = numel(traceImages);
    %create empty matrix for neutral faces
    myNeutralList = zeros(1, numTraceImages/33);
    myNeutralList = num2cell(myNeutralList);

    listnum = 1;
    for face = 1:numTraceImages
        myTraceImage = traceImages{face};
        if contains(myTraceImage, 'ex17.jpg') == true
            myNeutralList(1, listnum) = traceImages(1,face);
            listnum = listnum+1;
        end
    end
