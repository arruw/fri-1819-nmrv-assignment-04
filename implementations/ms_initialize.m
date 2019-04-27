function [state, bbox] = ms_initialize(I, bbox, bins, eps, sigma)
   
    x1 = round(bbox(1));
    x2 = round(x1 + bbox(3));
    y1 = round(bbox(2));
    y2 = round(y1 + bbox(4));
       
    if mod(x2 - x1 + 1, 2) == 0
       x2 = x2 + 1; 
    end
    
    if mod(y2 - y1 + 1, 2) == 0
       y2 = y2 + 1; 
    end
        
    template = I(y1:y2, x1:x2, :);
          
    state = struct('template', template, 'size', [x2 - x1 + 1, y2 - y1 + 1]);
    state.region = [x1 y1 x2 y2];   
    state.kernel = create_epanechnik_kernel(state.size(2), state.size(1), sigma);
    state.q = extract_histogram(template, bins, state.kernel);
    
    kx2 = floor(state.size(1) / 2);
    ky2 = floor(state.size(2) / 2);
    
    [state.mx, state.my] = meshgrid(-kx2:kx2, -ky2:ky2);
    
    bbox = [x1, y1, state.size];
end