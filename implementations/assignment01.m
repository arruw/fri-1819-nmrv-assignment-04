rng('default');
rng(1);

% [x,y] = generate_random_trajectory(30);
[x,y] = generate_spiral_trajectory(30);

figure(1); clf;
plot_kalman(3, 5, 1, x, y,  "RW", 100,  1);
plot_kalman(3, 5, 2, x, y,  "RW", 5,    1);
plot_kalman(3, 5, 3, x, y,  "RW", 1,    1);
plot_kalman(3, 5, 4, x, y,  "RW", 1,    5);
plot_kalman(3, 5, 5, x, y,  "RW", 1,    100);

plot_kalman(3, 5, 6, x, y,  "NCV", 100,  1);
plot_kalman(3, 5, 7, x, y,  "NCV", 5,    1);
plot_kalman(3, 5, 8, x, y,  "NCV", 1,    1);
plot_kalman(3, 5, 9, x, y,  "NCV", 1,    5);
plot_kalman(3, 5, 10, x, y, "NCV", 1,    100);

plot_kalman(3, 5, 11, x, y, "NCA", 100,  1);
plot_kalman(3, 5, 12, x, y, "NCA", 5,    1);
plot_kalman(3, 5, 13, x, y, "NCA", 1,    1);
plot_kalman(3, 5, 14, x, y, "NCA", 1,    5);
plot_kalman(3, 5, 15, x, y, "NCA", 1,    100);

function [sx, sy] = kalman_apply(x, y, model, q, r)
    [A,C,Q,R] = generate_model(model, q, r);

    sx=zeros(1,length(x));
    sy=zeros(1,length(y));

    sx(1)=x(1);
    sy(1)=y(1);

    state=zeros(size(A,1),1);
    state(1)=x(1);
    state(2)=y(1);
    covariance=eye(size(A,1));

    for i=2:length(x)
        [state,covariance]=...
            kalman_update(A,C,Q,...
            R,[x(i),y(i)]',state,covariance);

        sx(i)=state(1);
        sy(i)=state(2);

    end
end

function plot_kalman(cols, rows, i, x, y, model, q, r)
    label = model + " q=" + num2str(q) + " r=" + (r);
    subplot(cols,rows,i); plot(x, y, 'r-o'); axis square; title(label); drawnow;
    
    [sx, sy] = kalman_apply(x, y, model, q, r);
    
    hold on;
    plot(sx, sy, 'b-o');
    hold off;
    drawnow;
end
