% Initialize global variables
epsilon = 1.0;
epsilonDecay = 0.999609;
gamma = 0.99;
replayIndex = 1;
maxReplay = false;
totalMSE = 0;
mseTrack = 0;
updateCount = 0;
done = false;

% Initialize main network
mainNetwork = Network(4,[32,4096,1;4096,2048,1;2048,2048,1;2048,1024,2]);

% Initialize target network
targetNetwork = Network(4,[32,4096,1;4096,2048,1;2048,2048,1;2048,1024,2]);
copyNetwork(mainNetwork,targetNetwork);

% Initialize replay buffer
emptyState = zeros(32,1,'double');
emptyAction = zeros(1024,1,'double');
replayBuffer = arrayfun(@(x)ReplayExperience(emptyState,emptyAction,0,...
               emptyState),1:500);
           
% Initialize network to interact with Checkers board
liveBoard(); 
pausing();

% Main Loop
while done == false
    % Gather Samples with Epsilon Greedy
    for i = 1:50
        networkGameState = observeGameState();
        networkOutput = mainNetwork.forward(networkGameState);
        action = zeros(1024,1,'double');
        targetAction = zeros(1024,1,'double');
        terminal = false;

        % Determine Action Based on Epsilon Greedy
        r = rand(1,1); % Random value

        % If random value is less than epsilon choose random action
        if r < epsilon   
            % Selection and Move is Randomized
            act = randi([1,1024], 1, 1);
            action(act,1) = 1;

            % Execute Action
            executeAction(action);
            resetPointer();
            pause(1.5);
        % Otherwise Choose Action with Highest Q-Value   
        else
            % Find highest input and select action
            maxQ = max(networkOutput);
            qLoc = find(networkOutput == maxQ);
            action(qLoc,1) = 1;

            %Execute Action
            executeAction(action);
            resetPointer();
            pause(1.5);
        end

        % Observe New State
        newGameState = observeGameState();

        % Calculate Reward
        reward = 0;
        if networkGameState == newGameState
            reward = reward - 0.200;
        else
            reward = reward + 0.200;
        end
        
        if selRed(action, networkGameState) == true
            reward = reward + 0.05;
        else
            reward = reward - 0.05;
        end
        
        reward = reward + kingIncrease(networkGameState, newGameState);
        reward = reward + captureIncrease(networkGameState, newGameState);

        % Store in replay buffer
        currentExperience = ReplayExperience(networkGameState,...
                            action,reward,newGameState);
        replayBuffer(replayIndex) = currentExperience;

        % Epsilon Value Updater
        epsilon = epsilon * epsilonDecay;

        % Replay Value Updater
        replayIndex = replayIndex + 1;
        if replayIndex == 10001
            maxReplay = true;
            replayIndex = 1;
        end
        
        % Learning Phase
        if (replayIndex > 50 || maxReplay == true) && i == 50
            gameOver();
            
            % Create Training Batch
            if maxReplay == true
                randpermValue = 10000;
            else
                randpermValue = replayIndex - 1;
            end
            
            numOfSamples = 0;
            if randpermValue < 10000
                numOfSamples = randpermValue * 0.10;
            else
                numOfSamples = 1000;
            end
            
            batch = randperm(randpermValue, numOfSamples);
            % Compute Q-Values and train network for each experience
            for j = 1:numOfSamples
                % Calculate Q value for Training State
                curSample = replayBuffer(1,batch(1,j));
                curInput = curSample.s;
                mainQValues = mainNetwork.forward(curInput);

                % Retrieve Action from Sample
                curAction = curSample.a;
                mainLoc = find(curAction == 1);

                % Retrieve Q Value for Action
                mainQValue = mainQValues(mainLoc,1);

                % Calculate Target Q Value
                curNextInput = curSample.s1;
                targetQValues = targetNetwork.forward(curNextInput);
                targetQValue = max(targetQValues);
                targetLoc = find(targetQValues == targetQValue);
                targetQValue = curSample.r + (gamma * targetQValue);

                % Compute mse and error
                mainVector = mainQValues; 
                mainVector(mainLoc,1) = targetQValue;
                error = mainVector - mainQValues;
                mse = transpose(mainVector - mainQValues) * (mainVector - mainQValues);
                totalMSE = totalMSE + mse;
                mseTrack = mseTrack + 1;

                % Backpropagation
                mainNetwork.backward(error,0.0001);
                updateCount = updateCount + 1;
                
                % Update Target Network
                if updateCount == 256
                    copyNetwork(mainNetwork,targetNetwork);
                    updateCount = 0;
                end
                
                disp("Training Sample: " + j + "/" + numOfSamples);
            end
            disp("MSE for Training: " + (totalMSE/mseTrack));
            if (totalMSE / mseTrack) < 0.5
                done = true;
                break;
            end    
            mseTrack = 0;
            totalMSE = 0;
            
            % Official Game
            if i == 50
                delay = 0;
                liveBoard(); 
                pausing();
                newEpisode();
                for j = 1:1
                    for k = 1:100
                        % Recieve Input and Determine Q Values
                        networkGameState = observeGameState();
                        networkOutput = mainNetwork.forward(networkGameState);

                        % Split output into selection and move
                        selection = networkOutput(1:32,1);
                        move = networkOutput(33:64,1);

                        % Find highest input and select action
                        maxS = max(selection);
                        maxM = max(move);
                        selLoc = find(selection == maxS);
                        movLoc = find(move == maxM);

                        %Execute Action
                        moveAndClick(selLoc);
                        moveAndClick(movLoc);
                        pause(1.5);
                        newGameState = observeGameState();

                        % Check Delay
                        if networkGameState == newGameState
                            delay = delay + 1;
                        else
                            delay = 0;
                        end
                        
                        if delay == 10
                            break;
                        end    
                    end
                end
            end    
        end
    end
    if epsilon < 0.02    
        epsilon = 0.02;
    end
    gameOver();
    pause(2);
    liveBoard(); 
    pausing();
    newEpisode();
