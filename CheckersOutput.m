% Output... to be the result of the Neural Network
Output = [0,0,0,0,...
          0,0,0,0,...
          0,0,0,0,...
          0,0,0,0,...
          0,1,0,0,...
          0,0,0,0,...
          0,0,0,0,...
          0,0,0,0,...% End of Selection
          ...
          ...
          0,0,0,0,...% Start of Move
          0,0,0,0,...
          0,0,1,0,...
          0,0,0,0,...
          0,0,0,0,...
          0,0,0,0,...
          0,0,0,0,...
          0,0,0,0,];

      
% Output to Selection Conversion
selection = Output(1,1:32);
move = Output(1,33:64);

selLoc = find(selection == 1);
movLoc = find(move == 1);


% Selection Map
liveBoard();
pausing();
moveAndClick(selLoc);
moveAndClick(movLoc);

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
robot.mouseMove(0,0);
robot.mouseMove(505,240);
robot.mousePress(4096);
robot.mouseRelease(4096);

end

function mov2()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,0);
robot.mouseMove(670,240);
robot.mousePress(4096);
robot.mouseRelease(4096);

end

function mov3()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,0);
robot.mouseMove(840,240);
robot.mousePress(4096);
robot.mouseRelease(4096);

end

function mov4()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,0);
robot.mouseMove(1005,240);
robot.mousePress(4096);
robot.mouseRelease(4096);

end

% Second Row
function mov5()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,0);
robot.mouseMove(420,325);
robot.mousePress(4096);
robot.mouseRelease(4096);

end

function mov6()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,0);
robot.mouseMove(590,325);
robot.mousePress(4096);
robot.mouseRelease(4096);

end

function mov7()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,0);
robot.mouseMove(755,325);
robot.mousePress(4096);
robot.mouseRelease(4096);

end

function mov8()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,0);
robot.mouseMove(925,325);
robot.mousePress(4096);
robot.mouseRelease(4096);

end

% Third Row
function mov9()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,0);
robot.mouseMove(505,405);
robot.mousePress(4096);
robot.mouseRelease(4096);

end

function mov10()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,0);
robot.mouseMove(670,405);
robot.mousePress(4096);
robot.mouseRelease(4096);

end

function mov11()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,0);
robot.mouseMove(840,405);
robot.mousePress(4096);
robot.mouseRelease(4096);

end

function mov12()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,0);
robot.mouseMove(1005,405);
robot.mousePress(4096);
robot.mouseRelease(4096);

end

% Fourth Row
function mov13()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,0);
robot.mouseMove(420,490);
robot.mousePress(4096);
robot.mouseRelease(4096);

end

function mov14()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,0);
robot.mouseMove(590,490);
robot.mousePress(4096);
robot.mouseRelease(4096);

end

function mov15()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,0);
robot.mouseMove(755,490);
robot.mousePress(4096);
robot.mouseRelease(4096);

end

function mov16()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,0);
robot.mouseMove(925,490);
robot.mousePress(4096);
robot.mouseRelease(4096);

end

% Fifth Row
function mov17()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,0);
robot.mouseMove(505,575);
robot.mousePress(4096);
robot.mouseRelease(4096);

end

function mov18()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,0);
robot.mouseMove(670,575);
robot.mousePress(4096);
robot.mouseRelease(4096);

end

function mov19()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,0);
robot.mouseMove(840,575);
robot.mousePress(4096);
robot.mouseRelease(4096);

end

function mov20()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,0);
robot.mouseMove(1005,575);
robot.mousePress(4096);
robot.mouseRelease(4096);

end

% Sixth Row
function mov21()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,0);
robot.mouseMove(420,650);
robot.mousePress(4096);
robot.mouseRelease(4096);

end

function mov22()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,0);
robot.mouseMove(590,650);
robot.mousePress(4096);
robot.mouseRelease(4096);

end

function mov23()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,0);
robot.mouseMove(755,650);
robot.mousePress(4096);
robot.mouseRelease(4096);

end

function mov24()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,0);
robot.mouseMove(925,650);
robot.mousePress(4096);
robot.mouseRelease(4096);

end

% Seventh Row
function mov25()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,0);
robot.mouseMove(505,740);
robot.mousePress(4096);
robot.mouseRelease(4096);

end

function mov26()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,0);
robot.mouseMove(670,740);
robot.mousePress(4096);
robot.mouseRelease(4096);

end

function mov27()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,0);
robot.mouseMove(840,740);
robot.mousePress(4096);
robot.mouseRelease(4096);

end

function mov28()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,0);
robot.mouseMove(1005,740);
robot.mousePress(4096);
robot.mouseRelease(4096);

end

% Eigth Row
function mov29()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,0);
robot.mouseMove(420,820);
robot.mousePress(4096);
robot.mouseRelease(4096);

end

function mov30()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,0);
robot.mouseMove(590,820);
robot.mousePress(4096);
robot.mouseRelease(4096);

end

function mov31()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,0);
robot.mouseMove(755,820);
robot.mousePress(4096);
robot.mouseRelease(4096);

end

function mov32()

pausing();
robot = java.awt.Robot();
robot.mouseMove(0,0);
robot.mouseMove(925,820);
robot.mousePress(4096);
robot.mouseRelease(4096);

end

function pausing()

system('dir');
pause(0.5);
system('dir');

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