% 用于检查用户周围10m范围内的RRH数目是否满足服务天线数目
function r=density_check(RRH_matrix,USER_matrix,service_number,distance_matrix,range)
r=1;
rrh=size(RRH_matrix,1);
new_rrh=1:rrh;
new_rrh(min(distance_matrix)>range)=[]; % 该变量可以记录周围10m范围内有用户的RRH编号
if size(new_rrh,2)<size(USER_matrix,1)*service_number
    r=0;
end 
end