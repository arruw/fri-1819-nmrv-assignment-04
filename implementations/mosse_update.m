function [state, location] = mosse_update(state, I, params)
    
    % get current center
    x_c = state.bbox_t(1)+state.bbox_t(3)/2;
    y_c = state.bbox_t(2)+state.bbox_t(4)/2;

    % get localization patch
    L = double(rgb2gray(get_patch(I, [x_c y_c], 1, [state.bbox_t(3) state.bbox_t(4)]))) .* state.Cw;

    % precalculate
    Lf = fft2(L);
    Lfc = conj(Lf);
    
    % get next center
    Gp = ifft2(Lf .* (state.A ./ state.B));
    [m, mi] = max(Gp(:));
    [y_n, x_n] = ind2sub(size(Gp), mi);
    x_n = x_n + state.bbox_t(1);
    y_n = y_n + state.bbox_t(2);
           
    % get displacement vector
    dx = x_n - x_c;
    dy = y_n - y_c;
    
    % update state
    if m >= params.peak*params.psr;
        alpha = params.alpha * m/params.peak;
        state.A = (1-alpha)*state.A + alpha*(state.Gf .* Lfc);
        state.B = (1-alpha)*state.B + alpha*((Lf .* Lfc)+params.lambda);
    end

    state.bbox_s = [state.bbox_s(1)+dx state.bbox_s(2)+dy state.bbox_s(3:4)];
    state.bbox_t = [state.bbox_t(1)+dx state.bbox_t(2)+dy state.bbox_t(3:4)];
    state.m = [state.m m];
    
    % location
    location = state.bbox_s;
    
end