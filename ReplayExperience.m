classdef ReplayExperience<handle
    properties
        s  % First State Vector
        a  % Action Vector
        r  % Reward from Action
        s1 % State Vector after Action
        t  % Is Terminal state vector
    end
    
    methods
        function obj = ReplayExperience(iState, action, reward, cState)
            obj.s = iState;
            obj.a = action;
            obj.r = reward;
            obj.s1 = cState;
        end
    end    
end