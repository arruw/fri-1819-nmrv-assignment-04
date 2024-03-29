function [A,C,Q,R] = generate_model(model, q, r)
% OUTPUTS:
% A - system matrix
% C - observation matrix
% Q - system noise covariance matrix
% R - observation noise convariance matrix

switch model
    
    % Random Walk
    case 'RW'
        % state = [x, y]'
        % where x,y is position
        
        F = zeros(2);
        L = eye(2);
        C = eye(2);
        
    % Nearly Constant Velocity
    case 'NCV'
        % state = [x, y, xv, yv]'
        % where x,y is position and xv,yv is the velocity
        
        F = [0 0 1 0; 0 0 0 1; 0 0 0 0; 0 0 0 0];
        L = [0 0 1 0; 0 0 0 1]';
        C = [1 0 0 0; 0 1 0 0];
        
    % Nearly Constant Acceleration
    case 'NCA'
        % state = [x, y, xv, yv, xa, ya]'
        % where x,y is position, xv,yv is the velocity and xa,ya is the
        % acceleration
        
        F = [0 0 1 0 0 0; 0 0 0 1 0 0; 0 0 0 0 1 0; 0 0 0 0 0 1; 0 0 0 0 0 0; 0 0 0 0 0 0];
        L = [0 0 1 0 0 0; 0 0 0 1 0 0]';
        C = [1 0 0 0 0 0; 0 1 0 0 0 0];
        
    otherwise
        throw(MException('generate_model:invalidModel', 'Unsupported model.'));        
end

    syms sym_T sym_q
    Fi = expm(F*sym_T);
    Q = int((Fi*L)*sym_q*(Fi*L)',sym_T,0,sym_T);
    
    A = double(subs(Fi, [sym_T sym_q], [1 q]));
    Q = double(subs(Q, [sym_T sym_q], [1 q]));
    R = [r 0; 0 r];
end

