% Clear the workspace
clear all;
close all;
clear mex;
clearvars;
sca;

% Setup PTB with some default values
PsychDefaultSetup(2);

%Enter participant number
%SparticipantNumber = input(prompt);

% Seed the random number generator. There's an older version on the ptb
% tutorial

participantID = randi([1, 200]);

%check for unique ppID
dirName = 'C:\Users\BBUser\Desktop\CBM_Human\participant_data';
fileList = dir([dirName, '\*.csv']);
fileNames = {fileList.name};
ppNum = sum(~cellfun(@isempty, strfind(fileNames, participantID)));
while ppNum == 1
    participantID = randi([1, 200]);
    ppNum = sum(~cellfun(@isempty, strfind(fileNames, participantID)));
end


%%create name for file and check it doesn't exist
% filepath = 'C:\Users\orang\Documents\PhD\CBM_Human\participant_data\pp';
% filename = int2str(participantID);
% partFilepath = strcat(filepath, filename, condition);
% fullFilepath = strcat(partFilepath, '.csv');
% if exist(fullFilepath, 'file') == 2
%     sca;
%     disp 'Warning, file already exists.'
% end

%determine group
randomNumber = randperm(3);
conditionNumber = randomNumber(1);
%conditionNumber = 3;

    
numControls = sum(~cellfun(@isempty, strfind(fileNames, 'control')));
numTraces = sum(~cellfun(@isempty, strfind(fileNames, 'trace')));
numCTs = sum(~cellfun(@isempty, strfind(fileNames, 'CT')));

%start counterbalancing once there's five files.
totalFiles = length(fileList);
if totalFiles > 6
    if numControls == numTraces
        if numTraces == numCTs
            conditionNumber = conditionNumber;
        elseif numTraces > numCTs
            conditionNumber = 3;
        elseif numTrace < numCTs
            conditionNumber = 2;
        end
    elseif numControls > numTraces
        conditionNumber = 2;
    elseif numControls < numTraces
        conditionNumber = 1;
    end
end 
        
if conditionNumber == 1
    condition  = '_control';
elseif conditionNumber == 2
    condition = '_trace';
elseif conditionNumber == 3
    condition = '_CT';
end 



% Set the screen number to the external secondary monitor if there is one
% connected
screenNumber = max(Screen('Screens'));

% Define black, white and grey
white = WhiteIndex(screenNumber);
grey = white / 2;
black = BlackIndex(screenNumber);

% Open the screen
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey, [], 32, 2);

