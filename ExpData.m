%% A class to interact with time-lapse fluorescence microscopy data
% ... at the most basic level
classdef ExpData
    %% properties
    % # wavelenth: a container.Map object where the keys are ordinal
    % numbers of the wavlengths in the order is was acquired and the values
    % are the names of the wavelengths.
    % # time: a container.Map object where the keys are the ordinal numbers
    % of the time points in the order it was taken and the values are
    % MATLAB Serial Date Numbers.
    % # position_xy: a container.Map object where the keys are the ordinal
    % numbers of the positions in the order it was designated and the
    % values are the (x,y) coordinates of the stage at that position in
    % micrometers.
    % # position_z: a container.Map object where the keys are the ordinal
    % numbers of the z-positions in the order it was acquired and each
    % value is the z coordinate of the objective in micrometers.
    % # filename_image: a 4D cell that contains the name of the image file
    % that corresponds to a *position_xy*, *wavelength*, *time*, and
    % *position_z*, respectively indexed in that order.
    % # rootdir_image: the directory that contains the *filename_image*
    % files.
    % # pixel_size: the physical distance each pixel represents in an
    % image in micrometers. This number depends on the magnification of the
    % objective and the physical size of the camera sensor grid.
    % # stepsize_z: the distance between any two z-positions.
    % # image_height: the number of pixels from the top to the bottom of
    % the image.
    % # image_width: the number of pixels from the left to the right of the
    % image.
    % # exposure: a container.Map object where the keys are the wavelength
    % names and the values are the lengths of exposure in milliseconds.
    % # binning: the binning that was used when the image was collected.
    properties
        wavelength;
        time;
        position_xy;
        position_z;
        filename_image;
        rootdir_image;
        pixel_size;
        stepsize_z;
        image_height;
        image_width;
        exposure;
        binning;
    end
    %% methods
    %
    methods
        %% constructor
        %
        function obj = ExpData(csvfile, my_binning, my_image_height, my_image_width, my_pixel_size, my_stepsize_z)
            % process the csvfile
            
            % assign values to the remaining properties
            obj.rootdir_image = 'not yet assigned';
            obj.pixel_size = my_pixel_size;
            obj.stepsize_z = my_stepsize_z;
            obj.image_height = my_image_height;
            obj.image_width = my_image_width;
            obj.binning = my_binning;
        end
        %% get_image
        %
        function img = get_image()
        end
        %% get_timetrace
        %
        function ttrace = get_timetrace()
        end
    end
end