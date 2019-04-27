% YUY2_1280x720
% YUY2_640x360
vidObj = videoinput('linuxvideo', 1, 'YUY2_640x360');
vidObj.ReturnedColorspace = 'rgb';
vidObj.Timeout = 500;
triggerconfig(vidObj, 'manual');

start(vidObj)

global flag_stop flag_init;
flag_init = true;
flag_stop = false;

params = struct;
params.sigma = 2;
params.peak = 100;
params.s2tr = 2;
params.alpha = 0.125;
params.psr = 0.05;
params.lambda = 1e-5;

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
        tracker = mosse_initialize(I, bbox, params); 
    else
       [tracker, bbox] = mosse_update(tracker, I, params); 
    end
    
    subplot(7, 1, 1:6); 
    hold on;
    if mod(frame, 20) == 0
       cla;
    end
    imagesc(I); 
    color = 'y';
    if tracker.m(end) < params.peak*params.psr;
        color = 'r';
    end
    rectangle('Position',bbox, 'LineWidth',2, 'EdgeColor',color);
    text(5, 35, sprintf('Frame: #%d\nFPS: %d', frame, round(frame/toc)), 'Color','w', ...
        'FontSize',10, 'FontWeight','normal', ...
        'BackgroundColor','k', 'Margin',1);   
    hold off;
        
    subplot(7, 1, 7);
    hold on;
    if mod(frame, 20) == 0
       cla;
    end
    plot(1:frame, tracker.m, 'b'); ylim([0 params.peak*0.2]);
    plot([1 frame], [params.peak*params.psr params.peak*params.psr], 'r'); ylim([0 params.peak*0.2]);
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