% antenna_selection 太慢，在此重写
function A=antenna_selection_enhanced(service_number,distance_matrix)
user=size(distance_matrix,1);
A=zeros(user,service_number);
for i=1:user
    sort_distance_matrix=sort(distance_matrix(i,:));
    for k=1:service_number
        t=find(distance_matrix(i,:)==sort_distance_matrix(1,k)); % 寻找最小的第k个元素在原数组中的位置
        t=t(unidrnd(size(t,2)));
        if ~ismember(t,A)
            A(i,k)=t;
        else
            n=1;
            while ismember(t,A)
                t=find(distance_matrix(i,:)==sort_distance_matrix(1,k+n));
                t=t(unidrnd(size(t,2)));
                n=n+1;
            end
            A(i,k)=t;
        end
    end
end
A=A';   % 为了跟之前的复用，第一列的元素表示为第一个用户所选择的RRH编号
end
