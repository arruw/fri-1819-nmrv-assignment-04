name = [];
fps = [];
f2o = [];
n_frames = [];

baseline_path = './workspace/results/mosse_20_20_0125/baseline';
sequences = dir(baseline_path);
for i = 3:length(sequences)
    sequence = sequences(i).name;
    
    time_path = char(baseline_path+"/"+sequence+"/"+sequence+"_time.txt");
    times = readtable(time_path, 'ReadVariableNames',false);
    
    name = [name string(sequence)];
    fps = [fps (size(times,1)/sum(times.Var1))];
    f2o = [f2o (times.Var1(1)/(sum(times.Var1(2:end)/(size(times,1)-1))))];
    n_frames = [n_frames (size(times,1))];
end

results = table(name', fps', f2o', n_frames','VariableNames',{'Sequence','FPS','F2O','Frames'});
writetable(results, './report/results/time_analysis.csv');