% Flip to clear
Screen('Flip', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Set the text size
%Screen('TextSize', window, 60);

% Get the size of the on screen window in pixels
% For help see: Screen WindowSize?
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Query the maximum priority level
topPriorityLevel = MaxPriority(window);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%choose number of blocks and trials. There's an awkward number of CT images
%so these must be altered
if conditionNumber == 3
    numTrials = 40;
    numTrialsTr = 17;
    numBlocksPT = 5;
    numBlocksTr = 40;
    numBlocksTe = 5;
elseif conditionNumber == 2
    numTrials = 40;
    numTrialsTr = numTrials;
    numBlocksPT = 5;
    numBlocksTr = 17;
    numBlocksTe = 5;
elseif conditionNumber == 1
    numTrials = 40;
    numTrialsTr = 44;
    numBlocksPT = 5;
    numBlocksTr = 15;
    numBlocksTe = 5;
end
    

% numTrialsPT = 20;
% numTrialsTr = 20;
% numTrialsTe = 20;

% %comment next lines if using separate values
% numBlocksPT = numBlocks;
% numBlocksTr = numBlocks;
% numBlocksTe = numBlocks;
numTrialsPT = numTrials;
numTrialsTe = numTrials;


%create empty matrix to store all response matrices. Uncomment if different
%quantities of blocks or trials are required for each section
%totalTrials = (numTrials * numBlocks) * 3;
%totalTrials = (numBlocksPT+numBlocksTr+numBlocksTe)*(numBlocksPT+numBlocksTe+numBlocksTr);
totalTrials = (numTrialsPT*numBlocksPT)+(numTrialsTr*numBlocksTr)+(numTrialsTe*numBlocksTe);
fullRespMat = zeros(6, totalTrials);

%get start and end column per block
ptColumnStart = 1;
ptColumnEnd = ptColumnStart * numTrials;
%ptColumnEnd = ptColumnStart * numTrialsPT;
%trColumnStart = (numTrials * numBlocks) + 1;
trColumnStart = (numTrials * numBlocksPT) + 1;
%trColumnStart = (numTrialsPT * numBlocksPT) + 1;
%trColumnEnd = (trColumnStart + numTrials) - 1;
trColumnEnd = (trColumnStart + numTrialsTr) - 1;
%teColumnStart = trColumnStart + (numTrials * numBlocks);
%teColumnStart = trColumnStart + (numTrials * numBlocksTr);
teColumnStart = trColumnStart + (numTrialsTr * numBlocksTr);
teColumnEnd = (teColumnStart + numTrials) - 1;
%teColumnEnd = (teColumnStart + numTrialsTe) - 1;


%----------------------------------------------------------------------
%                       Timing Information
%----------------------------------------------------------------------

% Interstimulus interval time in seconds and frames
isiTimeSecs = 1;
isiTimeFrames = round(isiTimeSecs / ifi);

% Numer of frames to wait before re-drawing
waitframes = 1;

%-------------------------------------------------------------------------
%                         Pretraining Loop
%-------------------------------------------------------------------------

%Instruction slide
line1 = 'You will now be shown a series of faces';
line2 = '\n\n Press the LEFT arrow key if you would describe';
line3 = '\n this face as having a SAD facial expression';
line4 = '\n\n Press the UP arrow key if you would describe';
line5 = '\n this face as having a NEUTRAL facial expression';
line6 = '\n\n Press the RIGHT arrow key if you would describe';
line7 = '\n this face as having a HAPPY facial expression';
line8 = '\n\n\n Press any key to begin';
% Draw all the text in one go
Screen('TextSize', window, 50);

DrawFormattedText(window, [line1 line2 line3 line4 line5 line6 line7 line8],...
    'center', screenYpixels * 0.25, white);

% Flip to the screen
Screen('Flip', window);

% Now we have drawn to the screen we wait for a keyboard button press (any
% key) to terminate the demo
KbStrokeWait;

%Set keyboard presses. % We will be using the left
% and right arrow keys as response keys for the task and the escape key as
% a exit/reset key
escapeKey = KbName('ESCAPE');
leftKey = KbName('LeftArrow');
rightKey = KbName('RightArrow');
upKey = KbName('UpArrow');

%_____________________
%    Begin Blocks
%_____________________

for block = 1:numBlocksPT
    
    %Make the matrix which will determine our conditions
    condMatrixBase = [1];

    % Duplicate the condition matrix to get the full number of trials
    condMatrix = repmat(condMatrixBase, 1, numTrialsPT);

    % Get the size of the matrix
    [~, numTrialsPT] = size(condMatrix);

    % Randomise the conditions (not needed as stimuli are shuffled)
    %shuffler = Shuffle(1:numTrials);
    %condMatrixShuffled = condMatrix(:, shuffler);

    %Create the response matrix. The first row is the block, the second will record the order of presentation, the third row
    %the valence of the face shown, the fourth row their response. The
    %fifth is the section of the study. Sixth is faceID
    respMatPreTrain = nan(6, numTrialsPT);
    


    % Animation loop: we loop for the total number of trials
    for trial = 1:numTrialsPT
        trialNum = trial;
        %faceValence = condMatrixShuffled(1, trial); not needed for random
        %images
        % Cue to determine whether a response has been made
        respToBeMade = true;

        % Flip again to sync us to the vertical retrace at the same time as
        % drawing our fixation point
        Screen('DrawDots', window, [xCenter; yCenter], 10, black, [], 2);
        vbl = Screen('Flip', window);

        % Now we present the isi interval with fixation point minus one frame
        % because we presented the fixation point once already when getting a
        % time stamp
        for frame = 1:isiTimeFrames - 1
            % Draw the fixation point
            Screen('DrawDots', window, [xCenter; yCenter], 10, black, [], 2);
            % Flip to the screen
            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        end

        %get the random face
        randomFace = getRandomFace();
        %Now present the random face in continuous loops until the person presses a
        % key to respond.
        while respToBeMade == true
            %store valence and ID
            valence = regexp(randomFace, '\d*', 'match');
            faceValence = str2num(valence{1,2});
            faceID = str2num(valence{1,1});
            %faceValence = str2num(randomFace(end-4));
            %present the face
            showRandomFace(window, screenYpixels, randomFace);

            % Check the keyboard. The person should press the
            [keyIsDown,secs, keyCode] = KbCheck;
            if keyCode(escapeKey)
                ShowCursor;
                sca;
                return
            elseif keyCode(leftKey)
                response = 1;
                respToBeMade = false;
            elseif keyCode(upKey)
                response = 2;
                respToBeMade = false;
            elseif keyCode(rightKey)
                response = 3;
                respToBeMade = false;
            end

             % Flip to the screen
            Screen('Flip', window);
        end
        
        %give a value for the section of the study. Here, pretraining = 1
        trainingBlock = 1;

        % Record the trial data into out data matrix
        respMatPreTrain(1, trial) = block;
        respMatPreTrain(2, trial) = trialNum;
        respMatPreTrain(3, trial) = faceValence;
        respMatPreTrain(4, trial) = response;
        respMatPreTrain(5, trial) = trainingBlock;
        respMatPreTrain(6, trial) = faceID;
        
        Screen('Close');
    end
       
    %add response matrix into initialised array 
    fullRespMat(1:6, ptColumnStart:ptColumnEnd) = respMatPreTrain;
    ptColumnStart = ptColumnStart + numTrialsPT;
    ptColumnEnd = ptColumnEnd + numTrialsPT;
    

    % Break screen
    DrawFormattedText(window, 'Take a Break \n\n Press Any Key To Continue',...
        'center', 'center', black);
    Screen('Flip', window);
    KbStrokeWait;
  
   
end

filepath = 'C:\Users\BBUser\Desktop\CBM_Human\participant_data\section1_';
filename = int2str(participantID);
partFilepath = strcat(filepath, filename, condition);
fullFilepath = strcat(partFilepath, '.csv');

csvwrite(fullFilepath, fullRespMat);

%-------------------------------------------------------------------------
%                         Training Loop
%-------------------------------------------------------------------------

%Instruction slide
line1 = 'You will now be shown more faces. Remember:';
line2 = '\n\n Press the LEFT arrow key if you would describe';
line3 = '\n this face as having a SAD facial expression';
line4 = '\n\n Press the UP arrow key if you would describe';
line5 = '\n this face as having a NEUTRAL facial expression';
line6 = '\n\n Press the RIGHT arrow key if you would describe';
line7 = '\n this face as having a HAPPY facial expression';
line8 = '\n\n\n Press any key to begin';
% Draw all the text in one go
Screen('TextSize', window, 50);

DrawFormattedText(window, [line1 line2 line3 line4 line5 line6 line7 line8],...
    'center', screenYpixels * 0.25, white);

% Flip to the screen
Screen('Flip', window);

% Now we have drawn to the screen we wait for a keyboard button press (any
% key) to terminate the demo
KbStrokeWait;

%initialise for CT outside of loop
listNum = 1;


%-----------------------------------------------------------------------
%                              control
%-----------------------------------------------------------------------

for block = 1:numBlocksTr

    if conditionNumber == 1
        
        %randomise presentation order
        controlList = [1:660];
        controlList = Shuffle(controlList);
        directory = 'C:\Users\BBUser\Desktop\\CBM_Human\images\real_random';
        randImages = dir(fullfile(directory, '*.jpg'));
        

        %Make the matrix which will determine our conditions
        condMatrixBase = [1];

        % Duplicate the condition matrix to get the full number of trials
        condMatrix = repmat(condMatrixBase, 1, numTrialsTr);

        % Get the size of the matrix
        [~, numTrialsTr] = size(condMatrix);

        %Create the response matrix. The first row is the block, the second will record the order of presentation, the third row
        %the valence of the face shown, the fourth row their response. The
        %fifth is the section of the study. Sixth is faceID
        respMatControl = nan(6, numTrialsTr);

        % Animation loop: we loop for the total number of trials
        for trial = 1:numTrialsTr
            trialNum = trial;
            
            % Cue to determine whether a response has been made
            respToBeMade = true;

            % Flip again to sync us to the vertical retrace at the same time as
            % drawing our fixation point
            Screen('DrawDots', window, [xCenter; yCenter], 10, black, [], 2);
            vbl = Screen('Flip', window);

            % Now we present the isi interval with fixation point minus one frame
            % because we presented the fixation point once already when getting a
            % time stamp
            for frame = 1:isiTimeFrames - 1
                % Draw the fixation point
                Screen('DrawDots', window, [xCenter; yCenter], 10, black, [], 2);
                % Flip to the screen
                vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
            end

            %get the random face
            randomFace = randImages(controlList(((block-1)*numTrials)+trial)).name;
            %Now present the random face in continuous loops until the person presses a
            % key to respond.
            while respToBeMade == true
                %store valence and ID
                valence = regexp(randomFace, '\d*', 'match');
                faceValence = str2num(valence{1,2});
                faceID = str2num(valence{1,1});
                %present the face
                showRandomFace(window, screenYpixels, randomFace);

                % Check the keyboard. The person should press the
                [keyIsDown,secs, keyCode] = KbCheck;
                if keyCode(escapeKey)
                    ShowCursor;
                    sca;
                    return
                elseif keyCode(leftKey)
                    response = 1;
                    respToBeMade = false;
                elseif keyCode(upKey)
                    response = 2;
                    respToBeMade = false;
                elseif keyCode(rightKey)
                    response = 3;
                    respToBeMade = false;
                end

                 % Flip to the screen
                Screen('Flip', window);
            end
            %give a value for the section of the study. Here, training = 2
            trainingBlock = 2;

            % Record the trial data into out data matrix
            respMatControl(1, trial) = block;
            respMatControl(2, trial) = trialNum;
            respMatControl(3, trial) = faceValence;
            respMatControl(4, trial) = response;
            respMatControl(5, trial) = trainingBlock;    
            respMatControl(6, trial) = faceID;
            
            Screen('Close');
        end

        %add response matrix into initialised array 
        fullRespMat(1:6, trColumnStart:trColumnEnd) = respMatControl;
        trColumnStart = trColumnStart + numTrialsTr;
        trColumnEnd = trColumnEnd + numTrialsTr;


        %Break Screen
        DrawFormattedText(window, 'Take a Break \n\n Press Any Key To Continue',...
            'center', 'center', black);
        Screen('Flip', window);
        KbStrokeWait;
        
        
    %-----------------------------------------------------------------------
    %                              Trace Learning
    %-----------------------------------------------------------------------
    elseif conditionNumber == 2

        %Make the matrix which will determine our conditions;
        %happy and neutral
        %condMatrixBase = [1 2];
        condMatrixBase = [1];

        % Duplicate the condition matrix to get the full number of trials
        condMatrix = repmat(condMatrixBase, 1, numTrialsTr);

        % Get the size of the matrix
        [~, numTrialsTr] = size(condMatrix);

        %Create the response matrix. The first row is the block, the second will record the order of presentation, the third row
        %the valence of the face shown (happy = 1, neutral = 2), the fourth
        %row their response. The fifth is the section of the study. Sixth
        %is faceID
        respMatTrace = nan(6, numTrialsTr);
        
        % get happy and neutral image list
        happyList = getHappyList();
        neutralList = getNeutralList;
        
        % Randomise the order of image pairs
        happyOrder = Shuffle(1:20);
        neutralOrder = Shuffle(1:20);
        xNum = 1;
        yNum = 1; %we can't use trial to index into happyOrder as there's 40 vs 20

        % Animation loop: we loop for the total number of trials
        for trial = 1:numTrialsTr
            trialNum = trial;
            
            % Cue to determine whether a response has been made
            respToBeMade = true;

            % Flip again to sync us to the vertical retrace at the same time as
            % drawing our fixation point
            Screen('DrawDots', window, [xCenter; yCenter], 10, black, [], 2);
            vbl = Screen('Flip', window);

            % Now we present the isi interval with fixation point minus one frame
            % because we presented the fixation point once already when getting a
            % time stamp
            for frame = 1:isiTimeFrames - 1
                % Draw the fixation point
                Screen('DrawDots', window, [xCenter; yCenter], 10, black, [], 2);
                % Flip to the screen
                vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
            end
            
            %for odd numbers, a happy face is chosen. For even, a neutral
            if mod(trial,2) == 1
                traceNum = happyOrder(xNum);
                faceValence = 1;
                traceFace = happyList{1, traceNum};
                xNum = xNum+1;
            else
                traceNum = neutralOrder(yNum);
                faceValence = 2;
                traceFace = neutralList{1, traceNum};
                yNum = yNum+1;
            end
            
            %Now present the image in continuous loops until the person presses a
            % key to respond.
            while respToBeMade == true
                %present the face
                showTraceFace(window, screenYpixels, traceFace);

                % Check the keyboard. The person should press the
                [keyIsDown,secs, keyCode] = KbCheck;
                if keyCode(escapeKey)
                    ShowCursor;
                    sca;
                    return
                elseif keyCode(leftKey)
                    response = 1;
                    respToBeMade = false;
                elseif keyCode(upKey)
                    response = 2;
                    respToBeMade = false;
                elseif keyCode(rightKey)
                    response = 3;
                    respToBeMade = false;
                end

                 % Flip to the screen
                Screen('Flip', window);
            end
           
            
            %get faceID
            valence = regexp(traceFace, '\d*', 'match');
            faceID = str2num(valence{1,1});
            
            %give a value for the section of the study. Here, training = 2
            trainingBlock = 2;
            % Record the trial data into out data matrix
            respMatTrace(1, trial) = block;
            respMatTrace(2, trial) = trialNum;
            respMatTrace(3, trial) = faceValence;
            respMatTrace(4, trial) = response;
            respMatTrace(5, trial) = trainingBlock;
            respMatTrace(6, trial) = faceID;
            
            Screen('Close');
        end
        
        %add response matrix into initialised array 
        fullRespMat(1:6, trColumnStart:trColumnEnd) = respMatTrace;
        trColumnStart = trColumnStart + numTrialsTr;
        trColumnEnd = trColumnEnd + numTrialsTr;

        % Break screen
        DrawFormattedText(window, 'Take a Break \n\n Press Any Key To Continue',...
            'center', 'center', black);
        Screen('Flip', window);
        KbStrokeWait;
        
    %-----------------------------------------------------------------------
    %                              CT Learning
    %-----------------------------------------------------------------------
    elseif conditionNumber == 3
        
        %choose random presentation order and initialise file choice
        CTList1  = Shuffle([1:20]);
        CTList2 = Shuffle([1:20]);
        %concatenate horizontally
        CTList = cat(2, CTList1, CTList2);
        CTList = Shuffle(CTList);
        directory = 'C:\Users\BBUser\Desktop\\CBM_Human\images\real_random';
        CTImages = dir(fullfile(directory, '*.jpg'));
        CTImages = natsortfiles({CTImages.name});
        
        
        
        %Make the matrix which will determine our conditions
        condMatrixBase = [1];


        % Duplicate the condition matrix to get the full number of trials
        condMatrix = repmat(condMatrixBase, 1, numTrialsTr);

        % Get the size of the matrix
        [~, numTrialsTr] = size(condMatrix);

        %Create the response matrix. The first row is the block, the second will record the order of presentation, the third row
        %the valence of the face shown, the fourth row their response. The fifth is the section of the study
        respMatCT = nan(6, numTrialsTr);

        % Animation loop: we loop for the total number of trials
        for trial = 1:numTrialsTr
            trialNum = trial;
            startNum = CTList(listNum);
            
            % Cue to determine whether a response has been made
            respToBeMade = true;

            % Flip again to sync us to the vertical retrace at the same time as
            % drawing our fixation point
            Screen('DrawDots', window, [xCenter; yCenter], 10, black, [], 2);
            vbl = Screen('Flip', window);

            % Now we present the isi interval with fixation point minus one frame
            % because we presented the fixation point once already when getting a
            % time stamp
            for frame = 1:isiTimeFrames - 1
                % Draw the fixation point
                Screen('DrawDots', window, [xCenter; yCenter], 10, black, [], 2);
                % Flip to the screen
                vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
            end
            
            
            %get the face image. each set has 33 images, so we add the
            %trialNum to the set
            if startNum == 1
                imageNum = trialNum;
            else
                imageNum = ((startNum - 1) * 33) + trialNum;
            end
            
            CTFace = getCTFace(directory, imageNum);
            %get the valence and ID 
            valence = regexp(CTFace, '\d*', 'match');
            faceValence = str2num(valence{1,2});
            faceID = str2num(valence{1,1});
            

            %Now present the face in continuous loops until the person presses a
            % key to respond.
            while respToBeMade == true
               
                %present the face
                showCTFace(window, screenYpixels, CTFace);

                % Check the keyboard. The person should press the
                [keyIsDown,secs, keyCode] = KbCheck;
                if keyCode(escapeKey)
                    ShowCursor;
                    sca;
                    return
                elseif keyCode(leftKey)
                    response = 1;
                    respToBeMade = false;
                elseif keyCode(upKey)
                    response = 2;
                    respToBeMade = false;
                elseif keyCode(rightKey)
                    response = 3;
                    respToBeMade = false;
                end

                 % Flip to the screen
                Screen('Flip', window);
            end
            
            
            %give a value for the section of the study. Here, training = 2
            trainingBlock = 2;
         
            % Record the trial data into out data matrix
            respMatCT(1, trial) = block;
            respMatCT(2, trial) = trialNum;
            respMatCT(3, trial) = faceValence;
            respMatCT(4, trial) = response;
            respMatCT(5, trial) = trainingBlock;
            respMatCT(6, trial) = faceID;
            
            Screen('Close');
            
        end
        
        listNum = listNum + 1;
        
        %add response matrix into initialised array 
        fullRespMat(1:6, trColumnStart:trColumnEnd) = respMatCT;
        trColumnStart = trColumnStart + numTrialsTr;
        trColumnEnd = trColumnEnd + numTrialsTr;

        % Break screen
        if mod(block,2) == 0
            DrawFormattedText(window, 'Take a Break \n\n Press Any Key To Continue',...
            'center', 'center', black);
            Screen('Flip', window);
            KbStrokeWait;
        end

    end
    
    filepath = 'C:\Users\BBUser\Desktop\CBM_Human\participant_data\section2_';
    filename = int2str(participantID);
    partFilepath = strcat(filepath, filename, condition);
    fullFilepath = strcat(partFilepath, '.csv');

    csvwrite(fullFilepath, fullRespMat)
end
%--------------------------------------------------------------------------
%                                testing
%--------------------------------------------------------------------------


for block = 1:numBlocksTe

    %Make the matrix which will determine our conditions
    condMatrixBase = [1];


    % Duplicate the condition matrix to get the full number of trials
    condMatrix = repmat(condMatrixBase, 1, numTrialsTe);

    % Get the size of the matrix
    [~, numTrialsTe] = size(condMatrix);

    %Create the response matrix. The first row is the block, the second will record the order of presentation, the third row
    %the valence of the face shown, the fourth row their response. The fifth is the section of the study
    
    respMatTest = nan(6, numTrialsTe);

    % Animation loop: we loop for the total number of trials
    for trial = 1:numTrialsTe
        trialNum = trial;
        
        % Cue to determine whether a response has been made
        respToBeMade = true;

        % Flip again to sync us to the vertical retrace at the same time as
        % drawing our fixation point
        Screen('DrawDots', window, [xCenter; yCenter], 10, black, [], 2);
        vbl = Screen('Flip', window);

        % Now we present the isi interval with fixation point minus one frame
        % because we presented the fixation point once already when getting a
        % time stamp
        for frame = 1:isiTimeFrames - 1
            % Draw the fixation point
            Screen('DrawDots', window, [xCenter; yCenter], 10, black, [], 2);
            % Flip to the screen
            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        end

        %get the random face
        randomFace = getRandomFace();
        %Now present the random face in continuous loops until the person presses a
        % key to respond.
        while respToBeMade == true
            %store valence
            valence = regexp(randomFace, '\d*', 'match');
            faceValence = str2num(valence{1,2});
            faceID = str2num(valence{1,1});
            %present the face
            showRandomFace(window, screenYpixels, randomFace);

            % Check the keyboard. The person should press the
            [keyIsDown,secs, keyCode] = KbCheck;
            if keyCode(escapeKey)
                ShowCursor;
                sca;
                return
            elseif keyCode(leftKey)
                response = 1;
                respToBeMade = false;
            elseif keyCode(upKey)
                response = 2;
                respToBeMade = false;
            elseif keyCode(rightKey)
                response = 3;
                respToBeMade = false;
            end

             % Flip to the screen
            Screen('Flip', window);
        end
        
        %give a value for the section of the study. Here, testing = 3
        trainingBlock = 3;

        % Record the trial data into out data matrix
        respMatTest(1, trial) = block;
        respMatTest(2, trial) = trialNum;
        respMatTest(3, trial) = faceValence;
        respMatTest(4, trial) = response;
        respMatTest(5, trial) = trainingBlock;
        respMatTest(6, trial) = faceID;
        
        Screen('Close');
    end
   

    %add response matrix into initialised array 
    fullRespMat(1:6, teColumnStart:teColumnEnd) = respMatTest;
    teColumnStart = teColumnStart + numTrialsTe;
    teColumnEnd = teColumnEnd + numTrialsTe;
        

    % End of block screen
    if block == numBlocksTe
        if trial == numTrialsTe
            % End of experiment screen. We clear the screen once they have made their
            % response
            DrawFormattedText(window, 'Experiment Finished \n\n Press Any Key To Exit',...
            'center', 'center', black);
            Screen('Flip', window);
            KbStrokeWait;
            sca;
        end
    else 
        DrawFormattedText(window, 'Take a Break \n\n Press Any Key To Continue',...
        'center', 'center', black);
        Screen('Flip', window);
        KbStrokeWait;
    end
end

% % End of experiment screen. We clear the screen once they have made their
% % response
% DrawFormattedText(window, 'Experiment Finished \n\n Press Any Key To Exit',...
%     'center', 'center', black);
% Screen('Flip', window);
% KbStrokeWait;
% sca;


%%save file
filepath = 'C:\Users\BBUser\Desktop\CBM_Human\participant_data\pp';
filename = int2str(participantID);
partFilepath = strcat(filepath, filename, condition);
fullFilepath = strcat(partFilepath, '.csv');

csvwrite(fullFilepath, fullRespMat);

