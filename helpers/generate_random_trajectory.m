function [x,y] = generate_random_trajectory(N)

x = zeros(N);
y = zeros(N);

d = smoothdata(rand(N,2)*10-5);

for i = 2:N
    x(i) = x(i-1) + d(i, 1);
    y(i) = y(i-1) + d(i, 2);
end

end

