function [state, location] = kf_update(state, I, params)
    
    % get current center
    % x_c = state.bbox_t(1)+state.bbox_t(3)/2;
    % y_c = state.bbox_t(2)+state.bbox_t(4)/2;

    % extract template
    % template = get_patch(I, [x_c y_c], 1, [state.bbox_t(3) state.bbox_t(4)]);

    % a) sample new particles
    particles = sample_particles(state, params);
    weights = zeros(params.N, 1);
    A = state.A;
    bins = params.bins;
    sigma = params.sigma;
    
    parfor (i = 1:params.N, 4)
        particle = particles(i,:);
        % b) move each particle apply dinamic model and noise
        particle = (A*particle' + mvnrnd([0 0 0 0], state.Q)')';
        
        % c) update weights based on the model similarity
                  
        % extract model
        template = get_patch(I, [particle(1) particle(2)], 1, [state.bbox(3) state.bbox(4)]);
        hist = extract_histogram(template, bins, state.kernel);
        
        % hellinger distance squared
        d = 1-sum(sqrt(state.hist.*hist), 'all');
        
        % convert similarity measure to weight
        weights(i, 1) = exp(-d/(2*sigma^2));
        particles(i, :) = particle;
    end
        
    % d) compute new location of the target (weighted sum)
    weights(~isfinite(weights)) = 1e-10;
    state.weights = weights / sum(weights, 'all');
    state.particles = particles;
    state.center(1) = sum(state.particles(:,1) .* state.weights);
    state.center(2) = sum(state.particles(:,2) .* state.weights);
    state.center(3) = sum(state.particles(:,3) .* state.weights);
    state.center(4) = sum(state.particles(:,4) .* state.weights);
   
    template = get_patch(I, [state.center(1) state.center(2)], 1, [state.bbox(3) state.bbox(4)]);
    hist = extract_histogram(template, params.bins, state.kernel);
    
    % update model
    state.hist = (1-params.alpha)*state.hist + params.alpha*hist;
    
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