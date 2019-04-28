% YUY2_1280x720
% YUY2_640x360
imaqreset
imaqmex('feature','-limitPhysicalMemoryUsage',false);
vidObj = videoinput('linuxvideo', 1, 'YUY2_640x360');
vidObj.ReturnedColorspace = 'rgb';
vidObj.Timeout = 500;
triggerconfig(vidObj, 'manual');

start(vidObj)

global flag_stop flag_init;
flag_init = true;
flag_stop = false;

params = struct;
params.model = "RW";
params.r = 1;
params.sigma = 0.2;     % epanechnikov kernel sigma
params.bins = 20;        % number of histogram bins
params.N = 30;         % number of particles
params.alpha = 0.01;
params.plot = true;

frame = 1;
while true
    if flag_stop
       break; 
    end
    
    I = getsnapshot(vidObj);
    
    if flag_init
        figure(1); clf;
        subplot(7, 1, 1:6);
        imagesc(I);
        uicontrol('Position', [5 5 100 20], 'String', 'Init', 'Callback', @initialize_f);
        uicontrol('Position', [110 5 100 20], 'String', 'Stop', 'Callback', @stop_f);
        drawnow;
        frame = 1;
        flag_init = false;
        bbox = getrect;
        tic;
        tracker = kf_initialize(I, bbox, params); 
    else
       [tracker, bbox] = kf_update(tracker, I, params); 
    end
    
    hold on;
    if mod(frame, 20) == 0
       cla;
    end
    imagesc(I); 
    rectangle('Position',bbox, 'LineWidth',2);
    text(5, 35, sprintf('Frame: #%d\nFPS: %d', frame, round(frame/toc)), 'Color','w', ...
        'FontSize',10, 'FontWeight','normal', ...
        'BackgroundColor','k', 'Margin',1);   
    hold off;
    drawnow;
    
    frame = frame + 1;
end

stop(vidObj);
delete(vidObj);
clear all;

function initialize_f(src, evt)
    global flag_init;
    flag_init = true;
end

function stop_f(src, evt)
    global flag_stop;
    flag_stop = true;
end