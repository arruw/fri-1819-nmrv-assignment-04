function hist = extract_color_pdf(I,bins,cos_window)
    
    I = double(I);
%     I(:, :, 1) = I(:, :, 1) .* cos_window;
%     I(:, :, 2) = I(:, :, 2) .* cos_window;
%     I(:, :, 3) = I(:, :, 3) .* cos_window;

    hist = [...
        imhist(I(:, :, 1), bins)'... % red
        imhist(I(:, :, 2), bins)'... % green
        imhist(I(:, :, 3), bins)'... % blue
        ];
    
    hist = hist / sum(hist);
end