end       
beep();
beep();
beep();








%---------------------------------Functions--------------------------------
function out = captureIncrease(oldBoard, newBoard)
    origCount = 0;
    newCount = 0;
    eOrigCount = 0;
    eNewCount = 0;
    
    netCount = 0;
    eNetCount = 0;
    for i = 1:32
        if oldBoard(i,1) == 0.4 || oldBoard(i,1) == 0.8
            origCount = origCount + 1;
        elseif oldBoard(i,1) == 0.6 || oldBoard(i,1) == 1.0
            eOrigCount = eOrigCount + 1;
        end    
    end
    
    for i = 1:32
        if newBoard(i,1) == 0.4 || newBoard(i,1) == 0.8
            newCount = newCount + 1;
        elseif newBoard(i,1) == 0.6 || newBoard(i,1) == 1.0
            eNewCount = eNewCount + 1;
        end    
    end
    
    netCount = newCount - origCount;
    eNetCount = eNewCount - eOrigCount;
    if netCount <= 0
        netCount = 0;
    end
    if eNetCount <= 0
        eNetCount = 0;
    end
   
    out = netCount - eNetCount;
end

function out = kingIncrease(oldBoard, newBoard)
    origKingCount = 0;
    newKingCount = 0;
    eOrigKingCount = 0;
    eNewKingCount = 0;
    
    netKingCount = 0;
    eNetKingCount = 0;
    for i = 1:32
        if oldBoard(i,1) == 0.8
            origKingCount = origKingCount + 1;
        elseif oldBoard(i,1) == 1.0
            eOrigKingCount = eOrigKingCount +1; 
        end    
    end
    
    for i = 1:32
        if newBoard(i,1) == 0.8
            newKingCount = newKingCount + 1;
        elseif newBoard(i,1) == 1.0
            eNewKingCount = eNewKingCount + 1;
        end    
    end
    
    netKingCount = newKingCount - origKingCount;
    eNetKingCount = eNewKingCount - eOrigKingCount;
    
    if netKingCount <= 0
        netKingCount = 0;
    end
    if eNetKingCount <= 0
        eNetKingCount = 0;
    end
    
    out = 0.5 * (netKingCount - eNetKingCount);
