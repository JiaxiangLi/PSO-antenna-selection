function [R,S]=PSO_new_distance(yita,RRH_matrix,USER_matrix,service_number,power_cell,distance_matrix,range)
NP = 100;                         % 种群个数
G = 200;                          % 迭代次数
rrh=size(RRH_matrix,1);
user=size(USER_matrix,1);
x=zeros(user,rrh,NP);
new_distance_matrix=distance_matrix.^(-3.19);

for i=1:NP
    x(:,:,i)=generate_initial_particle(user,rrh,service_number,distance_matrix,range);
end
[r,s]=baseline_enhanced(yita,service_number,power_cell,distance_matrix,RRH_matrix,USER_matrix);
x(:,:,NP)=s;

plot_y=1:G;plot_a=1:G;
individual_best = x;            %  每个个体的历史最优
pbest = zeros(NP, 1);           %  个体最优位置对应的适应度值
for k=1:NP
    pbest(k, 1) = sum(fitness_based_distance_for_multiple_user(yita,individual_best(:,:,k),service_number,new_distance_matrix));
end
global_best = zeros(user,rrh);
global_best_fit = zeros(user,1);
for k=1:NP
    temp = fitness_based_distance_for_multiple_user(yita,individual_best(:,:,k),service_number,new_distance_matrix);
    if sum(temp) > sum(global_best_fit)
        global_best = individual_best(:,:,k);
        global_best_fit = temp;
    end
end
for gen = 1:G
    for k=1:NP
        x(:,:,k)=iteration(x(:,:,k),global_best,individual_best(:,:,k),distance_matrix,range);
    end
    % 计算个体历史最优与全局最优
    % 个体历史最优
    for k=1:NP
        old_fitness = sum(fitness_based_distance_for_multiple_user(yita,individual_best(:,:,k),service_number,new_distance_matrix));
        new_fitness = sum(fitness_based_distance_for_multiple_user(yita,x(:,:,k),service_number,new_distance_matrix));
        if new_fitness > old_fitness
            individual_best(:,:,k) = x(:,:,k);
            pbest(k, 1) = new_fitness;
        end
    end
    % 全局最优
    for k=1:NP
        temp = fitness_for_multiple_user(yita,individual_best(:,:,k),service_number,new_distance_matrix);
        if sum(temp) > sum(global_best_fit)
            global_best = individual_best(:,:,k);
            global_best_fit = temp;
        end
    end
    plot_y(1,gen)=sum(real(global_best_fit));
    plot_a(1,gen)=sum(real(fitness_for_multiple_user(yita,global_best,service_number,power_cell)));
    if gen>20 && plot_y(1,gen)==plot_y(1,gen-20)
        break
    end
end
S=global_best;
R=real(fitness_for_multiple_user(yita,global_best,service_number,power_cell));
% % if plot_y(1,1)==plot_y(1:gen)
% %     disp('迭代过程未更新全局最优')
% % end
% plot_x=1:G;
% plot(plot_x(1:gen),plot_y(1:gen),'g','LineWidth',2);
% xlim([1 gen]);
% set(gca,'XTick',1:3:gen);
% % title(['Global Best of fitness function vs Iteration Process']);
% % xlabel('Number of iterations') ;
% % ylabel('The result of fitness function of Global Best') ;
% hold on
% % f2=figure;
% % plot(plot_x(1:gen),plot_a(1:gen),'r','LineWidth',2);
% % title(['System Downlink Capacity vs Iteration Process']);
% % xlabel('Number of iterations') ;
% % ylabel('System downlink channel capacity (bit/s/Hz)') ;
end

function s=iteration(x,global_best,individual_best,distance_matrix,range)
s=x;
c=rand(size(x,1),size(x,2)).*(individual_best-x)+rand(size(x,1),size(x,2)).*(global_best-x);
c_negative=c;c_positive=c;
c_negative(c_negative>0)=0;
c_positive(c_positive<0)=0;
c_negative=c_negative./sum(c_negative,2);
c_positive=c_positive./sum(c_positive,2);
c_negative(isnan(c_negative))=0;
c_positive(isnan(c_positive))=0;   
% 以上生成了一正一负的概率矩阵，行和为1（或者-1）
% 下面则根据概率矩阵发生关于s的变动。生成的0-1之间的随机数如果大于负概率矩阵中该位置的元素，则发生从1到0的改变。
% 同时在该行中，根据概率选择一个位置发生从0到1的改变。
for i=1:size(s,1)
    for j=1:size(s,2)
        if c_positive(i,j)>rand() && distance_matrix(i,j)<range && isequal(s(:,j),zeros(size(x,1),1))
            s(i,j)=1;
            s(i,find_change_elements(c_negative(i,:),j))=0;
        end
    end
end
end

function p=find_change_elements(probility_array,j)
pc=cumsum(probility_array);
n=find(pc>rand());
if size(n,2)==0
    p=j;
    return
end
p=n(1);
end

function x=generate_initial_particle(user,rrh,service_number,distance_matrix,range)
x=zeros(user,rrh);
row_index=randperm(user);
column_index=randperm(rrh);
set=eye(user);
for i=1:user
    check=0;
    for j=1:rrh
        if check<service_number && distance_matrix(row_index(i),column_index(j))<=range && isequal(x(:,column_index(j)),zeros(user,1))
           check=check+1; 
           x(:,column_index(j))=set(:,row_index(i));
        end
    end
end
end