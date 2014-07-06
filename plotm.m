%载入所有数据
multi_data  = load('cl_normal.txt');
%example on node31
raw_data = multi_data(1,1500:5762);


plot(raw_data,'*');
%hold on;
%plot(thta,'*');