end
function out = selRed(action,input)
    loc = find(action == 1);
    sel = ceil(loc/32);
    
    if input(sel,1) == 0.4
        out = true;
    else
        out = false;
    end    
end

function executeAction(action)
    loc = find(action == 1);
    sel = ceil(loc/32);
    mov = loc;
    while mov > 32
        mov = mov - 32;
    end
    moveAndClick(sel);
    moveAndClick(mov);
end

function newEpisode()
    movHome();
    movPlay();
    mov1Player();
    movNewGame();
    movEasy();
    movStartGame();
    pause(1.5);
end

function gameState = observeGameState()
    % Screenshot Current Board State
    curBoard = takeScreenshot(397,193,630,631);

    % Greyscale The Image of Current Board
    curBoard = rgb2gray(curBoard);

    % Get Off-Row Values
    offRowStart = [92,17,74,74];
    offRowValues = offRowInput(curBoard,offRowStart);

    % Get On-Row Values
    onRowStart = [17,92,74,74];
    onRowValues = onRowInput(curBoard,onRowStart);

    % Add pixel value to boardInput
    boardInput = offRowValues + onRowValues;

    % Pixel Value to Neural Input
    gameState = InputTransform(boardInput); 
end

function [boardInput] = offRowInput(board,offRowStart)
    bInput = zeros(1,32);
    boardPos = imcrop(board, offRowStart);
    rowHolder = offRowStart;
    colHolder = offRowStart; %167
    spot = 1;
    for i = 1:4
        for j = 1:4
            centPix = impixel(boardPos,38,37);
            centPix = centPix(1,1);
            bInput(1,spot) = centPix;

            rowHolder = rowHolder + [150,0,0,0];
            spot = spot + 1;
            boardPos = imcrop(board,rowHolder);
        end
        
        colHolder = colHolder + [0,150,0,0];
        rowHolder = colHolder;
        spot = spot + 4;
        boardPos = imcrop(board, colHolder);
    end
    boardInput = bInput;
end

function [boardInput] = onRowInput(board,onRowStart)
    bInput = zeros(1,32);
    boardPos = imcrop(board, onRowStart);
    rowHolder = onRowStart;
    colHolder = onRowStart; %167
    spot = 5;
    for i = 1:4
        for j = 1:4
            centPix = impixel(boardPos,38,37);
            centPix = centPix(1,1);
            bInput(1,spot) = centPix;

            rowHolder = rowHolder + [150,0,0,0];
            spot = spot + 1;
            boardPos = imcrop(board,rowHolder);
        end

        colHolder = colHolder + [0,150,0,0];
        rowHolder = colHolder;
        spot = spot + 4;
        boardPos = imcrop(board, colHolder);
    end
    boardInput = bInput;
end

function [NeuralInput] = InputTransform(nInput)

temp = zeros(1,32,'double');

for i = 1:32
    if nInput(1,i) == 55 || nInput(1,i) == 56
        temp(1,i) = -0.2;
    elseif nInput(1,i)== 57 || nInput(1,i) == 58
        temp(1,i) = 0.2;
    elseif nInput(1,i) == 38
        temp(1,i) = -0.4;
    elseif nInput(1,i) == 40
        temp(1,i) = 0.4;
    else
        temp(1,i) = 0.0;
    end    
end
NeuralInput = transpose(temp);
end

function gameOver()

VK_CONTROL = 17;
VK_RIGHT = 39;

robot = java.awt.Robot();
robot.keyPress(VK_CONTROL);
robot.keyPress(VK_RIGHT);
robot.keyRelease(VK_RIGHT);
robot.keyRelease(VK_CONTROL);

end

function liveBoard()

VK_CONTROL = 17;
VK_LEFT = 37;

robot = java.awt.Robot();
robot.keyPress(VK_CONTROL);
robot.keyPress(VK_LEFT);
robot.keyRelease(VK_LEFT);
robot.keyRelease(VK_CONTROL);

