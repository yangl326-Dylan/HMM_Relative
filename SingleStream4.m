%%% using the original hmm model learning algorithm
%%% 预测下一个窗口的所有数据
clear all;
%载入所有数据
%multi_data  = load('synthesis_comtamination&normal_p31_5199t_240i.txt');
%multi_data  = load('cl_normal.txt');
multi_data  = load('synthesis_comtamination&normal_p58_3663t_240i.txt');

%example on node31
raw_data = multi_data(59,1500:5762);
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
w = 5;%一个窗口的大小
sliding_w = 1;
% 0 < decay < 1, with smaller values meaning the past is forgotten more quickly.
% (We need to decay the old ess, since they were based on out-of-date parameters.)
%0.1 0.2 0.3 ... 0.9
decay_sched = [0.1:0.1:0.9];
act_win = [1]; % arbitrary initial value
%所有的长度
raw_len = length(raw_data);

%predict observation pdf ：我预测的结果，用概率来表示每一种观测发生的概率
pre_obs = cell(1,w);
for a=1:w
    pre_obs{a} = zeros(1,V);
end

%statistic for miscounting
min_thred_pro = 0.01;
mis_total = 0;
mis_con_two = 0; %表示所有连续出现预测不准的case的总次数
mis_con_flag = 0; %表示连续出现预测不准的连续次数
flag = 0; % mark if to continously check in the next 10 step

 %离散化
 x = mean(raw_data(1,1:1+dis_win-1)); %当前窗口的平均值
 if(x == 0)
     dy = 1;
 else
      dy = ceil(x/unit);  %%>=后面的整数
 end
 % Initialize
[prior1] = normalise(prior1 .* obsmat1(:,dy));
dis_data = dy;

for tamp=1+dis_win:dis_win:raw_len-dis_win  %%1,7,13....
    %离散化
    x = mean(raw_data(1,tamp:tamp+dis_win-1)); %当前窗口的平均值
    if(x == 0)
        dy = 1;
    else
        dy = ceil(x/unit);  %%>=后面的整数
    end
    dis_data = [dis_data dy];
end
T = length(dis_data);
fprintf('the length of the dis_data : %d\n',T);

data_win = zeros(1,w);
fut_win = zeros(1,w);
fp = fopen('result59.txt','wt');
fp0 = fopen('confidence.txt','wt');
penalty_threshold = 50;

for t=1:sliding_w:T-2*w
    data_win = dis_data(t:t+w-1); % 起始时刻是t，窗口长度是w的一段窗口
    act_win = act(t:t+w-1);
    fut_win = dis_data(t+w-1:t+2*w-2);
    %%%判断当前窗口预测的准确度
    win_mis_cnt = 0; %一个窗口内预测错误的个数，初始化为0
    penalty = 0; %惩罚项
    confidence = 0; %不是异常的自信度，自信度，
    if(t>1)
        for a=1:w
            real = fut_win(a);
            predictor_pdf = pre_obs{a};
            penalty = penalty - log(predictor_pdf(real));
            confidence = confidence + predictor_pdf(real);
            %if(log(predictor_pdf(real))<-1)
                %fprintf(fp,'%d 时刻预测的log(概率)为 %d .\n',t,log(predictor_pdf(real)));
            %end
            %if(predictor_pdf(real) < min_thred_pro)
                %win_mis_cnt = win_mis_cnt+1;
                %mis_total = mis_total+1;
            %end
        end
        if(penalty > penalty_threshold)
            fprintf('%d 时刻开始的窗口内预测的惩罚项为： %d.\n',t+w-1+a-1,penalty);
        end
        fprintf(fp,'%d %f\n',t+w-1+a-1,penalty);
        fprintf(fp0,'%d %f\n',t+w-1+a-1,confidence/w);
        %if(win_mis_cnt>w/2)
             %fprintf('%d 时刻开始的窗口内真实值与预测相差的个数 %d .\n',t,win_mis_cnt);
        %end
    end
    if t>1 
        prior1 = gamma(:, sliding_w+1);
    end
    d = decay_sched(min(t, length(decay_sched)));
    [transmat1, obsmat1, ess_trans, ess_emit, gamma, ll] = dhmm_em_online(...
        prior1, transmat1, obsmat1, ess_trans, ess_emit, d, data_win, act_win);
    %bel = gamma(:, end);
    %LL1(t) = ll/length(data_win);
    %%预测
    bm = multinomial_prob(data_win, obsmat1);
    [path_win] = viterbi_path(prior1, transmat1{1}, bm);
    curr_state = path_win(end);
    for a=1:w
         %下一个时刻的状态分布
        [next_state] = transmat1{1}(curr_state,:);
          %initialize it
         pre_obs{a} = zeros(1,V);
         %求下一个时刻观测的概率分布
        for s=1:Q
           pre_obs{a} = pre_obs{a} + next_state(s)*obsmat1(s,:);
        end
        [curr_state_pro curr_state] = max(next_state);
    end
end
fclose(fp);
fclose(fp0);


