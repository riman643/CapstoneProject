classdef Network<handle
    properties
        layerLedger  % Number of Layers
        N            % Number of Layers
    end
    
    methods
        function obj = Network(numOfLayers, layerMatrix)
            obj.N = numOfLayers;
            
            obj.layerLedger = arrayfun(@(x)NetworkLayer(1,1,1),...
            1:numOfLayers);
            
            for i = 1:numOfLayers
                curInput = layerMatrix(i,1);
                curOutput = layerMatrix(i,2);
                curTransfer = layerMatrix(i,3);
                curLayer = NetworkLayer(curInput,curOutput,curTransfer);
                obj.layerLedger(1,i) = curLayer;
            end    
        end
        
        function outPut = forward(self, input)
            curInput = input;
            for i = 1:self.N
                curOutput = self.layerLedger(1,i).forward(curInput);
                curInput = curOutput;
            end
            
            outPut = curOutput;
        end
        
        function backward(self,error,alpha)
            index = self.N;
            curDerivative = 0;
            curSensitivity = 0;
            oldSensitivity = 0;

            for i = index:-1:1
                if self.layerLedger(1,i).transferFunction == "relu"
                    % Compute Derivative
                    d = zeros(length(transpose(self.layerLedger(1,i).a)));
                    for j = 1:1:length(transpose(self.layerLedger(1,i).a))
                        if self.layerLedger(1,i).a(j,1) > 0
                            d(j,j) = 1;
                        else
                            d(j,j) = 0.01;
                        end    
                    end
                    curDerivative = d;
                    % Compute Sensitivity
                    curSensitivity = curDerivative *...
                                 transpose(self.layerLedger(1,i+1).W) *...
                                 oldSensitivity;
                    % Backpropagate
                    self.layerLedger(1,i).backward(alpha,curSensitivity);
                    oldSensitivity = curSensitivity;  
                else
                    % Compute Derivative
                    % Empty Array to compute derivative
                    d = zeros(length(transpose(self.layerLedger(1,i).a)));
                    % Fills in array with derivative
                    for j = 1:1:length(transpose(self.layerLedger(1,i).a))
                        d(j,j) = 1;
                    end
                    curDerivative = d;
                    % Compute Sensitivity
                    curSensitivity = -2 * curDerivative * error;
                    % Backpropagate
                    self.layerLedger(1,i).backward(alpha,curSensitivity);
                    oldSensitivity = curSensitivity;
                end    
            end
        end   
    end
end    