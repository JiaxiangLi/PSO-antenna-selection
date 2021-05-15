function d_attenuation=fitness_based_distance_for_multiple_user(yita,x,service_number,distance_matrix)
if max(max(x))>1                % x不再是0-1矩阵
    d_attenuation=-inf;
    warning('迭代过程中x出现非0非1元素')
    return
end
if sum(ismember(sum(x,1),1))~=size(x,1)*service_number
    d_attenuation=-inf;
    return
end
% if max(sum(x,1))>Nrf || max(sum(x,2))>service_number || max(max(x))==0
if max(max(x))==0 || ~isequal(sum(x,2),service_number*ones(size(x,1),1))
    d_attenuation=-inf;
    return
end
useful_distance=zeros(size(x,1),1);interference_distance=zeros(size(x,1),1);d=zeros(size(x,1),1);
work_x=sum(x,1);
N0=10^(-143/10)/1000;
for i=1:size(x,1)
    useful_distance(i,1)=sum(distance_matrix(i,:).*x(i,:));
    interference_distance(i,1)=sum(distance_matrix(i,:).*work_x)-useful_distance(i,1);
    d(i,1)=log(1+(useful_distance(i,1)/(interference_distance(i,1)+(N0/yita))));
%     d(i,1)=useful_distance(i,1)/(interference_distance(i,1)+N0); % 以SINR为和不好
end
d_attenuation=sum(d);
end