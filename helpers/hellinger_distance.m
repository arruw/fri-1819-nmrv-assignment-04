function d = hellinger_distance(a,b)
% INPUTS
% a & b - discrete probability distribution (color histograms)
% OUTPUTS
% d - hellinger distance

d = norm(a-b)/sqrt(2);
end

