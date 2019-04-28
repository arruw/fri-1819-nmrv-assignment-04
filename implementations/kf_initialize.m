function [state, location] = kf_initialize(I, region, params)

    % get bounding box
    bbox = get_bbox(region);
    
    % extract template
    center = [bbox(1)+bbox(3)/2 bbox(2)+bbox(4)/2];
    template = get_patch(I, center, 1, [bbox(3) bbox(4)]);
    
    q = (bbox(3)+bbox(4))/10;
    
    % construct state
    state = struct;
    state.bbox = bbox;
    state.cos_window = create_cos_window([bbox(3) bbox(4)]);
    state.kernel = create_epanechnik_kernel(bbox(3), bbox(4), params.sigma);
    state.hist = extract_histogram(template, params.bins, state.kernel);
%     state.color_pdf = extract_color_pdf(template, params.bins, state.cos_window);
    [state.A, state.C, state.Q, state.R] = generate_model(params.model, q, params.r);
    
    state.center = [center 0 0];
    state.particles = mvnrnd(repmat([center 0 0],params.N,1),state.Q);
    state.weights = ones(params.N, 1);
    
    % location
    location = bbox;
    
end

function bbox = get_bbox(region)
    % If the provided region is a polygon ...
    if numel(region) > 4
        x1 = round(min(region(1:2:end)));
        x2 = round(max(region(1:2:end)));
        y1 = round(min(region(2:2:end)));
        y2 = round(max(region(2:2:end)));
        region = round([x1, y1, x2 - x1, y2 - y1]);
    else
        region = round([round(region(1)), round(region(2)), ... 
            round(region(1) + region(3)) - round(region(1)), ...
            round(region(2) + region(4)) - round(region(2))]);
    end

    if(mod(region(3), 2) == 0) region(3) = region(3)+1; end
    if(mod(region(4), 2) == 0) region(4) = region(4)+1; end
    
    bbox = region;
end