%   R = RAND(N) returns an N-by-N matrix containing pseudorandom(伪随机) values drawn
%   from the standard uniform distribution on the open interval(0,1).  RAND(M,N)
%   or RAND([M,N]) returns an M-by-N matrix.
%

%载入所有数据
multi_data  = load('cl_normal.txt');
%example on node31
raw_data = multi_data(32,1500:5762);
%V={1,2,...,M} 所有可能的观测的个数 |V|
V = 18;
%Q={1,2,...,N} 所有可能得状态的集合 |Q|
Q = 3; 
A = 2; %?????
%partial observable Markov decision process 中用到的action 
act = [2*ones(1,1000) 1*ones(1,1000) 1*ones(1,1000) 2*ones(1,1000) ];

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
%%
%%cl 浓度数据需要离散化
len = length(raw_data);
data = zeros(1,floor(len/2));
thta = zeros(1,floor(len/2));
unit = 180/V;  %离散化成18个状态（注意区分这里得状态和hmm中的状态）
for t= 1:len/2
    y1 = raw_data(2*t-1);
    y2 = raw_data(2*t);
    thta(t) = atand((y1-y2)*100); %求斜率角
    if(thta(t)<0)
        thta(t) = 180+thta(t);
    end
    data(t) = ceil(thta(t)/unit) + 1; 
end
%plot(data,'*');
%%
T = length(data);

% Params
w = 2;
% 0 < decay < 1, with smaller values meaning the past is forgotten more quickly.
% (We need to decay the old ess, since they were based on out-of-date parameters.)
decay_sched = [0.1:0.1:0.9];

% Initialize
LL1 = zeros(1,T);
t = 1;
y = data(t);
data_win = y;
act_win = [1]; % arbitrary initial value
[prior1, LL1(1)] = normalise(prior1 .* obsmat1(:,y));

% Iterate
for t=2:T
  y = data(t);
  a = act(t);
  if t <= w
    data_win = [data_win y];
    act_win = [act_win a];
  else
    data_win = [data_win(2:end) y];
    act_win = [act_win(2:end) a];
    prior1 = gamma(:, 2);
  end
  d = decay_sched(min(t, length(decay_sched)));
  [transmat1, obsmat1, ess_trans, ess_emit, gamma, ll] = dhmm_em_online(...
      prior1, transmat1, obsmat1, ess_trans, ess_emit, d, data_win, act_win);
  bel = gamma(:, end);
  LL1(t) = ll/length(data_win);
  %fprintf('t=%d, ll=%f\n', t, ll);
end
%采用维特比算法求得概率最大的状态序列
%First you need to evaluate B(i,t) = P(y_t | Q_t=i) for all t,i:
B = multinomial_prob(data, obsmat1);
[path] = viterbi_path(prior1, transmat1{1}, B)
%统计字符型数组中各行元素出现的频数、频率
TABLE = tabulate(data);
%画直方图
bar(TABLE(:,1),TABLE(:,2))
LL1(1) = LL1(2); % since initial likelihood is for 1 slice
plot(1:T, LL1, 'rx-');
