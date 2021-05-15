function R=fitness_for_multiple_user(yita,x,service_number,power_cell)
if max(max(x))>1                % x不再是0-1矩阵
    R=0;
    warning('迭代过程中x出现非0非1元素')
    return
end
% if max(sum(x,1))>Nrf || max(sum(x,2))>service_number || max(max(x))==0
if max(max(x))==0 || ~isequal(sum(x,2),service_number*ones(size(x,1),1))
    R=0;
%     warning('用户选择天线数目不正确')
    return
end
if sum(ismember(sum(x,1),1))~=size(x,1)*service_number
    R=0;
%     warning('服务天线总数不正确')
    return
end
N0=10^(-143/10)/1000;useful_power=zeros(size(x,1),1);interference_power=zeros(size(x,1),1);
R=zeros(size(x,1),1);work_x=sum(x,1);
for i=1:size(x,1)
    useful_power(i,1)=yita*sum(power_cell(i,:).*x(i,:));
    interference_power(i,1)=yita*sum(power_cell(i,:).*work_x)-useful_power(i,1);
    R(i,1)=log(1+useful_power(i,1)/(N0+interference_power(i,1)));
end
end