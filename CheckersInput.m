% Get input from screen
liveBoard(); 
pausing();
curBoard = takeScreenshot(359,181,707,709);

% Greyscale The Image
curBoard = rgb2gray(curBoard);

% Get Off-Row Values
offRowStart = [105,22,81,82];
offRowValues = offRowInput(curBoard,offRowStart);

% Get On-Row Values
onRowStart = [22,105,81,82];
onRowValues = onRowInput(curBoard,onRowStart);

% Add pixel value to boardInput
boardInput = offRowValues + onRowValues;

% Pixel Value to Neural Input
NeuralInput = InputTransform(boardInput);

% Display Input by Position
num = 1;
for i = 1:32
    temp = [];
    for i = num:num + 4
        temp = [temp, NeuralInput(1,i)];
    end
    disp(transpose(temp));
    num = num + 5;
end    

% Show Transformed input results
gameOver();


function [boardInput] = offRowInput(board,offRowStart)
bInput = zeros(1,32);
boardPos = imcrop(board, offRowStart);
rowHolder = offRowStart;
colHolder = offRowStart; %167
spot = 1;
for i = 1:4
    for j = 1:4
        centPix = impixel(boardPos,42,41);
        centPix = centPix(1,1);
        bInput(1,spot) = centPix;
    
        rowHolder = rowHolder + [167,0,0,0];
        spot = spot + 1;
        boardPos = imcrop(board,rowHolder);
    end
    
    colHolder = colHolder + [0,167,0,0];
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
        centPix = impixel(boardPos,42,41);
        centPix = centPix(1,1);
        bInput(1,spot) = centPix;
    
        rowHolder = rowHolder + [167,0,0,0];
        spot = spot + 1;
        boardPos = imcrop(board,rowHolder);
    end
    
    colHolder = colHolder + [0,167,0,0];
    rowHolder = colHolder;
    spot = spot + 4;
    boardPos = imcrop(board, colHolder);
end
boardInput = bInput;
end

function [NeuralInput] = InputTransform(nInput)

temp = [];

for i = 1:32
    if nInput(1,i) == 55 || nInput(1,i) == 56
        temp = [temp, 0, 0, 1, 0, 0];
    elseif nInput(1,i)== 57 || nInput(1,i) == 58
        temp = [temp, 0, 1, 0, 0, 0];
    elseif nInput(1,i) == 38
        temp = [temp, 0, 0, 0, 0, 1];
    elseif nInput(1,i) == 40
        temp = [temp, 0, 0, 0, 1, 0];
    else
        temp = [temp, 1, 0, 0, 0, 0];
    end    
end
NeuralInput = temp;
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
pause(1);
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