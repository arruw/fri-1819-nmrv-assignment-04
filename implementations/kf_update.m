function [state, location] = kf_update(state, I, params)
    
    % get current center
    % x_c = state.bbox_t(1)+state.bbox_t(3)/2;
    % y_c = state.bbox_t(2)+state.bbox_t(4)/2;

    % extract template
    % template = get_patch(I, [x_c y_c], 1, [state.bbox_t(3) state.bbox_t(4)]);

    % a) sample new particles
    state.particles = sample_particles(state, params);
    
    for i = 1:params.N
        % b) move each particle apply dinamic model and noise
        state.particles(i,:) = (state.A*state.particles(i,:)' + mvnrnd([0 0 0 0], state.Q)')';
        
        % c) update weights based on the model similarity
        
        % extract model
        template = get_patch(I, [state.particles(i, 1) state.particles(i, 2)], 1, [state.bbox(3) state.bbox(4)]);
        color_pdf = extract_color_pdf(template, params.bins, state.cos_window);
        
        % calculate similarity (hellinger distance values between 0 and 1)
        d = hellinger_distance(state.color_pdf, color_pdf);
        
        % convert similarity measure to weight
        state.weights(i, 1) = exp(-(d^2)/(2*params.q));
        % state.weights(i, 1) = d;
    end
        
    % d) compute new location of the target (weighted sum)
    sw = sum(state.weights);
    state.center(1) = sum(state.particles(:,1) .* state.weights)/sw;
    state.center(2) = sum(state.particles(:,2) .* state.weights)/sw;
    state.center(3) = sum(state.particles(:,3) .* state.weights)/sw;
    state.center(4) = sum(state.particles(:,4) .* state.weights)/sw;
   
    template = get_patch(I, [state.center(1) state.center(2)], 1, [state.bbox(3) state.bbox(4)]);
    color_pdf = extract_color_pdf(template, params.bins, state.cos_window);
    
    % update model
    state.color_pdf = (1-params.alpha)*state.color_pdf + params.alpha*color_pdf;
    
    state.bbox = [...
        state.center(1)-state.bbox(3)/2 ...
        state.center(2)-state.bbox(4)/2 ...
        state.bbox(3) ...
        state.bbox(4)];
    
    % location
    location = state.bbox;
    
end

function particles = sample_particles(state, params)
    Q = state.weights/sum(state.weights);
    R = cumsum(Q);
    [~,I] = histc(rand(1,params.N),R);
    particles = state.particles(I+1,:);
end