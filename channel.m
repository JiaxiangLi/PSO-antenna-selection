% 本程序即建立基本s-v模型的信道模型
% 具体的参考文献是Cell-free and user-centric massive MIMO at millimeter wave frequencies
% 以及Energy-Efficient Downlink Power Control in mmWave Cell-free and User-centric Massive MIMO
% 入射角，出射角均建模为全角度均匀分布
% 发射天线数目为4，接受天线数目为1
% 需要定义函数衰减函数L，和空间特征值函数a
% 该信道矩阵也是一个函数，输入变量为第m个AP的坐标，第k个User的坐标（用于计算距离），输出是一个Nt*Nr维矩阵

function channel=channel(x1,y1,x2,y2,Nt,Nr)
Ncl=max(1,poissrnd(1.9));Nray=20;frequency=73e9;a=randn(1);
% 这里选用文献On Clustered Statistical MIMO Millimeter Wave Channel Simulation
channel=Channel(x1,y1,x2,y2,Nt,Nr,Ncl,Nray,frequency,a);
end

function H=Channel(x1,y1,x2,y2,Nt,Nr,Ncl,Nray,frequency,a)
H=zeros(Nt,Nr);
lambda=(3*10^8)/frequency;
d=distance(x1,y1,x2,y2);
for i=1:Ncl
    theta=rand(1)*2*pi;
    % 这里的思路：簇内的射线之间，入射出射角一样；簇与簇之间，入射出射角不一样，重新生成
    for j=1:Nray
%         H=H+a*L_nlos(d,lambda)^1/2*spatial_feature_map(theta,Nt)*(spatial_feature_map(theta,Nr)');
        H=H+a*L_nlos(d,lambda)^1/2*(Array_response(1,4,theta,0,pi)')*Array_response(1,4,theta,0,pi);
    end
end
H=(Nt*Nr/Ncl*Nray)^1/2*H+H_los(d,Nt,Nr,lambda);
end

function h=H_los(d,Nt,Nr,lambda)
I=rand(1)<min(20/d,1)*(1-exp(-d/39))+exp(-d/39);
% h=I*(Nr*Nt)^1/2*exp(1i*rand(1)*2*pi)*L_los(d,lambda)^1/2*spatial_feature_map(0,Nt)*(spatial_feature_map(0,Nr)');
% 有点问题，不会算直射路径的入射角和出射角，这里全用0度来代替了
h=I*(Nr*Nt)^1/2*exp(1i*rand(1)*2*pi)*L_los(d,lambda)^1/2*(Array_response(1,4,0,0,pi)')*Array_response(1,4,0,0,pi);
end

function l=L_nlos(d,lambda)
l=Evaluation_Path_loss(d,3e08/lambda,2,0);
end

function l=L_los(d,lambda)
l=Evaluation_Path_loss(d,3e08/lambda,2,1);
end

function e=spatial_feature_map(theta,n)
e=zeros(n,1);
for k=1:n
    e(k,1)=(n)^(-1/2)*exp(-1i*2*(k-1)*pi*cos(theta)*1/2);
end
end

function L=Evaluation_Path_loss(path_length,f,scenario,LOS)
% Function for the evaluation of the attenuation as in equation(2) in
%
% S. Buzzi, C. D'Andrea , "On Clustered Statistical MIMO Millimeter Wave Channel Simulation",
% submitted to IEEE Wireless Communications Letters
%
% The values used here are in Table I in the paper listed above.
%
% License: This code is licensed under the GPLv2 License.If you in any way 
% use this code for research that results in publications, please cite our
% original article listed above.
%
% 
% path_length: the length of the path of which the function calculate the
% attenuation 
% 
% f: is the carrier frequency
% 
% scenario: variable that contains information about the use-case scenario,
% it assumes the values:
% - scenario==1  ==> 'Open square'
% - scenario==2  ==> 'Street Canyon'
% - scenario==3  ==> 'Indoor Office'
% - scenario==4  ==> 'Shopping mall'
% 
% LOS: variable that is '1' if transmitter and receiver are in LOS and '0'
% otherwise
% 
% 
% 
% L: attenuation of the path in the indicated scenario expressed in
% naturals

if scenario==1 % 'Open square'
    if LOS==1
        n=1.85;
        sigma=4.2;
        b=0;
        f0=1e9;
    else
        n=2.89;
        sigma=7.1;
        b=0;
        f0=1e9;        
    end
elseif scenario==2 % 'Street Canyon'
    if LOS==1
        n=1.98;
        sigma=3.1;
        b=0;
        f0=1e9;        
    else
        n=3.19;
        sigma=8.2;
        b=0;
        f0=1e9;        
    end
elseif scenario==3 % 'Indoor Office'
    if LOS==1
        n=1.73;
        sigma=3.02;
        b=0;
        f0=1e9;       
    else
        n=3.19;
        sigma=8.29;
        b=0.06;
        f0=24.2e9;        
    end 
elseif scenario==4 % 'Shopping mall'
    if LOS==1
        n=1.73;
        sigma=2.01;
        b=0;
        f0=1e9;        
    else
        n=2.59;
        sigma=7.40;
        b=0.01;
        f0=39.5e9;        
    end
end
L_dB=20*log10(4*pi*f/3e8)+10*n*(1+b*((f-f0)/f0))*log10(path_length)+normrnd(0,sigma);

L=10^(-L_dB/10);

end

function a=Array_response(Y,Z,phi,theta,kd)
% This Function generates array response of a planar uniform array as in
%
% S. Buzzi, C. D'Andrea , "On Clustered Statistical MIMO Millimeter Wave Channel Simulation",
% submitted to IEEE Wireless Communications Letters
%
% License: This code is licensed under the GPLv2 License.If you in any way 
% use this code for research that results in publications, please cite our
% original article listed above.
% 
% 
% 
% % Y and Z: number of antennas on the y and x axes of the
% % planar array (e.g., 10 and 5 for a planar array with 50 antennas);
% 
% % phi and theta: are the position in azimuth and elevation of 
% % the considered path;
% 
% % kd: product of wavenumber,2*pi/lambda, and 
% % the inter-element spacing of the array.
% 
% 
% 
% % a: array response of planar array, column vector with Y*Z elements and
% % unitary norm.

A=zeros(Y,Z); % initialize a temporary matrix 
for m=1:Y
    for n=1:Z
       A(m,n)=exp(1j*kd*((m-1)*sin(phi)*sin(theta)+(n-1)*cos(theta))); % calculate the element of temporary matrix 
    end
end
a=A(:)/sqrt(Y*Z); %dispose elements in a vector
end


% 2020.10.5 by LiJiaxiang