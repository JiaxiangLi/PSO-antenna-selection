% 改进版baseline 搭配antenna_selection_enhanced
function [R,S]=baseline_enhanced(yita,service_number,power_cell,distance_matrix,RRH_matrix,USER_matrix)
rrh=size(distance_matrix,2);
user=size(distance_matrix,1);
a=randperm(user);
new_distance_matrix=distance_matrix(a,:);
A=antenna_selection_enhanced(service_number,new_distance_matrix);
x=change_A_to_x(A,user,rrh);
if ~ismember(1,sum(x,1))
    disp('一个天线被重复选择了多次');
end
new_x=x;
for i=1:user
    new_x(a(i),:)=x(i,:);
end
R=real(fitness_for_multiple_user(yita,new_x,service_number,power_cell));
S=new_x;
end

function x=change_A_to_x(A,user,rrh)
x=zeros(user,rrh);  % 建立一个二进制的天线选择方案矩阵，好利用之前写的函数
for i=1:user
    for j=1:size(A,1)
        x(i,A(j,i))=1;
    end
end
end