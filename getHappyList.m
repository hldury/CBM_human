

function myHappyList = getHappyList()
    
    %get image folder. Directory will need to change depending on computer
    %used 
    directory = 'C:\Users\BBUser\Desktop\CBM_Human\images\real_random';
    traceImages = dir(fullfile(directory, '*.jpg'));
    
    %order the files
    traceImages = natsortfiles({traceImages.name});
    numTraceImages = numel(traceImages);
    %create empty matrix for all happy and neutral faces
    myHappyList = zeros(1, numTraceImages/33);
    myHappyList = num2cell(myHappyList);
    
    listnum = 1;
    for face = 1:numTraceImages
        myTraceImage = traceImages{face};
        if contains(myTraceImage, 'ex1.jpg') == true
            myHappyList(1, listnum) = traceImages(1,face);
            listnum = listnum+1;
        end
    end

            
        
  
    

    

    

