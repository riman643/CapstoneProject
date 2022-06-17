classdef ExperienceBuffer<handle
% This Objects Hosts a List of Objects that are created in the constructor

    properties
        experienceList = ReplayExperience(0,0,0,0);
    end

    methods
        function obj = ExperienceBuffer()
            emptyState = zeros(1,160,'uint32');
            emptyAction = zeros(1,64,'uint32');
            exp = ReplayExperience(emptyState, emptyAction, 0, emptyState);
            for n = 1000:-1:1        
                obj.experienceList(n) = exp;        
            end
        end
    end
end
