yita_dbm=-80;
Nrf=2;Nt=4;Nr=1;N0=10^(-143/10)/1000;yita=10^(yita_dbm/10)/1000;user=15;rrh=200;range=20;
service_number=1:1:5; 
% largescale_loop=400;smallscale_loop=1;
largescale_loop=1;smallscale_loop=1;
R_baseline_service_number=zeros(largescale_loop,size(service_number,2));
R_capacity_service_number=zeros(largescale_loop,size(service_number,2));
R_distance_service_number=zeros(largescale_loop,size(service_number,2));
% R_idealized_service_number=zeros(loop,size(service_number,2));
for l=1:largescale_loop
    [RRH_matrix,USER_matrix,distance_matrix,LOS_matrix]=generate_largescale_matrix(user,rrh);
    while density_check(RRH_matrix,USER_matrix,max(service_number),distance_matrix,range)==0
        [RRH_matrix,USER_matrix,distance_matrix,LOS_matrix]=generate_largescale_matrix(user,rrh);
    end
    for k=1:smallscale_loop
        [channel_cell,precoder_cell,power_cell]=generate_smallscale_matrix(RRH_matrix,USER_matrix,LOS_matrix,Nrf,Nt,Nr,distance_matrix);
        R_baseline_service_number(l,:)=R_baseline_service_number(l,:)+get_R_baseline(yita,RRH_matrix,USER_matrix,service_number,power_cell,distance_matrix);
        R_capacity_service_number(l,:)=R_capacity_service_number(l,:)+get_R_capacity(yita,RRH_matrix,USER_matrix,service_number,power_cell,distance_matrix,range);
        R_distance_service_number(l,:)=R_distance_service_number(l,:)+get_R_distance(yita,RRH_matrix,USER_matrix,service_number,power_cell,distance_matrix,range);
%         R_idealized_service_number(l,:)=get_R_idealized(yita,RRH_matrix,USER_matrix,service_number,channel_cell);
    end
    R_baseline_service_number(l,:)=R_baseline_service_number(l,:)/smallscale_loop;
    R_capacity_service_number(l,:)=R_capacity_service_number(l,:)/smallscale_loop;
    R_distance_service_number(l,:)=R_distance_service_number(l,:)/smallscale_loop;
end
new_R_baseline_service_number=sum(R_baseline_service_number,1)/largescale_loop;
new_R_capacity_service_number=sum(R_capacity_service_number,1)/largescale_loop;
new_R_distance_service_number=sum(R_distance_service_number,1)/largescale_loop;
% new_R_idealized_service_number=sum(R_idealized_service_number,1)/loop;

plot(service_number,new_R_baseline_service_number,'b:','LineWidth',2);hold on
plot(service_number,new_R_capacity_service_number,'r--','LineWidth',2);hold on
plot(service_number,new_R_distance_service_number,'g','LineWidth',2);hold on
% plot(service_number,new_R_idealized,'m','LineWidth',2);hold on
set(gca,'XTick',service_number);
xlabel('Number of RRHs') ;
ylabel('Sum Rate (bit/s/Hz)') ;
legend({'NN','IDPSO-C','IDPSO-D'},'Location','southwest');

function R_baseline=get_R_baseline(yita,RRH_matrix,USER_matrix,service_number,power_cell,distance_matrix)
R_baseline=zeros(1,size(service_number,2));
loop=3; 
for i=1:size(service_number,2)
    for j=1:loop
        R_baseline(1,i)=R_baseline(1,i)+sum(baseline_enhanced(yita,service_number(1,i),power_cell,distance_matrix,RRH_matrix,USER_matrix));
    end
end
R_baseline=R_baseline/loop;
if R_baseline==0
    disp('check');
end
end

function R_capacity=get_R_capacity(yita,RRH_matrix,USER_matrix,service_number,power_cell,distance_matrix,range)
R_capacity=zeros(1,size(service_number,2));
loop=1;
for i=1:size(service_number,2)
    for j=1:loop
        R_capacity(1,i)=R_capacity(1,i)+sum(PSO_new_capacity(yita,RRH_matrix,USER_matrix,service_number(1,i),power_cell,distance_matrix,range));
    end
end
R_capacity=R_capacity/loop;
end

function R_distance=get_R_distance(yita,RRH_matrix,USER_matrix,service_number,power_cell,distance_matrix,range)
R_distance=zeros(1,size(service_number,2));
loop=1;
for i=1:size(service_number,2)
    for j=1:loop
        R_distance(1,i)=R_distance(1,i)+sum(PSO_new_distance(yita,RRH_matrix,USER_matrix,service_number(1,i),power_cell,distance_matrix,range));
    end
end
R_distance=R_distance/loop;
end

function R_idealized=get_R_idealized(yita,RRH_matrix,USER_matrix,service_number,channel_cell)
R_idealized=zeros(1,size(service_number,2));
loop=1;
for i=1:size(service_number,2)
    for j=1:loop
        % 这里少函数别忘了
        [R,S]=idealized_selection(yita,RRH_matrix,USER_matrix,service_number,channel_cell);
        R_idealized(1,i)=R_idealized(1,i)+R;
    end
end
R_idealized=R_idealized/loop;
end

