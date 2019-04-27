load('helpers/tabulated.mat');

kernels = {
    {'gaussian-11-05', gaussian_shadow(11, 0.5)},
    {'gaussian-15-05', gaussian_shadow(15, 0.5)},
    {'gaussian-19-05', gaussian_shadow(19, 0.5)},
    {'gaussian-23-05', gaussian_shadow(23, 0.5)},

    {'gaussian-11-1',  gaussian_shadow(11, 1)},
    {'gaussian-15-1',  gaussian_shadow(15, 1)},
    {'gaussian-19-1',  gaussian_shadow(19, 1)},
    {'gaussian-23-1',  gaussian_shadow(23, 1)},

    {'gaussian-11-2',  gaussian_shadow(11, 2)},
    {'gaussian-15-2',  gaussian_shadow(15, 2)},
    {'gaussian-19-2',  gaussian_shadow(19, 2)},
    {'gaussian-23-2',  gaussian_shadow(23, 2)},

    % Epanechnikov
    {'epanechnikov-11', epanechnikov_shadow(11)},    
    {'epanechnikov-15', epanechnikov_shadow(15)},
    {'epanechnikov-19', epanechnikov_shadow(19)},
    {'epanechnikov-23', epanechnikov_shadow(23)}
};

responses = random_response(10);
steps = 20;

% This allow us to click on figure and trigger mean shif algorithm
figure(1);
hold on;
imagesc(responses, 'ButtonDownFcn', {@button_down_handler,responses,kernels{1}{2}, steps});
text(2, 5, 'Click on image to trigger mean shift.');
axis([0 100 0 100]);
axis square;

% This allow us to visualize multiple kernels
% figure(1);
% hold on;
% axis([0 100 0 100]);
% axis square;
% imagesc(responses);
% pause(1);
% 
% results = {}
% for ki = [1:size(kernels, 1)]
%     figure(1);
%     hold on;
%     axis([0 100 0 100]);
%     axis square;
%         
%     imagesc(responses);
%     text(2, 5, kernels{ki}{1}, 'FontSize',20);
%     
%     for cx = [1:10:100]
%         for cy = [1:10:100]
%             test(cx, cy, responses, kernels{ki}{2}, steps);
%         end
%     end
%     
%     results{ki} = get_frame_image(gca);
%     clf;
% end
% result = montage(results, 'Size', [4 4]);
% imwrite(result.CData, './report/results/mean-shift-comparison-random.png');

function test(x, y, relief, kernel, steps)
    % Find path
    [xs, ys] = meanshift([x y], relief, kernel, steps);
        
    if size(xs, 2) == 1
        return
    end
    
    % Plot click point & square of neighbourhood
    plot(x, y, 'r.','MarkerSize', 20);
    %plot_square(x, y, size(kernel, 1));
    
    % Plot path & end position
    plot(xs(end), ys(end), 'rx','MarkerSize', 20);
    plot(xs, ys, '-k');
    
    % Plot number of steps
    steps = size(xs, 2)-1;
    text(x, y, "  "+steps, 'FontSize',14);
end

function [x1, y1, x2, y2] = square_points(x, y, n)
    x1 = ceil(x-n/2);
    y1 = ceil(y-n/2);
    x2 = x1 + n-1;
    y2 = y1 + n-1;
end

function plot_square(x, y, n)
    [x1, y1, x2, y2] = square_points(x, y, n);
    
    x = [x1, x2, x2, x1, x1];
    y = [y1, y1, y2, y2, y1];
    plot(x, y, '--r', 'LineWidth', 1);
end

function shadow = gaussian_shadow(n, sigma)
    shadow = -fspecial('gaussian', [n n], sigma);
end

function shadow = epanechnikov_shadow(n)
    shadow = -ones(n)./(n.^2);
end

function button_down_handler(src, eventdata, relief, kernel, steps)
    coordinates = get(get(src,'Parent'),'CurrentPoint'); 
    coordinates = round(coordinates(1,1:2));
    x = coordinates(1);
    y = coordinates(2);

    test(x, y, relief, kernel, steps);
end

function img = get_frame_image(ax)
    ax.Units = 'pixels';
    pos = ax.Position;
    ti = ax.TightInset+10;
    F = getframe(ax);
    img = frame2im(F);
end

function responses = random_response(i)
    responses = zeros(100, 100);
    
    mask = fspecial('gaussian', [30 30], 4);
    
    for i = [1:i]
        rx = randi([1, 70]);
        ry = randi([1, 70]);
       
        responses([rx:rx+30-1], [ry:ry+30-1]) = responses([rx:rx+30-1], [ry:ry+30-1])+mask;
    end
end

function [xs, ys] = meanshift(start, relief, kernel, steps)

    n = size(kernel, 1);
    pad = ceil(n/2);
    
    % Pad edges with 0
    relief = padarray(relief, [pad pad], min(relief(:)));
    
    xs = [start(1)+pad];
    ys = [start(2)+pad];
    
    [mx, my] = meshgrid(1:max(size(relief)));      
    
    while true
        
        % Extract neighbourhood
        [fx1, fy1, fx2, fy2] = square_points(xs(end), ys(end), n);
        f_relief = relief(fy1:fy2, fx1:fx2);
        f_mx = mx(fy1:fy2, fx1:fx2);
        f_my = my(fy1:fy2, fx1:fx2);
                
        % Calculate new position
        x_n = xs(end);
        %xi = mx+fx1;%-1;
        gx = conv2(abs((xs(end)-f_mx)/n).^2, kernel, 'same');
        sgx = sum(f_relief.*gx, 'all');
        if sgx ~= 0
            x_n = round(sum(f_mx.*f_relief.*gx, 'all')/sgx);
        end
        
        y_n = ys(end);
        %yi = my+fy1,%-1;
        gy = conv2(abs((ys(end)-f_my)/n).^2, kernel, 'same');
        sgy = sum(f_relief.*gy, 'all');
        if sgy ~= 0
            y_n = round(sum(f_my.*f_relief.*gy, 'all')/sgy);
        end
        
        
        % Calculate displacement vector
        dx = x_n - xs(end);
        dy = y_n - ys(end);
                
        % Stop when displacement vector converges
        if (dx == 0 && dy == 0) || steps == 0
            break
        end  
                
        % Append new step
        xs = [xs x_n];
        ys = [ys y_n];
        steps = steps-1;
    end
    
    xs = xs-pad;
    ys = ys-pad;
end