end

function pausing()

system('dir');
pause(0.5);
system('dir');

end

function [imgData] = takeScreenshot(left, top, width, height)

robot = java.awt.Robot();
pos = [left, top, width, height];

rect = java.awt.Rectangle(pos(1),pos(2),pos(3),pos(4));
cap = robot.createScreenCapture(rect);

rgb = typecast(cap.getRGB(0,0,cap.getWidth,cap.getHeight,[],0,cap.getWidth),'uint8');
imgData = zeros(cap.getHeight,cap.getWidth,3,'uint8');
imgData(:,:,1) = reshape(rgb(3:4:end),cap.getWidth,[])';
imgData(:,:,2) = reshape(rgb(2:4:end),cap.getWidth,[])';
imgData(:,:,3) = reshape(rgb(1:4:end),cap.getWidth,[])';

end

function copyNetwork(orig, copy)
    num = orig.N;
    copyLedger = orig.layerLedger;
    
    for i = 1:num
        copyLayer = copyLedger(1,i);
        copyWeight = copyLayer.W;
        copyBias = copyLayer.b;
        copyInput = copyLayer.p;
        copyTransferFunction = copyLayer.transferFunction;
        
        copy.layerLedger(1,i).W = copyWeight;
        copy.layerLedger(1,i).b = copyBias;
        copy.layerLedger(1,i).p = copyInput;
        copy.layerLedger(1,i).transferFunction = copyTransferFunction;
    end    
    
    copy.N = num;
end

function moveAndClick(loc)
if loc == 1
    mov1();
elseif loc == 2
    mov2();
elseif loc == 3
    mov3();
elseif loc == 4
    mov4();
elseif loc == 5
    mov5();
elseif loc == 6
    mov6();
elseif loc == 7
    mov7();
elseif loc == 8
    mov8();
elseif loc == 9
    mov9();
elseif loc == 10
    mov10();
elseif loc == 11
    mov11();
elseif loc == 12
    mov12();
elseif loc == 13
    mov13();
elseif loc == 14
    mov14();
elseif loc == 15
    mov15();
elseif loc == 16
    mov16();
elseif loc == 17
    mov17();
elseif loc == 18
    mov18();
elseif loc == 19
    mov19();
elseif loc == 20
    mov20();     
elseif loc == 21
    mov21();
elseif loc == 22
    mov22();
elseif loc == 23
    mov23();
elseif loc == 24
    mov24();
elseif loc == 25
    mov25();
elseif loc == 26
    mov26();
elseif loc == 27
    mov27();
elseif loc == 28
    mov28();
elseif loc == 29
    mov29();
elseif loc == 30
    mov30();
elseif loc == 31
    mov31();
else
    mov32();
end

end

% First Row
function mov1()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,50);
robot.mouseMove(525,240);
robot.mousePress(1024);
robot.mouseRelease(1024);

end

function mov2()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,50);
robot.mouseMove(675,240);
robot.mousePress(1024);
robot.mouseRelease(1024);

end

function mov3()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,50);
robot.mouseMove(825,240);
robot.mousePress(1024);
robot.mouseRelease(1024);

end

function mov4()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,50);
robot.mouseMove(975,240);
robot.mousePress(1024);
robot.mouseRelease(1024);

end

% Second Row
function mov5()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,50);
robot.mouseMove(450,315);
robot.mousePress(1024);
robot.mouseRelease(1024);

end

function mov6()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,50);
robot.mouseMove(600,315);
robot.mousePress(1024);
robot.mouseRelease(1024);

end

function mov7()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,50);
robot.mouseMove(750,315);
robot.mousePress(1024);
robot.mouseRelease(1024);

end

function mov8()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,50);
robot.mouseMove(900,315);
robot.mousePress(1024);
robot.mouseRelease(1024);

end

% Third Row
function mov9()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,50);
robot.mouseMove(525,390);
robot.mousePress(1024);
robot.mouseRelease(1024);

end

function mov10()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,50);
robot.mouseMove(675,390);
robot.mousePress(1024);
robot.mouseRelease(1024);

