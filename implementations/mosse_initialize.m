function [state, location] = mosse_initialize(I, region, params)

    % get search bounding box
    bbox_s = get_search_bbox(region);
    
    % get target bounding box
    bbox_t = round([bbox_s(1)-bbox_s(3)*(params.s2tr-1)/2 bbox_s(2)-bbox_s(4)*(params.s2tr-1)/2 bbox_s(3)*params.s2tr bbox_s(4)*params.s2tr]);
    
    % get cosine window
    Cw = create_cos_window([bbox_t(3) bbox_t(4)]);
    
    % get target patch
    P = double(rgb2gray(get_patch(I, [bbox_t(1)+bbox_t(3)/2 bbox_t(2)+bbox_t(4)/2], 1, [bbox_t(3) bbox_t(4)]))) .* Cw;
    
    % get ground truth
    G = create_gauss_peak([bbox_t(3) bbox_t(4)], params.peak, params.sigma);
    
    % precalculate
    Pf = fft2(P);
    Pfc = conj(Pf);
    Gf = fft2(G);
    
    % calculate filter
    A = (Gf .* Pfc);
    B = (Pf .* Pfc) + params.lambda;
    
    % construct state
    state = struct;  
    state.A = A;
    state.B = B;
    state.Gf = Gf;
    state.Cw = Cw;
    state.bbox_s = bbox_s;
    state.bbox_t = bbox_t;
    state.m = [params.peak];
    
    % location
    location = bbox_s;
    
end

function bbox_s = get_search_bbox(region)
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
    end;

    bbox_s = region;
end