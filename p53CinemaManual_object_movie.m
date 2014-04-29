%%
%
classdef p53CinemaManual_object_movie < handle
    properties
        master;
        size = [50,50];
        framerate;
    end
    events
        
    end
    methods
        %% Constructor
        function obj = p53CinemaManual_object_cellTracker(master)
            obj.master = master;
            %%
            % create folder to hold output movies
            if ~isdir(fullfile(master.outputdirectory,'MOVIES'))
                mkdir(fullfile(master.outputdirectory,'MOVIES'));
            end
        end      
        %%
        %
        function obj = movies4AllCells(obj)
            [obj] = p53CinemaManual_method_movie_movies4AllCells(obj);
        end
        %% Delete function
        function delete(obj)
            % Ask if the user wants to save the annotation
            delete(obj.gui_cellTracker);
        end
    end
end