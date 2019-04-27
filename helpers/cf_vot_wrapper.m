function cf_vot_wrapper(varargin)
    % wrapper function for VOT-like interface
    %
    % This function is a wrapper for the DACF tracker using the VOT interface for input/output
    % data loading (i.e. images, initial region) and storing (i.e. output.txt or trax output)
    %
    % Input:
    % - varargin[OutputDir] (string): path to dir where some output images/data should be stored

    cleanup = onCleanup(@() exit() ); % Always call exit command at the end to terminate Matlab!
    RandStream.setGlobalStream(RandStream('mt19937ar', 'Seed', sum(clock))); % Set random seed to a different value every time as required by the VOT rules.

    [handle, image_path, region] = vot('polygon'); % Obtain communication object
    image = imread(image_path); % Read first image from file

    % matlab indexing: starts with (1,1); gt starts with (0,0)
    if numel(region) > 4
        % all x,y points shifted by 1
        region = region + 1;
    else
        % shift x,y by 1
        region(1:2) = region(1:2) + 1;
    end

    % TODO: call your own tracker initialization script
    tracker = mosse_initialize(image, region);

    while true

        [handle, image_path] = handle.frame(handle); % Get the next frame

        if isempty(image_path) % Are we done?
            break;
        end;

        image = imread(image_path);
        
        % TODO: call your own target localization (tracker update) script
        tracker = mosse_update(tracker, image);
        region = tracker.bb;

        % matlab indexing: starts with (1,1); gt starts with (0,0)
        if numel(region) > 4
            % all x,y points shifted by 1
            region = region - 1;
        else
            % shift x,y by 1
            region(1:2) = region(1:2) - 1;
        end

        handle = handle.report(handle, double(region)); % Report position for the given frame

    end;

    handle.quit(handle); % Output the results and clear the resources

end  % endfunction