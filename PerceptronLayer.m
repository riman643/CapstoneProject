classdef PerceptronLayer<handle
    properties
        W % weights matrix
        b % bias vector
        p % input vector
        transferFunction
    end
    methods
        function obj = PerceptronLayer(input, output, t)
            if length(input) == 1 && length(output) == 1
                R = input; % dimension of input
                S = output; % dimension of output
                % initialize weights
                weights = unifrnd(-1, 1, S, R); 
                % initialize bias
                bias = unifrnd(-1, 1, S, 1);
                obj.W = weights;
                obj.b = bias;
            else
                obj.W = input;  % input in this case is the weight matrix
                obj.b = output; % output in this case is the bias vector
            end
            obj.transferFunction = t;
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
            end
            
            self.p = x;
        end
        
        % backward function to apply adjustments from errorLoss()
        function backward(self, errors)
            %result -1;
            if size(errors, 1) ~= size(self.W, 1)
                errorMessage = "The error vector passed to backward()"...
                    + " has the wrong number of neurons. The input error"...
                    + " vector has height " + size(errors, 1) + ", but"...
                    + " you need the height of the weight vector, which"... 
                    + " is " + size(self.W, 1);
                error(char(errorMessage));
                return;
            end
            
            %update the weighs (self.W), based on the errors vector
            %NOTE: Doing this requires that the class inherit from handle.
            
            %disp("Weight before = ");
            %disp(self.W);
            %disp("Bias before = ");
            %disp(self.b);
            self.W = self.W + (errors * transpose(self.p));
            self.b = self.b + errors;
            %disp("Weight after = ");
            %disp(self.W);
            %disp("Bias after = ");
            %disp(self.b);
            
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

        