function Hd = buildFilt(stop1,pass1,pass2,stop2)

global Fs

Fstop1 = stop1;  % First Stopband Frequency
Fpass1 = pass1;    % First Passband Frequency
Fpass2 = pass2;   % Second Passband Frequency
Fstop2 = stop2;   % Second Stopband Frequency
Astop1 = 60;   % First Stopband Attenuation (dB)
Apass  = 1;    % Passband Ripple (dB)
Astop2 = 60;   % Second Stopband Attenuation (dB)

h = fdesign.bandpass('fst1,fp1,fp2,fst2,ast1,ap,ast2', Fstop1, Fpass1, ...
    Fpass2, Fstop2, Astop1, Apass, Astop2, Fs);

Hd = design(h, 'equiripple', ...
    'MinOrder', 'any');

end

