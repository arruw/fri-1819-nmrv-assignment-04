clear;
clc;

rng('default');
rng(1);

% Default (best)
% RW 20 50 0.01
params = {
    % Testing training speed alpha
%     create_params("RW", 20, 30, 0.01, 'rw_20_30_001'),...            % best
%     create_params("RW", 20, 30, 0.02, 'rw_20_30_002'),...
%     create_params("RW", 20, 30, 0.03, 'rw_20_30_003'),...
%     create_params("RW", 20, 30, 0.05, 'rw_20_30_005'),...
    
    % Testing number of particles
%     create_params("RW", 20, 10, 0.01, 'rw_20_10_001'),...           
%     create_params("RW", 20, 30, 0.01, 'rw_20_30_001'),...
%     create_params("RW", 20, 50, 0.01, 'rw_20_50_001'),...           % best
%     create_params("RW", 20, 70, 0.01, 'rw_20_70_001'),...
%     create_params("RW", 20, 90, 0.01, 'rw_20_90_001')...
    
    % Testing #bins
%     create_params("RW", 5,  30, 0.01, 'rw_5_30_001'),...
%     create_params("RW", 10, 30, 0.01, 'rw_10_30_001'),...
%     create_params("RW", 15, 30, 0.01, 'rw_15_30_001'),...
%     create_params("RW", 20, 30, 0.01, 'rw_20_30_001')...           % best
    
%     % Test motion models
%     create_params("RW",  20, 30, 0.01, 'rw_20_30_001'),...         % best
%     create_params("NCV", 20, 30, 0.01, 'ncv_20_30_001'),...
%     create_params("NCA", 20, 30, 0.01, 'nca_20_30_001')...

    % Test best 
    create_params("RW", 20, 50, 0.01, 'rw_20_50_001')
};

cd('./workspace');
trackers = cell(length(params), 1);
for i = 1:length(params)
    create_wrapper(params{i});
    run_experiment;
    performance_summary;
    delete_wrapper(params{i});
    trackers{i} = params{i}.name;
end
% inject_template("./templates/workspace_config.template",struct('name','xyz'), "./workspace_config.m");
% set(0,'defaultTextInterpreter','latex');
% compare_trackers(trackers);
% delete("./workspace_config.m");
% cd('..');

function p = create_params(model, bins, N, alpha, name)
    p = struct;
    p.name = name;
    p.model = model;
    p.r = 1;
    p.sigma = 0.2;
    p.bins = bins;
    p.N = N;
    p.alpha = alpha;
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