function summary = smps_summary(params, Rin_esr, Rout_esr, dt)
% SMPS_SUMMARY Prints out a summary of all of the calculated parameters of
%              a given SMPS and also returns the summary in structure
%              format.
%
% Inputs:
%   params   - Switchmode voltage regulator parameters.
%   Rin_esr  - Input capacitor ESR value.
%   Rout_esr - Output capacitor ESR value.
%   dt       - Duty cycle of the PWM signal.
%
% Outputs:
%   summary - Summary of all the calculated parameters for the regulator.
%
% See also SMPS_BOOST.

% Convert frequency to time.
T = 1 / params.freq;

% Set some defaults in case of missing arguments.
mfnarg = nargin;
if nargin < 2
    Rin_esr = 0;
    Rout_esr = 0;
elseif nargin < 3
    Rout_esr = 0;
end

    function S = boost()
    % BOOST Calculates the summary for a Step-up (Boost) regulator.
        S = struct();
        
        % Calculate the duty cycle OFF time.
        Toff = (params.Vin / params.Vout) * T;
        if mfnarg >= 4
            Toff = T * (1 - dt);
        end
        
        % Nominal input current.
        S.Iin_nom = params.Iout * (params.Vout / params.Vin);
        
        % Nominal input current ripple.
        S.Iin_rpl_nom = (T / params.L) * params.Vin * ...
            (1 - (params.Vin / params.Vout));
        
        % Nominal minimum inductor value.
        S.Lmin_nom = (T / (2 * params.Iout)) * ...
            (params.Vout - params.Vin) * ((params.Vin / params.Vout) ^ 2);
        
        % Calculated Vout given duty cycle.
        S.Vout = params.Vin * (T / Toff);
        
        % Voltage ratios.
        Di = (params.Vin / S.Vout);
        D = 1 - Di;
        
        % Minimum output current to maintain continuous conduction mode.
        S.Iout_min = (T / (2 * params.L)) * S.Vout * D * (Di ^ 2);
        
        % Output capacitor ripple current.
        S.Iout_rpl = params.Iout / Di;
        
        % Inductor peak current.
        S.Il_pk = (params.Iout / Di) + (T / (2 * params.L)) * D * ...
            params.Vin;
        
        % Inductor ripple current.
        S.Il_rpl = (T / params.L) * params.Vin * D;
        
        % Inductor RMS current.
        S.Il_rms = sqrt(((params.Iout / Di) ^ 2) + ((S.Il_rpl ^ 2) / 12));
        
        % Minimum inductor value.
        S.Lmin = (T / (2 * params.Iout)) * (S.Vout - params.Vin) * ...
            (Di ^ 2);
        
        % Minimum input capacitor value.
        S.Cin_min = S.Il_rpl / (8 * params.Vin_rpl * params.freq);
        
        % Input voltage ripple from capacitor ESR.
        S.Vin_esr = S.Il_rpl * Rin_esr;
        
        % Minimum output capacitor value.
        S.Cout_min = (params.Iout * D) / (params.Vout_rpl * params.freq);
        
        % Output voltage ripple from capacitor ESR.
        S.Vout_esr = ((params.Iout / Di) + (S.Il_rpl / 2)) * Rout_esr;
        
        % Print out summary.
        fprintf('Step-up (Boost) Converter Summary\n\n');
        fprintf('Nominal values:\n\n');
        fprintf('\tVin       = %.1f V\n', params.Vin);
        fprintf('\tVout      = %.1f V\n', params.Vout);
        fprintf('\tIout      = %.3f A\n', params.Iout);
        fprintf('\tVin(rpl)  = %.3f V\n', params.Vin_rpl);
        fprintf('\tVout(rpl) = %.3f V\n', params.Vout_rpl);
        fprintf('\tIin       = %.3f A\n', S.Iin_nom);
        fprintf('\tIin(rpl)  = %.3f A\n', S.Iin_rpl_nom);
        fprintf('\tLmin      = %.0f uH\n', S.Lmin_nom * 1e6);
        fprintf('\nEstimated values:\n\n');
        fprintf('\tVout       = %.1f V\n', S.Vout);
        fprintf('\tDT         = %.0f%%\n', (1 - (Toff / T)) * 100);
        fprintf('\tIout(min)  = %.3f A\n', S.Iout_min);
        fprintf('\tLmin       = %.0f uH\n', S.Lmin * 1e6);
        fprintf('\tIcout(rpl) = %.3f A\n', S.Iout_rpl);
        fprintf('\tIl(pk)     = %.3f A\n', S.Il_pk);
        fprintf('\tIl(rms)    = %.3f A\n', S.Il_rms);
        fprintf('\nInductor selection guide (10%% margin):\n\n');
        fprintf('\tLmin >= %.0f uH\n', S.Lmin * 1e6 * 1.2);
        fprintf('\tIrms >= %.3f A\n', S.Il_rms * 1.1);
        fprintf('\tIsat >= %.3f A\n', S.Il_pk * 1.1);
        fprintf('\nCapacitor selection guide:\n\n');
        fprintf('\tCin(min)  = %.0f uF\n', S.Cin_min * 1e6);
        if Rin_esr ~= 0
            fprintf('\tVin(esr)  = %.3f V  (%.3f V)\n', S.Vin_esr, ...
                S.Vin_esr + params.Vin_rpl);
        end
        fprintf('\tCout(min) = %.0f uF\n', S.Cout_min * 1e6);
        if Rout_esr ~= 0
            fprintf('\tVout(esr) = %.3f V  (%.3f V)\n', S.Vout_esr, ...
                S.Vout_esr + params.Vout_rpl);
        end
    end

% Calculate the parameters given a specific topology.
if strcmpi(params.type, 'boost')
    % Step-up (Boost).
    summary = boost(); 
else
    % Invalid topology.
    disp('Invalid SMPS topology');
    return;
end
end