function d=get_distance_matrix(USER_matrix,RRH_matrix)
user=size(USER_matrix,1);rrh=size(RRH_matrix,1);
d=zeros(user,rrh);
for i=1:user
    for j=1:rrh
        d(i,j)=max(distance(USER_matrix(i,1),USER_matrix(i,2),RRH_matrix(j,1),RRH_matrix(j,2)),1);
    end
end
end