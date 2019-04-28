clear;
clc;

% Default
% 2.0,100,2.0,0.125,0.05,1e-05
params = {
    % Testing training speed alpha
%     create_params(2.0, 2.0, 0.00, 'mosse_20_20_000'),...
%     create_params(2.0, 2.0, 0.01, 'mosse_20_20_001'),...
%     create_params(2.0, 2.0, 0.05, 'mosse_20_20_005'),...
%     create_params(2.0, 2.0, 0.10, 'mosse_20_20_010'),...
%     create_params(2.0, 2.0, 0.40, 'mosse_20_20_040')...
    
    % Testing Gaussian sigma
%     create_params(0.5, 2.0, 0.125, 'mosse_05_20_0125'),...
%     create_params(1.0, 2.0, 0.125, 'mosse_10_20_0125'),...
%     create_params(1.5, 2.0, 0.125, 'mosse_15_20_0125'),...
%     create_params(2.0, 2.0, 0.125, 'mosse_20_20_0125'),...
%     create_params(8.0, 2.0, 0.125, 'mosse_80_20_0125')...
    
    % Testing filter size
%     create_params(2.0, 1.0, 0.125, 'mosse_20_10_0125'),...
%     create_params(2.0, 1.5, 0.125, 'mosse_20_15_0125'),...
%     create_params(2.0, 2.0, 0.125, 'mosse_20_20_0125'),...
%     create_params(2.0, 2.5, 0.125, 'mosse_20_25_0125'),...
%     create_params(2.0, 5.0, 0.125, 'mosse_20_50_0125')...
};

cd('./workspace');
trackers = cell(length(params), 1);
for i = 1:length(params)
    create_wrapper(params{i});
    run_experiment;
    delete_wrapper(params{i});
    trackers{i} = params{i}.name;
end
inject_template("./templates/workspace_config.template",struct('name','xyz'), "./workspace_config.m");
set(0,'defaultTextInterpreter','latex');
compare_trackers(trackers);
delete("./workspace_config.m");
cd('..');

function p = create_params(sigma, s2tr, alpha, name)
    p = struct;
    p.name = name;
    p.sigma = sigma;
    p.peak = 100;
    p.s2tr = s2tr;
    p.alpha = alpha;
    p.psr = 0.05;
    p.lambda = 1e-5;
end

function create_wrapper(p)
    inject_template("./templates/initialize.template",      p, "./"+p.name+"_initialize.m");
    inject_template("./templates/update.template",          p, "./"+p.name+"_update.m");
    inject_template("./templates/workspace_config.template",p, "./workspace_config.m");
end

function delete_wrapper(p)
    delete("./"+p.name+"_initialize.m");
    delete("./"+p.name+"_update.m");
    delete("./workspace_config.m");
end