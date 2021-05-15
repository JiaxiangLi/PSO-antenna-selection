function [RRH_matrix,USER_matrix,distance_matrix,LOS_matrix]=generate_largescale_matrix(user,rrh)
RRH_matrix=rand(rrh,2)*100;
USER_matrix=rand(user,2)*40+ones(user,2)*30;
% USER_matrix=rand(user,2)*100;
distance_matrix=get_distance_matrix(USER_matrix,RRH_matrix);
LOS_matrix=zeros(user,rrh);     % 该矩阵用于记录第i个用户到第j个RRH之间有无直射路径
for i=1:user
    for j=1:rrh
        d=distance_matrix(i,j);
        LOS_matrix(i,j)=rand(1)<min(20/d,1)*(1-exp(-d/39))+exp(-d/39);
    end
end
end