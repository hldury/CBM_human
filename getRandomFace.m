

function myRandomImage = getRandomFace(~)
    
    %get image folder. Directory will need to change depending on computer
    %used 
    directory = 'C:\Users\BBUser\Desktop\CBM_Human\images\real_random';
    randImages = dir(fullfile(directory, '*.jpg'));
    % generate a random number between 1 and the number of images
    randomNumber = randi([1 size(randImages,1)]);
    % get the corresponding name of the image 
    myRandomImage = randImages(randomNumber).name;

    

    

