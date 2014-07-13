%%% using the original hmm model learning algorithm
%%% Ԥ����һ�����ڵ���������
clear all;
%������������
%multi_data  = load('cl_normal.txt');
multi_data  = load('synthesis_comtamination&normal_p58_3663t_240i.txt');

%example on node31
raw_data = multi_data(59,1500:5762);
%V={1,2,...,M} ���п��ܵĹ۲�ĸ��� |V|
V = 50;
%Q={1,2,...,N} ���п��ܵ�״̬�ļ��� |Q|
Q = 3;
A = 2; %action������
dis_win = 6; %a group of raw data was transformed to an observation token 
unit = 1/V;  %ÿһ��״̬��range
%partial observable Markov decision process ���õ���action 
%ȫ���õ�һ��action
act = [1*ones(1,5000) 1*ones(1,1000) 1*ones(1,1000) 2*ones(1,1000) ];

% initial guess of parameters
prior1 = normalise(rand(Q,1));
transmat1 = cell(1,A); % 1-by-A �����飬 ����Ԫ��Ϊcell
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
%���еĳ���
raw_len = length(raw_data);
%tamp ģ��ÿһ��ʱ���������ĵ���
for tamp=1:raw_len
    
end

