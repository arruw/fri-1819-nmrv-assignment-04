function [x,y] = generate_spiral_trajectory(N)
v=linspace(5*pi,0,N);
x=cos(v).*v;
y=sin(v).*v;
end

