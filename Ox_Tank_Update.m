function N2O_Tank = Ox_Tank_Update(N2O_Tank, Comb_Chamber, N2O_Valve, ...
                                    nox_prop, dt)
%ranges of function validity
tank_liquid_mass = N2O_Tank(3);
first_vapour_it = N2O_Tank(15);
tank_pressure = N2O_Tank(7);
mdot_tank_outflow = N2O_Tank(11);
   
    if (tank_liquid_mass < .0001) || (first_vapour_it == 0)
         N2O_Tank = tank_no_liquid(N2O_Tank, Comb_Chamber, N2O_Valve, ...
                                    nox_prop, dt);
    else
        N2O_Tank = tank_with_liquid(N2O_Tank, Comb_Chamber, N2O_Valve, ...
                                    nox_prop, dt);
    end
end