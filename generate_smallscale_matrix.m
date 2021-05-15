function [channel_cell,precoder_cell,power_cell]=generate_smallscale_matrix(RRH_matrix,USER_matrix,LOS_matrix,Nrf,Nt,Nr,distance_matrix)
user=size(USER_matrix,1);rrh=size(RRH_matrix,1);
channel_cell=cell(user,rrh);    % 该cell用于存储第i个用户到第j个RRH之间的平均信道
precoder_cell=cell(user,rrh,2);
power_cell=zeros(user,rrh);
for i=1:user
    for j=1:rrh
        if size(channel_cell{i,j},1)==0||size(channel_cell{i,j},2)==0   % 新生成的cell行数和列数都为0，不进行重新赋值操作会无法与new_channel矩阵相加
            channel_cell{i,j}=zeros(Nt,Nr);
        end
        channel_cell{i,j}=channel_cell{i,j}+new_channel(i,j,Nt,Nr,LOS_matrix(i,j),distance_matrix);
        [Vrf,Vb]=precoder(channel_cell{i,j},Nrf,3);
        precoder_cell{i,j,1}=Vrf;
        precoder_cell{i,j,2}=Vb;
        power_cell(i,j)=channel_cell{i,j}'*Vrf*(Vb*Vb')*Vrf'*channel_cell{i,j};
%         power_cell{i,j}=channel_cell{i,j}'*channel_cell{i,j};
    end
end    
end

function [Vrf,Vb]=precoder(H,Nrf,type)
if type==1 % 全随机波束成形
    Vrf=rand(size(H,1),Nrf);
    for i=1:size(Vrf,1)
        for j=1:size(Vrf,2)
            w=2*pi*rand;
            Vrf(i,j)=exp(w*1i);
        end
    end
    Vb=(H'*Vrf)'/norm(H'*Vrf,2);
elseif type==2 % 无约束的模拟预编码
    [~,~,V]=svd(H');
    transpose_V=V';
    Vrf=transpose_V(:,1:Nrf);
    Vrf=Vrf/norm(Vrf);
    Vb=(H'*Vrf)'/norm(H'*Vrf,2);
    Vb=Vb/norm(Vb);
elseif type==3 % 有约束的模拟预编码
    [~,~,V]=svd(H');
    transpose_V=V';
    Vrf=angle(transpose_V(:,1:Nrf));
    Vrf=Vrf/norm(Vrf);
    Vb=(H'*Vrf)'/norm(H'*Vrf);
    Vb=Vb/norm(Vb);
end
end