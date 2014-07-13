%%% using the original hmm model learning algorithm
%%% 预测下一个窗口的所有数据
clear all;
%载入所有数据
%multi_data  = load('cl_normal.txt');
multi_data  = load('synthesis_comtamination&normal_p58_3663t_240i.txt');

%example on node31
raw_data = multi_data(59,1500:5762);
%V={1,2,...,M} 所有可能的观测的个数 |V|
V = 50;
%Q={1,2,...,N} 所有可能得状态的集合 |Q|
Q = 3;
A = 2; %action的总数
dis_win = 6; %a group of raw data was transformed to an observation token 
unit = 1/V;  %每一种状态的range
%partial observable Markov decision process 中用到的action 
%全采用第一个action
act = [1*ones(1,5000) 1*ones(1,1000) 1*ones(1,1000) 2*ones(1,1000) ];

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
%所有的长度
raw_len = length(raw_data);
%tamp 模拟每一个时刻数据流的到来
for tamp=1:raw_len
    
end


