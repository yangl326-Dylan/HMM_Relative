%%% using the original hmm model learning algorithm
%%% 重构了代码
clear all;
%载入所有数据
multi_data  = load('synthesis_comtamination&normal_p31_5199t_240i.txt');
%multi_data  = load('cl_normal.txt');
%multi_data  = load('synthesis_comtamination&normal_p58_3663t_240i.txt');

%example on node31
raw_data = multi_data(32,1500:5762);
%归一化
raw_data = mapminmax(raw_data,0,1);
%V={1,2,...,M} 所有可能的观测的个数 |V|
V = 10;
%Q={1,2,...,N} 所有可能得状态的集合 |Q|
Q = 3;
A = 2; %action的总数
dis_win = 1; %a group of raw data was transformed to an observation token 
unit = 1/V;  %每一种状态的range
%partial observable Markov decision process 中用到的action 
%全采用第一个action
act = [1*ones(1,5000)];

% initial guess of parameters
prior1 = normalise(rand(Q,1));
transmat1 = cell(1,A); % 1-by-A 的数组， 数组元素为cell
for a=1:A
  transmat1{a} = mk_stochastic(rand(Q,Q));
end
obsmat1 = mk_stochastic(rand(Q,V));

% Uniformative Dirichlet prior (expected sufficient statistics / pseudo counts)
e = 0.001;
ess_trans = cell(1,A);
for a=1:A
  ess_trans{a} = repmat(e, Q, Q);
end
ess_emit = repmat(e, Q, V);

% Params
w = 2;
% 0 < decay < 1, with smaller values meaning the past is forgotten more quickly.
% (We need to decay the old ess, since they were based on out-of-date parameters.)
%0.1 0.2 0.3 ... 0.9
decay_sched = [0.1:0.1:0.9];
act_win = [1]; % arbitrary initial value
%所有的长度
raw_len = length(raw_data);
x = mean(raw_data(1,1:dis_win)); %求均值;
if(x == 0)
    dy = 1;
else
    dy = ceil(x/unit);  %%>=后面的整数
end
data_win = dy;
% Initialize
[prior1] = normalise(prior1 .* obsmat1(:,dy));

%predict observation pdf ：我预测的结果，用概率来表示每一种观测发生的概率
pre_obs = zeros(1,V);
%statistic for miscounting
min_thred_pro = 0.1;
mis_total = 0;
mis_con_two = 0; %表示所有连续出现预测不准的case的总次数
mis_con_flag = 0; %表示连续出现预测不准的连续次数
flag = 0; % mark if to continously check in the next 10 step

%tamp 模拟每一个时刻数据流的到来
t = 2;
for tamp=1+dis_win:dis_win:raw_len-dis_win  %%1,7,13....
    %离散化
    x = mean(raw_data(1,tamp:tamp+dis_win-1)); %当前窗口的平均值
    if(x == 0)
        dy = 1;
    else
        dy = ceil(x/unit);  %%>=后面的整数
    end
     %check if the predictor is right
    if(t>1)
        if(t>=3699)
            fprintf('%d :\n',pre_obs(dy));
        end
       if(pre_obs(dy)<min_thred_pro) 
          mis_total = mis_total+1;
          if(mis_con_flag >= 1) 
              fprintf('%d : %d\n',t, mis_con_flag);
              mis_con_two = mis_con_two + 1;
          end
          mis_con_flag = mis_con_flag+1;
       else
           mis_con_flag = 0;
       end
    end
    a = act(t);
    if t <= w
        data_win = [data_win dy];
        act_win = [act_win a];
    else
        data_win = [data_win(2:end) dy];
        act_win = [act_win(2:end) a];
        prior1 = gamma(:, 2);
    end
    d = decay_sched(min(t, length(decay_sched)));
    [transmat1, obsmat1, ess_trans, ess_emit, gamma, ll] = dhmm_em_online(...
        prior1, transmat1, obsmat1, ess_trans, ess_emit, d, data_win, act_win);
    bel = gamma(:, end);
    %LL1(t) = ll/length(data_win);
    %%预测
    bm = multinomial_prob(data_win, obsmat1);
    [path_win] = viterbi_path(prior1, transmat1{1}, bm);
    curr_state = path_win(end);
     %下一个时刻的状态分布
    [next_state] = transmat1{1}(curr_state,:);
     %initialize it
    pre_obs = zeros(1,V);
     %求下一个时刻观测的概率分布
    for s=1:Q
        pre_obs = pre_obs + next_state(s)*obsmat1(s,:);
    end
    t=t+1;
end


