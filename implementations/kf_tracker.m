function kf_tracker()

rng('default');
rng(1);

% TODO: put name oy four tracker here
tracker_name = 'kf';
% TODO: select a sequence you want to test on
sequence = 'bag';
% TODO: give path to the dataset folder
dataset_path = './resources/vot2015';

params = struct;
params.model = "RW";
%params.q = 20;          % (h+w)
params.r = 1;
params.sigma = 0.2;     % epanechnikov kernel sigma
params.bins = 8;        % number of histogram bins
params.N = 100;          % number of particles
params.alpha = 0.01;
params.plot = false;
% params.sigma = 2;
% params.peak = 100;
% params.s2tr = 2;
% params.alpha = 0.125;
% params.psr = 0.05;
% params.lambda = 1e-5;

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
while frame <= min(numel(img_dir), size(gt, 1))
    
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
    rectangle('Position',bbox, 'LineWidth',2, 'EdgeColor', 'y');
    % show current number of failures & frame number
    text(12, 15, sprintf('Failures: %d\nFrame: #%d\nFPS: %d', n_failures, frame, round(frame/toc)), 'Color','w', ...
        'FontSize',10, 'FontWeight','normal', ...
        'BackgroundColor','k', 'Margin',1);
    plot_particles(tracker, params);
    hold off;
    drawnow;
        
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

function plot_particles(tracker, params) 
    if ~params.plot
       return 
    end
        
    for i = 1:size(tracker.particles, 1) 
        if tracker.weights(i) == 0
            continue;
        end
        
        plot(tracker.particles(i, 1), tracker.particles(i, 2), 'y.', 'MarkerSize', tracker.weights(i)*params.N*3.5/2);
        plot(tracker.particles(i, 1), tracker.particles(i, 2), 'ko', 'MarkerSize', tracker.weights(i)*params.N*1/2);
    end

    switch params.model
        case "RW"
            
        case "NCV"
            plot(...
                [tracker.center(1) tracker.center(1)+(tracker.center(3)*5)], ...
                [tracker.center(2) tracker.center(2)+(tracker.center(4)*5)], ...
                'r-');
        case "NCA"
            
    end
    
end
