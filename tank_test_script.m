%Nitrous Oxide Parameters
pCrit = 72.51;     % critical pressure, Bar Abs 
rhoCrit = 452.0;   % critical density, kg/m3 
tCrit = 309.57;    % critical temperature, Kelvin (36.42 Centigrade) */
ZCrit = 0.28;      % critical compressibility factor 
gamma = 1.3;       % average over subcritical range 
nox_prop = [pCrit, rhoCrit, tCrit, ZCrit, gamma];

%Set Up time Vector
t_end = 8.3;
dt = 0.001; % time step
t = 0:dt:t_end;
max_t = length(t);

N2O_Tank_Time = zeros(21,max_t); 
N2O_Tank_Time(:,1) = Ox_Tank_InitV(nox_prop);
Comb_Chamber_Time = zeros(6,max_t);
Comb_Chamber_Time(:,1) = Comb_Chamber_Init;
N2O_Valve_Time = zeros(4, max_t);
N2O_Valve_Time(:,1) = [0,0,0,0];

for t_k=2:max_t
    if mod(t_k,20) == 0
        index = t_k/20;
        Comb_Chamber_Time(2, t_k) = Validation_Data2(index,3);
        Comb_Chamber_Time(1, t_k) = Validation_Data2(index,2);
        Comb_Chamber_Time(3, t_k) = Validation_Data2(index,6);
    else
        Comb_Chamber_Time(2, t_k) = Comb_Chamber_Time(2, t_k-1);
        Comb_Chamber_Time(1, t_k) = Comb_Chamber_Time(1, t_k-1);
        Comb_Chamber_Time(3, t_k) = Comb_Chamber_Time(3, t_k-1);
    end    
        
    N2O_Tank_Time(:,t_k) = ...
        Ox_Tank_UpdateV(N2O_Tank_Time(:, t_k-1), ...
                            Comb_Chamber_Time(:, t_k-1), ...
                            N2O_Valve_Time(:, t_k-1), ...
                            nox_prop, dt);
end    

figure(1);clf;hold on;
subplot(2,1,1)  
%plot(t,mdot,'r')
plot(t,N2O_Tank_Time(7,:),'r', ...
    t,Comb_Chamber_Time(1,:),'b'); %t,Comb_Chamber_Time(2,:),'k', ...
subplot(2,1,2)  
plot(t,N2O_Tank_Time(2,:),'r', ...
    t,Comb_Chamber_Time(3,:),'b');%,t,N2O_Tank_Time(10,:),'r')
%subplot(3,1,3); hold on;  
%plot(t,50*sw,'g')
%plot(t,m,'k')