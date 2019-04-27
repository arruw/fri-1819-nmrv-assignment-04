function demo_tracker()

% TODO: put name oy four tracker here
tracker_name = 'mosse';
% TODO: select a sequence you want to test on
sequence = 'sunshade';
% TODO: give path to the dataset folder
dataset_path = './resources/vot2014';

params = struct;
params.sigma = 2;
params.peak = 100;
params.s2tr = 2;
params.alpha = 0.125;
params.psr = 0.05;
params.lambda = 1e-5;

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

figure(1); clf;
frame = 1;
tic;
while frame <= numel(img_dir)
    
    % read frame
    img = imread(fullfile(base_path, img_dir(frame).name));
    
    if frame == start_frame
        % initialize tracker
        cla;
        tracker = initialize(img, gt(frame,:), params);
        bbox = gt(frame, :);
    else
        % update tracker (target localization + model update)
        [tracker, bbox] = update(tracker, img, params);
    end
    
    % show image
%     subplot(4, 4, 1:12);
%     cla;
    imshow(img);
    hold on;
    color = 'y';
    if tracker.m(end) < params.peak*params.psr
        color = 'r';
    end
    rectangle('Position',bbox, 'LineWidth',2, 'EdgeColor',color);
    % show current number of failures & frame number
    text(12, 15, sprintf('Failures: %d\nFrame: #%d\nFPS: %d\nPSR: %d', n_failures, frame, round(frame/toc), round(tracker.m(end))), 'Color','w', ...
        'FontSize',10, 'FontWeight','normal', ...
        'BackgroundColor','k', 'Margin',1);    
    hold off;
    drawnow;
    
%     subplot(4, 4, 13:16);
%     hold on;
%     cla;
%     plot(1:(frame-start_frame+1), tracker.m, 'b'); ylim([0 params.peak]);
%     plot([1 frame-start_frame+1], [params.peak*params.psr params.peak*params.psr], 'r'); ylim([0 params.peak]);
%     hold off;
%     drawnow;
    
    % detect failures and reinit
    if use_reinitialization
        area = rectint(bbox, gt(frame,:));
        if area < eps && use_reinitialization
            disp('Failure detected. Reinitializing tracker...');
            frame = frame + skip_after_fail - 1;  % skip 5 frames at reinit (like VOT)
            start_frame = frame + 1;
            n_failures = n_failures + 1;
        end
    end
    
    frame = frame + 1;
    
end

end  % endfunction

