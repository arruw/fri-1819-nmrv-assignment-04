clear; clc;
rng('default');
rng(1);

[x,y] = generate_trajectory(50);

figure(1); clf;
plot_kalman(1, 5, 1, x, y, "NCV", 100,  1);
plot_kalman(1, 5, 2, x, y, "NCV", 5,    1);
plot_kalman(1, 5, 3, x, y, "NCV", 1,    1);
plot_kalman(1, 5, 4, x, y, "NCV", 1,    5);
plot_kalman(1, 5, 5, x, y, "NCV", 1,    100);

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

    end;
end

function plot_kalman(cols, rows, i, x, y, model, q, r)
    label = model + " q=" + num2str(q) + " r=" + (r);
    subplot(cols,rows,i); plot(x, y, '-o'); axis square; title(label);
    [sx, sy] = kalman_apply(x, y, model, q, r);
    hold on;
    plot(sx, sy, '-o');
    hold off; drawnow;
end
