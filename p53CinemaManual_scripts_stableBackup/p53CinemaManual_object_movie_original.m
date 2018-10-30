%%
%
classdef p53CinemaManual_object_movie < handle
    properties
        obj_data;
        size = [50,50];
        resizeNumber = 0.5;
        framerate = 1/15; %in powerpoint the max fps is 15. To go faster frames must be cut out.
        outputdirectory;
    end
    events
        
    end
    methods
        %% Constructor
        function obj = p53CinemaManual_object_movie(obj_data)
            obj.obj_data = obj_data;
            %%
            % create folder to hold output movies
            if ~isdir(fullfile(obj_data.outputdirectory,'MOVIES'))
                mkdir(fullfile(obj_data.outputdirectory,'MOVIES'));
            end
            obj.outputdirectory = fullfile(obj_data.outputdirectory,'MOVIES');
        end      
        %%
        %
        function obj = movies4AllCells(obj)
            [obj] = p53CinemaManual_method_movie_movies4AllCells(obj);
        end
        %% Delete function
        function delete(obj)
            delete(obj.obj_data);
        end
    end
end