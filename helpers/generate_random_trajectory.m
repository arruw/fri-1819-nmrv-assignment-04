function [x,y] = generate_random_trajectory(N, scale, alpha)

x = ones(N, 1);
y = ones(N, 1);

d = round(smoothdata(rand(N,2)*scale-(scale*alpha/2)));

for i = 2:N
    x(i) = x(i-1) + d(i, 1);
    y(i) = y(i-1) + d(i, 2);
end

end

