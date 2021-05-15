% 5.5小时
yita_dbm=-80;
Nrf=2;Nt=4;Nr=1;N0=10^(-143/10)/1000;yita=10^(yita_dbm/10)/1000;rrh=200;service_number=2;range=20;
user=8:3:33;
largescale_loop=500;smallscale_loop=1;
% largescale_loop=1;smallscale_loop=1;
R_baseline_usernumber=zeros(largescale_loop,size(user,2));
R_capacity_usernumber=zeros(largescale_loop,size(user,2));
R_distance_usernumber=zeros(largescale_loop,size(user,2));
% R_idealized=zeros(loop,size(user,2));
for i=1:size(user,2)
    for l=1:largescale_loop
        [RRH_matrix,USER_matrix,distance_matrix,LOS_matrix]=generate_largescale_matrix(user(1,i),rrh);
        while density_check(RRH_matrix,USER_matrix,max(service_number),distance_matrix,range)==0
            [RRH_matrix,USER_matrix,distance_matrix,LOS_matrix]=generate_largescale_matrix(user(1,i),rrh);
        end
        for k=1:smallscale_loop
            [channel_cell,precoder_cell,power_cell]=generate_smallscale_matrix(RRH_matrix,USER_matrix,LOS_matrix,Nrf,Nt,Nr,distance_matrix);
            R_baseline_usernumber(l,i)=R_baseline_usernumber(l,i)+get_R_baseline(yita,RRH_matrix,USER_matrix,service_number,power_cell,distance_matrix);
            R_capacity_usernumber(l,i)=R_capacity_usernumber(l,i)+get_R_capacity(yita,RRH_matrix,USER_matrix,service_number,power_cell,distance_matrix,range);
            R_distance_usernumber(l,i)=R_distance_usernumber(l,i)+get_R_distance(yita,RRH_matrix,USER_matrix,service_number,power_cell,distance_matrix,range);
%             R_idealized(l,i)=get_R_idealized(yita,RRH_matrix,USER_matrix,service_number,channel_cell);
        end
        R_baseline_usernumber(l,i)=R_baseline_usernumber(l,i)/smallscale_loop;
        R_capacity_usernumber(l,i)=R_capacity_usernumber(l,i)/smallscale_loop;
        R_distance_usernumber(l,i)=R_distance_usernumber(l,i)/smallscale_loop;
    end
end

new_R_baseline_usernumber=sum(R_baseline_usernumber,1)/largescale_loop;
new_R_capacity_usernumber=sum(R_capacity_usernumber,1)/largescale_loop;
new_R_distance_usernumber=sum(R_distance_usernumber,1)/largescale_loop;
% new_R_idealized=sum(R_idealized,1)/loop;

plot(user,new_R_baseline_usernumber,'b','LineWidth',2);hold on
plot(user,new_R_capacity_usernumber,'r','LineWidth',2);hold on
plot(user,new_R_distance_usernumber,'g','LineWidth',2);hold on
% plot(user,new_R_idealized,'m','LineWidth',2);hold on
set(gca,'XTick',user);
xlabel('Number of Users') ;
ylabel('System Downlink Capacity (bit/s/Hz)') ;
legend({'NCSRCR','IDPSO-C','IDPSO-D'},'Location','southeast');

function R_baseline=get_R_baseline(yita,RRH_matrix,USER_matrix,service_number,power_cell,distance_matrix)
R_baseline=0;
loop=3;
for j=1:loop
    R_baseline=R_baseline+sum(baseline_enhanced(yita,service_number,power_cell,distance_matrix));
end
R_baseline=R_baseline/loop;
end

function R_capacity=get_R_capacity(yita,RRH_matrix,USER_matrix,service_number,power_cell,distance_matrix,range)
R_capacity=0;
loop=1;
for j=1:loop
    R_capacity=R_capacity+sum(PSO_new_capacity(yita,RRH_matrix,USER_matrix,service_number,power_cell,distance_matrix,range));
end
R_capacity=R_capacity/loop;
end

function R_distance=get_R_distance(yita,RRH_matrix,USER_matrix,service_number,power_cell,distance_matrix,range)
R_distance=0;
loop=1;
for j=1:loop
    R_distance=R_distance+sum(PSO_new_distance(yita,RRH_matrix,USER_matrix,service_number,power_cell,distance_matrix,range));
end
R_distance=R_distance/loop;
end

function R_idealized=get_R_idealized(yita,RRH_matrix,USER_matrix,service_number,channel_cell)
R_idealized=0;
loop=1;
    for j=1:loop
        [selection,~]=idealized_selection(yita(1,end),RRH_matrix,USER_matrix,service_number,channel_cell);
        R_idealized=R_idealized+idealized_capacity(yita,selection,service_number,channel_cell);
    end
R_idealized=R_idealized/loop;
end