end

function mov11()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,50);
robot.mouseMove(825,390);
robot.mousePress(1024);
robot.mouseRelease(1024);

end

function mov12()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,50);
robot.mouseMove(975,390);
robot.mousePress(1024);
robot.mouseRelease(1024);

end

% Fourth Row
function mov13()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,50);
robot.mouseMove(450,465);
robot.mousePress(1024);
robot.mouseRelease(1024);

end

function mov14()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,50);
robot.mouseMove(600,465);
robot.mousePress(1024);
robot.mouseRelease(1024);

end

function mov15()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,50);
robot.mouseMove(750,465);
robot.mousePress(1024);
robot.mouseRelease(1024);

end

function mov16()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,50);
robot.mouseMove(900,465);
robot.mousePress(1024);
robot.mouseRelease(1024);

end

% Fifth Row
function mov17()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,50);
robot.mouseMove(525,540);
robot.mousePress(1024);
robot.mouseRelease(1024);

end

function mov18()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,50);
robot.mouseMove(675,540);
robot.mousePress(1024);
robot.mouseRelease(1024);

end

function mov19()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,50);
robot.mouseMove(825,540);
robot.mousePress(1024);
robot.mouseRelease(1024);

end

function mov20()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,50);
robot.mouseMove(975,540);
robot.mousePress(1024);
robot.mouseRelease(1024);

end

% Sixth Row
function mov21()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,50);
robot.mouseMove(450,615);
robot.mousePress(1024);
robot.mouseRelease(1024);

end

function mov22()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,50);
robot.mouseMove(600,615);
robot.mousePress(1024);
robot.mouseRelease(1024);

end

function mov23()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,50);
robot.mouseMove(750,615);
robot.mousePress(1024);
robot.mouseRelease(1024);

end

function mov24()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,50);
robot.mouseMove(900,615);
robot.mousePress(1024);
robot.mouseRelease(1024);

end

% Seventh Row
function mov25()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,50);
robot.mouseMove(525,690);
robot.mousePress(1024);
robot.mouseRelease(1024);

end

function mov26()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,50);
robot.mouseMove(675,690);
robot.mousePress(1024);
robot.mouseRelease(1024);

end

function mov27()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,50);
robot.mouseMove(825,690);
robot.mousePress(1024);
robot.mouseRelease(1024);

end

function mov28()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,50);
robot.mouseMove(975,690);
robot.mousePress(1024);
robot.mouseRelease(1024);

end

% Eigth Row
function mov29()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,50);
robot.mouseMove(450,765);
robot.mousePress(1024);
robot.mouseRelease(1024);

end

function mov30()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,50);
robot.mouseMove(600,765);
robot.mousePress(1024);
robot.mouseRelease(1024);

end

function mov31()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,50);
robot.mouseMove(750,765);
robot.mousePress(1024);
robot.mouseRelease(1024);

end

function mov32()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,50);
robot.mouseMove(900,765);
robot.mousePress(1024);
robot.mouseRelease(1024);

end

function movHome()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,50);
robot.mouseMove(225,220);
robot.mousePress(1024);
robot.mouseRelease(1024);

end

function movPlay()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,50);
robot.mouseMove(600,750);
robot.mousePress(1024);
robot.mouseRelease(1024);

end

function mov1Player()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,50);
robot.mouseMove(710,435);
robot.mousePress(1024);
robot.mouseRelease(1024);

end

function movNewGame()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,50);
robot.mouseMove(600,665);
robot.mousePress(1024);
robot.mouseRelease(1024);

end


function movEasy()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,50);
robot.mouseMove(710,540);
robot.mousePress(1024);
robot.mouseRelease(1024);

end

function movStartGame()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,50);
robot.mouseMove(710,750);
robot.mousePress(1024);
robot.mouseRelease(1024);

end

function resetPointer()
    pausing();
    robot = java.awt.Robot();
    robot.mouseMove(0,50);
    robot.mouseMove(400,800);
    robot.mousePress(1024);
    robot.mouseRelease(1024);
end