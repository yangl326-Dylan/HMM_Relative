%������������
multi_data  = load('cl_normal.txt');
%example on node31
raw_data = multi_data(32,1500:5762);


%cl Ũ��������Ҫ��ɢ��
len = length(raw_data);
data = zeros(1,floor(len/2));
thta = zeros(1,floor(len/2));
thta = zeros(1,floor(len/2));
unit = 180/18;  %��ɢ����18��״̬��ע�����������״̬��hmm�е�״̬��
for t= 1:len/2
    y1 = raw_data(2*t-1);
    y2 = raw_data(2*t);
    thta(t) = atand((y1-y2)*100);
    if(thta(t)<0)
        thta(t) = 180+thta(t);
    end
    data(t) = ceil(thta(t)/unit); 
end
plot(data,'*');
%hold on;
%plot(thta,'*');