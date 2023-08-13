function params = smps_boost(Vin, Vout, Iout, freq, L, Vin_rpl, Vout_rpl)
% SMPS_BOOST Creates a structure representing the input parameters of a
%            DC-DC Switchmode Step-up (Boost) voltage regulator.
%
% Inputs:
%   Vin      - Nominal input voltage.
%   Vout     - Desired output voltage.
%   Iout     - Nominal output current.
%   freq     - Frequency of the PWM signal driving the inductor.
%   L        - Value of the main inductor.
%   Vin_rpl  - Acceptable input voltage ripple.
%   Vout_rpl - Acceptable output voltage ripple.
%
% Outputs:
%   params - Switchmode voltage regulator parameters.
%
% See also SMPS_SUMMARY.

params = struct('type', 'boost', 'Vin', Vin, 'Vout', Vout, ...
    'Iout', Iout, 'freq', freq, 'L', L, 'Vin_rpl', Vin_rpl, ...
    'Vout_rpl', Vout_rpl);

end