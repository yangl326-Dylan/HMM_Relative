%%% using the original hmm model learning algorithm
%   R = RAND(N) returns an N-by-N matrix containing pseudorandom(α���) values drawn
%   from the standard uniform distribution on the open interval(0,1).  RAND(M,N)
%   or RAND([M,N]) returns an M-by-N matrix.
%
clear all;
%������������
multi_data  = load('cl_normal.txt');
%multi_data  = load('synthesis_comtamination&normal_p31_5199t_240i.txt');

%example on node31
raw_data = multi_data(32,1500:5762);
%V={1,2,...,M} ���п��ܵĹ۲�ĸ��� |V|
V = 18;
%Q={1,2,...,N} ���п��ܵ�״̬�ļ��� |Q|
Q = 3;
A = 2; %?????
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
dis_win = 15;
sid_win = 3;
unit = 180/(V-1);  %��ɢ����18��״̬��ע�����������״̬��hmm�е�״̬��
%%
%%cl Ũ��������Ҫ��ɢ��
%%�����ط���Ҫ�޸ġ���Ҫ�Ӵ󴰿ڣ����ܵ�������������������ϳ�һ��ֱ�ߣ������Ļ��ھ���εĲ��������£���û��ʲô�������ɢ������

len = length(raw_data) - dis_win;
data = zeros(1,floor(len/sid_win));
thta = zeros(1,floor(len/sid_win)); %б�н�
pk = zeros(1,floor(len/sid_win)); %б��
for t = 1:floor(len/sid_win)
    start_index = 1+(t-1)*3;
    end_index = start_index+dis_win -1;
    x = raw_data(1,start_index:end_index);
    %X_new = (x - mean(x))/std(x);
    y = linspace(0.01,0.12,dis_win);
    %Y_new = (y - mean(y))/std(y);
    p = polyfit(x,y,1);%һ�����
    pk(t) = p(1);
    thta(t) = atand(p(1)); %p(1)��б��
    if(thta(t)<0)
        thta(t) = 180+thta(t);
    end
    data(t) = ceil(thta(t)/unit) + 1; 
end
%plot(data,'.');
%%
T = length(data);

% Params
w = 2;
% 0 < decay < 1, with smaller values meaning the past is forgotten more quickly.
% (We need to decay the old ess, since they were based on out-of-date parameters.)
%0.1 0.2 0.3 ... 0.9
decay_sched = [0.1:0.1:0.9];

% Initialize
LL1 = zeros(1,T);
t = 1;
dy = data(t);
data_win = dy;
act_win = [1]; % arbitrary initial value
[prior1, LL1(1)] = normalise(prior1 .* obsmat1(:,dy));
%predict observation pdf ����Ԥ��Ľ�����ø�������ʾÿһ�ֹ۲ⷢ���ĸ���
pre_obs = zeros(1,V);
%statistic for miscounting
min_thred_pro = 0.001;
mis_total = 0;
mis_con_two = 0; %��ʾ������������Ԥ�ⲻ׼��case���ܴ���
mis_con_flag = 0; %��ʾ��������Ԥ�ⲻ׼����������
flag = 0; % mark if to continously check in the next 10 step
%% Iterate
for t=2:T
  dy = data(t);
  %check if the predictor is right
  if(t>2)
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
  LL1(t) = ll/length(data_win);
  %fprintf('t=%d, ll=%f\n', t, ll);
  %%
  %%Ԥ��
  bm = multinomial_prob(data_win, obsmat1);
  [path_win] = viterbi_path(prior1, transmat1{1}, bm);
  curr_state = path_win(end);
  %��һ��ʱ�̵�״̬�ֲ�
  [next_state] = transmat1{1}(curr_state,:);
  %initialize it
  pre_obs = zeros(1,V);
  %����һ��ʱ�̹۲�ĸ��ʷֲ�
  for s=1:Q
      pre_obs = pre_obs + next_state(s)*obsmat1(s,:);
  end
end
%%
%����ά�ر��㷨��ø�������״̬����
%First you need to evaluate B(i,t) = P(y_t | Q_t=i) for all t,i:
B = multinomial_prob(data, obsmat1);
[path] = viterbi_path(prior1, transmat1{1}, B);
 %figure(1);
 %subplot(2,1,1);
 %plot(thta(150:288),'r.');
 %subplot(2,1,2);
 %plot(path(150:288),'.');
 %hold on;
%%
%%������������
%ͳ���ַ��������и���Ԫ�س��ֵ�Ƶ����Ƶ��
TABLE = tabulate(data);
%��ֱ��ͼ
%figure(2);
%bar(TABLE(:,1),TABLE(:,2));
%hold on;
%figure(3);
LL1(1) = LL1(2); % since initial likelihood is for 1 slice
%plot(1:T, LL1, 'rx-');



