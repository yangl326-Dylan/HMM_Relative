%载入所有数据
multi_data  = load('synthesis_comtamination&normal_p31_5199t_240i.txt');
%multi_data  = load('synthesis_comtamination&normal_p58_3663t_240i.txt');
%multi_data  = load('cl_normal.txt');
%example on node31
raw_data = multi_data(32,1500:5600);
map_data = mapminmax(raw_data,0,1);

data = load('result59.txt');
plot(data(:,1),data(:,2));
%plot(map_data,'.');
%hold on;
%plot(thta,'*');