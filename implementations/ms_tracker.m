function [n_frames, n_failures, imgs] = ms_tracker(dataset_path, sequence, bins, eps, sigma, steps, alpha, render)
% INPUT:
% dataset_path: path to the vot challange ("./resources/vot/2018")
% sequence: vot sequence name ("bolt1")
% bins: number of bins in color histograms (16)
% eps: some small number (0.0000000000000000001)
% sigma: epanechnikov kernel sigma (0.2)
% steps: max number of steps for meanshift (20)
% alpha: update model weight, some small value between 0 and 1 (0)
% render: render frames (true)
% OUTPUT: 
% n_frames: total number of frames
% n_failures: number of failures
% imgs: if render == true => cell array of annotated frames

% name of tracker
tracker_name = 'ms';

use_reinitialization = true;
skip_after_fail = 5;

% specify initialize and update function
initialize = str2func(sprintf('%s_initialize', tracker_name));
update = str2func(sprintf('%s_update', tracker_name));

% read all frames in the folder
base_path = fullfile(dataset_path, sequence);
img_dir = dir(fullfile(base_path, '*.jpg'));

% read ground-truth
% bounding box format: [x,y,width, height]
gt = dlmread(fullfile(base_path, 'groundtruth.txt'));
if size(gt,2) > 4
    % ground-truth in format: [x0,y0,x1,y1,x2,y2,x3,y3], convert:
    X = gt(:,1:2:end);
    Y = gt(:,2:2:end);
    X0 = min(X,[],2);
    Y0 = min(Y,[],2);
    W = max(X,[],2) - min(X,[],2) + 1;
    H = max(Y,[],2) - min(Y,[],2) + 1;
    gt = [X0, Y0, W, H];
end

start_frame = 1;
n_failures = 0;

if render
    figure(1); clf;
end
frame = 1;
imgs = {};
while frame <= numel(img_dir)
   
    % read frame
    img = imread(fullfile(base_path, img_dir(frame).name));
    
    if frame == start_frame
        % initialize tracker
        [tracker, bbox] = initialize(img, gt(frame,:), bins, eps, sigma);
    else
        % update tracker (target localization + model update)
        [tracker, bbox] = update(tracker, img, bins, eps, sigma, steps, alpha);
    end
        
    if render
        hold on;
        % show image
        imshow(img);
        rectangle('Position',bbox, 'LineWidth',2, 'EdgeColor','y');
        % show current number of failures
        text(12, 15, sprintf('Failures: %d\nFrame: #%d', n_failures, frame), 'Color','w', ...
            'FontSize',10, 'FontWeight','normal', ...
            'BackgroundColor','k', 'Margin',1);
        drawnow;
        imgs{frame} = get_frame_image(gca);
    end
    
    % detect failures and reinit
    if use_reinitialization
        area = rectint(bbox, gt(frame,:));
        if area < eps && use_reinitialization
            %disp('Failure detected. Reinitializing tracker...');
            frame = frame + skip_after_fail - 1;  % skip 5 frames at reinit (like VOT)
            start_frame = frame + 1;
            n_failures = n_failures + 1;
        end
    end
    
    frame = frame + 1;
end

n_frames = frame;

end  % endfunction

function img = get_frame_image(ax)
    ax.Units = 'pixels';
    pos = ax.Position;
    ti = ax.TightInset+10;
    F = getframe(ax);
    img = frame2im(F);
end

