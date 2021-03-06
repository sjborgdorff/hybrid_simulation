function N2O_Tank = tank_no_liquid(N2O_Tank, Comb_Chamber, ...
                                    N2O_Valve, nox_prop, dt)
%subroutine to model the tank emptying of vapour only
%Isentropic vapour-only blowdown model
    %capture initial conditions
    
    pCrit = nox_prop(1);
    ZCrit = nox_prop(4);
    gamma = nox_prop(5);
    
    chamber_press_bar = Comb_Chamber(2);
    tank_volume = N2O_Tank(1); 
    tank_fluid_temperature_K = N2O_Tank(2);
    tank_liquid_mass = N2O_Tank(3);
    tank_vapour_mass = N2O_Tank(4);
    tank_liquid_mass_old = N2O_Tank(5);
    tank_vapour_mass_old = N2O_Tank(6);
    tank_pressure_bar = N2O_Tank(7);
    tank_propellant_contents_mass = N2O_Tank(8);
    tank_vapour_density = N2O_Tank(10);  
    mdot_tank_outflow = N2O_Tank(11);
    mdot_tank_outflow_old = N2O_Tank(21);
    first_vapour_it = N2O_Tank(15);
    
    if (first_vapour_it == 1)
        initial_vapour_temp_K = N2O_Tank(2);
        initial_vapour_mass = N2O_Tank(4);
        initial_vapour_pressure_bar = N2O_Tank(7);
        initial_vapour_density = N2O_Tank(10);
        initial_Z = ...
            LinearInterpolate(tank_pressure_bar, 0.0, 1.0, pCrit, ZCrit);
        old_mdot_tank_outflow = 0.0; %reset
        first_vapour_it = 0;
        N2O_Tank(15) = first_vapour_it;
        N2O_Tank(16) = initial_vapour_temp_K;
        N2O_Tank(17) = initial_vapour_mass;
        N2O_Tank(18) = initial_vapour_pressure_bar;
        N2O_Tank(19) = initial_vapour_density;
        N2O_Tank(20) = initial_Z;
    else
        initial_vapour_temp_K = N2O_Tank(16);
        initial_vapour_mass = N2O_Tank(17);
        initial_vapour_pressure_bar = N2O_Tank(18);
        initial_vapour_density = N2O_Tank(19);
        initial_Z = N2O_Tank(20);
    end
    
    % integrate mass flowrate using Addams second order integration formula 
    %Xn = X(n-1) + DT/2 * ((3 * Xdot(n-1) - Xdot(n-2)));
    mdot_tank_outflow = N2O_Flow_Rate(N2O_Tank, Comb_Chamber, N2O_Valve);                                    
    %delta_outflow_mass = 0.5 * dt * ...
    %    (3.0 * mdot_tank_outflow - mdot_tank_outflow_old);
    % drain the tank based on flowrates only
    % update mass within tank for next iteration
    tank_propellant_contents_mass = ...
        tank_propellant_contents_mass - mdot_tank_outflow * dt;
    % drain off vapour
    % update vapour mass within tank for next iteration
    tank_vapour_mass = tank_vapour_mass - mdot_tank_outflow * dt; 
    % initial guess
    current_Z_guess = ...
        LinearInterpolate(tank_pressure_bar, 0.0, 1.0, pCrit, ZCrit);
    %set current_Z to value to ensure at least one loop iteration occurs
    current_Z = 2*current_Z_guess; 
    step = 1.0 / 0.9; % initial step size
    OldAim = 2; 
    Aim = 0; % flags used below to home-in
    % recursive loop to get correct compressibility factor
    while (((current_Z_guess / current_Z) > 1.000001) || ...
        ((current_Z_guess / current_Z) < (1.0/ 1.000001)) );
        % use isentropic relationships
        bob = gamma - 1.0;
        tank_fluid_temperature_K = initial_vapour_temp_K * ...
            (((tank_vapour_mass * current_Z_guess)...
            /(initial_vapour_mass * initial_Z))^bob);
        bob = gamma / (gamma - 1.0);
        tank_pressure_bar = initial_vapour_pressure_bar ...
            * ((tank_fluid_temperature_K /initial_vapour_temp_K)^bob);
        current_Z = ...
            LinearInterpolate(tank_pressure_bar, 0.0, 1.0, pCrit, ZCrit);
        OldAim = Aim;
        if (current_Z_guess < current_Z)
            current_Z_guess = current_Z_guess * step;
            Aim = 1;
        else
            current_Z_guess = current_Z_guess / step;
            Aim = -1;
            % check for overshoot of target, and if so, 
            %reduce step nearer to 1.0
            if (Aim == -OldAim)
                step = sqrt(step);
            end    
        end
    end
    bob = 1.0 / (gamma - 1.0);
    tank_vapour_density = initial_vapour_density ...
        *((tank_fluid_temperature_K / initial_vapour_temp_K)^bob);
    
    N2O_Tank(2) = tank_fluid_temperature_K;
    N2O_Tank(4) = tank_vapour_mass;
    N2O_Tank(6) = tank_vapour_mass_old;
    N2O_Tank(7) = tank_pressure_bar;
    N2O_Tank(13) = tank_volume;
    N2O_Tank(8) = tank_propellant_contents_mass;
    N2O_Tank(10) = tank_vapour_density;
    N2O_Tank(11) = mdot_tank_outflow;
    N2O_Tank(21) = mdot_tank_outflow_old;
    N2O_Tank(15) = first_vapour_it;
end