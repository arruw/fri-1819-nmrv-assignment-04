function hist = extract_color_pdf(I,bins,cos_window)
    
    I = double(I) .* cos_window;
    
    hist = [...
        imhist(I(:, :, 1), bins)'... % red
        imhist(I(:, :, 2), bins)'... % green
        imhist(I(:, :, 3), bins)'... % blue
        ];
    
    hist = hist / sum(hist);
end

