function [state, location] = kf_initialize(I, region, params)

    % get bounding box
    bbox = get_bbox(region);
    
    % extract template
    center = [bbox(1)+bbox(3)/2 bbox(2)+bbox(4)/2];
    template = get_patch(I, center, 1, [bbox(3) bbox(4)]);
    
    q = (bbox(3)+bbox(4)) * min(bbox(3),bbox(4))/max(bbox(3),bbox(4));
    
    % construct state
    state = struct;
    state.bbox = bbox;
    state.kernel = create_epanechnik_kernel(bbox(3), bbox(4), params.sigma);
    state.hist = extract_histogram(template, params.bins, state.kernel);
    [state.A, ~, state.Q, ~] = generate_model(params.model, q, params.r);
    
    switch params.model
        case "RW"
            state.center = [center];
        case "NCV"
            state.center = [center 0 0];
        case "NCA"
            state.center = [center 0 0 0 0];
    end
    
    state.particles = mvnrnd(repmat(state.center,params.N,1),state.Q);
    state.weights = ones(params.N, 1) / params.N;
    
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