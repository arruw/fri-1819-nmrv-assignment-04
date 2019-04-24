function [A,C,Q,R] = generate_model(model, q, r)
% OUTPUTS:
% A - system matrix
% C - observation matrix
% Q - system noise covariance matrix
% R - observation noise convariance matrix

switch model
    
    % Nearly Constant Velocity (1D)
    case 'NCV1D'
        % state = [x, xv]'
        % where x is position and xv is the velocity
        
        F = [0 1 ; 0 0];
        L = [0; 1];
        C = [1; 0];
        
    % Random Walk
    case 'RW'
        
    % Nearly Constant Velocity
    case 'NCV'
        % state = [x, y, xv, yv]'
        % where x,y is position and xv,yv is the velocity
        
        F = [0 0 1 0; 0 0 0 1; 0 0 0 0; 0 0 0 0];
        L = [1 0; 0 1; 0 0; 0 0];
        C = [1 0 0 0; 0 1 0 0];
        
    % Nearly Constant Accerelation
    case 'NCA'
        
        
    otherwise
        throw(MException('generate_model:invalidModel', 'Unsupported model.'));        
end

    syms sym_T sym_q
    Fi = expm(F*sym_T);
    Q = int((Fi*L)*sym_q*(Fi*L)',sym_T,0,sym_T);
        
    A = subs(Fi, [sym_T sym_q], [1 q]);
    Q = subs(Q, [sym_T sym_q], [1 q]);
    R = [r 0; 0 r];
end

