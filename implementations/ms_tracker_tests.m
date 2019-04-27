clear; clc;

t_bins = 3:4:16;
t_eps = [1e-10 1e-7 1e-4];
t_alphas = [0 0.001 0.01];
t_sigmas = [0.1 0.2 0.4];
t_sequences = ["ball1","ball2","bolt1","car1","hand"];

r_id = [];
r_sequence = [];
r_bins = [];
r_eps = [];
r_alpha = [];
r_sigma = [];
r_n_frames = [];
r_n_failures = [];
r_time = [];
r_error = [];
ri = 1;

total = size(t_bins, 2)*size(t_eps, 2)*size(t_alphas, 2)*size(t_sigmas, 2)*size(t_sequences, 2);

for sequence = t_sequences
for bins = t_bins
for eps = t_eps
for alpha = t_alphas
for sigma = t_sigmas
       
    if mod(ri, 5) == 0
        T = table(r_id', r_sequence', r_bins', r_eps', r_alpha', r_sigma', r_n_frames', r_n_failures', r_time' , r_error',...
            'VariableNames',{'id', 'Sequence', 'n_bins', 'eps', 'alpha', 'sigma', 'n_frames', 'n_failures', 'time', 'error'});
        writetable(T, './report/results/ms_tracker_comparison_1.csv');
    end
    
    try
        tic;
        [n_frames, n_failures] = ms_tracker(...
            './resources/vot',...
            sequence,...
            bins,...
            eps,...
            sigma,...
            20,...  % steps
            alpha,...
            false); % render
        dt = toc;

        r_id = [r_id ri];
        r_sequence = [r_sequence sequence];
        r_bins = [r_bins bins];
        r_eps = [r_eps eps];
        r_alpha = [r_alpha alpha];
        r_sigma = [r_sigma sigma];
        r_n_frames = [r_n_frames n_frames];
        r_n_failures = [r_n_failures n_failures];
        r_time = [r_time dt];
        r_error = [r_error 0];
        
        disp(ri+"/"+total+" in "+dt+ "s")
    catch
        
        r_id = [r_id ri];
        r_sequence = [r_sequence sequence];
        r_bins = [r_bins bins];
        r_eps = [r_eps eps];
        r_alpha = [r_alpha alpha];
        r_sigma = [r_sigma sigma];
        
        r_n_frames = [r_n_frames 0];
        r_n_failures = [r_n_failures 0];
        r_time = [r_time 0];
        r_error = [r_error 1];
        
        disp(ri+"/"+total+" ERROR!")
    end

    ri = ri + 1;
    
end
end
end
end
end

T = table(r_id', r_sequence', r_bins', r_eps', r_alpha', r_sigma', r_n_frames', r_n_failures', r_time' , r_error',...
    'VariableNames',{'id', 'Sequence', 'n_bins', 'eps', 'alpha', 'sigma', 'n_frames', 'n_failures', 'time', 'error'});
writetable(T, './report/results/ms_tracker_comparison_1.csv');


