% best found parameters
bins = 3;
eps = 1e-7;
alpha = 0;
sigma = 0.2;

t_sequences = ["car1",""];

for sequence = t_sequences

    outputFile = char(fullfile(pwd,'report','results',strcat(sequence, '.avi')))
    outputVideo = VideoWriter(outputFile);
    outputVideo.FrameRate = 15;
    
    [~, ~, imgs] = ms_tracker(...
                './resources/vot',...
                sequence,...
                bins,...
                eps,...
                sigma,...
                10,...  % steps
                alpha,...
                true); % render

    open(outputVideo);
    size1 = size(imgs{1}, 1);
    size2 = size(imgs{1}, 2);
    for i = 1:length(imgs)
        if size(imgs{i}, 1) ~= size1 || size(imgs{i}, 2) ~= size2
            continue;
        end
        writeVideo(outputVideo, imgs{i}); 
    end
    close(outputVideo);
    clear outputVideo;
end
        

