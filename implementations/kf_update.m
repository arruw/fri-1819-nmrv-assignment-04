function [state, location] = kf_update(state, I, params)
    
    % a) sample new particles
    state.particles = sample_particles(state, params);
    state.weights = ones(params.N, 1) / params.N;
    
    for i = 1:params.N
        % b) move each particle apply dinamic model and noise
        state.particles(i,:) = (state.A*state.particles(i,:)' + mvnrnd(zeros(size(state.center)), state.Q)')';
                
        if ~is_on_image(I, state.particles(i,:))
            state.weights(i, 1) = 0;
            continue;
        end
        
        % c) update weights based on the model similarity
                  
        % extract model
        template = get_patch(I, [state.particles(i,1) state.particles(i,2)], 1, [state.bbox(3) state.bbox(4)]);
        hist = extract_histogram(template, params.bins, state.kernel);
        
        % similarity
        d = 1 - sum(sqrt(hist .* state.hist), 'all');
        
        % convert similarity measure to weight
        state.weights(i, 1) = exp(-d/(2*params.sigma^2));
    end
        
    % d) compute new location of the target (weighted sum)
    
    state.weights(~isfinite(state.weights)) = 1e-100;
    state.weights = state.weights / sum(state.weights);
    state.weights(~isfinite(state.weights)) = 1e-100;
    
    state.center = sum(state.particles .* state.weights);
%     state.center(2) = sum(state.particles(:,2) .* state.weights);
%     state.center(3) = sum(state.particles(:,3) .* state.weights);
%     state.center(4) = sum(state.particles(:,4) .* state.weights);
   
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

function ok = is_on_image(I, particle)
    x = particle(1);
    y = particle(2);
    [h, w] = size(I);
    
    ok = x > 1 && y > 1 && x <= w && x <= h;
end