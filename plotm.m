%载入所有数据
%multi_data  = load('synthesis_comtamination&normal_p31_5199t_240i.txt');
multi_data  = load('synthesis_comtamination&normal_p58_3663t_240i.txt');
%example on node31
raw_data = multi_data(59,1500:1600);


plot(raw_data,'.');
%hold on;
%plot(thta,'*');