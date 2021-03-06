% 22.02.2016
% Amanda Prorok
%
% Batch EM for mixture of Gaussian and Lognormal 
%%

function parX = f_batch_EM(max_iter,data)

plot_on = false;
num_mod = 2; % number of modes
m_range = [-0.2 0.2; 0 3];
s_range = [0.1 0.6; 0.1 2];

if (~nargin)
    max_iter = 100;
    % Define true parameters; random samples
    par.m = zeros(num_mod,1);
    par.s = zeros(num_mod,1);
    for k=1:num_mod
        par.m(k) = m_range(k,1) + (m_range(k,2) - m_range(k,1)) * rand;
        par.s(k) = s_range(k,1) + (s_range(k,2) - s_range(k,1)) * rand;
    end
    par.w = s_range(1) + (s_range(2) - s_range(1)) .* rand(num_mod,1);
    par.w = par.w ./ sum(par.w); % normalize
    % Create data
    N = 200;
    [data,~] = f_create_NormLogn_data(N,par.m,par.s,par.w,0);
end
N = length(data);

%Initialize EM
for k=1:num_mod
    par0.m(k) = m_range(k,1) + (m_range(k,2) - m_range(k,1)) * rand;
    par0.s(k) = s_range(k,1) + (s_range(k,2) - s_range(k,1)) * rand;
end
%par0.m = m_range(1) + (m_range(2) - m_range(1)) .* rand(num_mod,1)';
%par0.s = s_range(1) + (s_range(2) - s_range(1)) .* rand(num_mod,1)';
par0.w = 1/num_mod * ones(1,num_mod);
par0_ = [par0.m par0.s]';
num_par = length(par0_);

% initialize structures
tau = zeros(num_mod,max_iter);
T = zeros(num_mod,N,max_iter);
parX_ = zeros(num_par,max_iter);
parX_(:,1) = par0_;
tau(:,1) = par0.w;


% Iterate
for t=1:max_iter-1
    fprintf('Iter: %d\n',t);
    T(:,:,t) = f_get_T(tau(:,t),parX_(:,t),data);
    tau(:,t+1) = f_update_tau(T(:,:,t));
    parX_(:,t+1) = f_update_par(T(:,:,t),data);
end

parX.m = parX_(1:num_mod,max_iter);
parX.s = parX_(num_mod+1:2*num_mod,max_iter);
parX.w = tau(:,max_iter);


% Plot
if plot_on
    ax = min(data)-0.1:0.02:max(data)+0.1;
    figure, hold on;
    fax = gca;
    % Plot data points
    f_plot_datapoints(fax,data);
    if(~nargin)
        % True curve in green
        f_plot_NormLogn(fax,ax,par.m,par.s,par.w,'g');
    end
    % Estimated curve in red
    f_plot_NormLogn(fax,ax,parX.m,parX.s,parX.w,'r');

end


end
