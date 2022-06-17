classdef NetworkLayer<handle
    properties
        W % weights matrix
        b % bias vector
        p % input vector
        a % output vector
        s % sigma
        transferFunction
    end
    methods
        function obj = NetworkLayer(input, output, t)
            if length(input) == 1 && length(output) == 1
                R = input; % dimension of input
                S = output; % dimension of output
                % initialize weights
                gain = sqrt(1/2);
                sigma = (gain/(sqrt(R/S)));
                obj.s = sigma;
                %weights = unifrnd(-1, 1, S, R); 
                weights = 0.05 * normrnd(0,sigma,S,R);
                % initialize bias
                bias = 0.05 * normrnd(0,sigma,S,1);
                obj.W = weights;
                obj.b = bias;
            else
                obj.W = input;  % input in this case is the weight matrix
                obj.b = output; % output in this case is the bias vector
            end
            
            if t == 1
                obj.transferFunction = "relu";
            elseif t == 2
                obj.transferFunction = "none";
            elseif t == 3
                obj.transferFunction = "logsig";
            end
        end
        
        % forward pass
        function output = forward(self, x)
            if length(x) ~= size(self.W, 2)
                error("input dimension mismatch")
            end
            output = self.W * x + self.b;
            if self.transferFunction == "logsig"
                output = logsig(output);
            elseif self.transferFunction == "hardlims"
                output = hardlims(output);
            elseif self.transferFunction == "hardlim"
                output = double(hardlim(output));
            elseif self.transferFunction == "purelin"
                output = purelin(output);
            elseif self.transferFunction == "relu"
                output = extractdata(leakyrelu(dlarray(output)));
            end
            
            self.p = x;
            self.a = output;
        end
        
        % backward function to apply adjustments from errorLoss()
        function backward(self,alpha,sensitivity)
            self.W = self.W - (alpha * sensitivity * transpose(self.p));
            self.b = self.b - (alpha * sensitivity);
        end
        
        % method to print the weights and biases
        function print(self)
            disp("Weights: ");
            disp(self.W);
            disp("Biases:  ");
            disp(self.b);
        end

    end
end

        