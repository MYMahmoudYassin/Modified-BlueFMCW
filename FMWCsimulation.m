%%FMWC radar simulation
%  System parameters            Value
%  ----------------------------------
%  Operating frequency (GHz)    77
%  Maximum target range (m)     200
%  Range resolution (m)         1
%  Maximum target speed (km/h)  230
%  Sweep time (microseconds)    7.33
%  Sweep bandwidth (MHz)        150
%  Maximum beat frequency (MHz) 27.30
%  Sample rate (MHz)            150

clear;clc;clf;
fc = 77e9;
c = 3e8;
lambda = c/fc;
range_max = 200;
tm = 5.5*range2time(range_max,c);
%---------------------------------------------
range_res = 1;
bw = rangeres2bw(range_res,c);
sweep_slope = bw/tm;
fr_max = range2beat(range_max,sweep_slope,c);
v_max = 230*1000/3600;
fd_max = speed2dop(2*v_max,lambda);
fb_max = fr_max+fd_max;
fs = max(2*fb_max,bw);
%%
% set up the FMCW waveform used in the radar system.

waveform = phased.FMCWWaveform('SweepTime',tm,'SweepBandwidth',bw, ...
    'SampleRate',fs);

%%
%up-sweep linear FMCW signal
sig = waveform();
figure
subplot(211); plot(0:1/fs:tm-1/fs,real(sig));
xlabel('Time (s)'); ylabel('Amplitude (v)');
title('FMCW signal'); axis tight;
subplot(212); spectrogram(sig,32,16,32,fs,'yaxis');
title('FMCW signal spectrogram');

%% Target Model
%  ACC radar with a car in front of it.

car_dist = 43;
car_speed = 96*1000/3600;
car_rcs = db2pow(min(10*log10(car_dist)+5,20));
cartarget = phased.RadarTarget('MeanRCS',car_rcs,'PropagationSpeed',c,...
    'OperatingFrequency',fc);
carmotion = phased.Platform('InitialPosition',[car_dist;0;0.5],...
    'Velocity',[car_speed;0;0]);

%%
% Assume the propagation model to be free space.

channel = phased.FreeSpace('PropagationSpeed',c,...
    'OperatingFrequency',fc,'SampleRate',fs,'TwoWayPropagation',true);

%% Radar System Setup
ant_aperture = 6.06e-4;                         % in square meter
ant_gain = aperture2gain(ant_aperture,lambda);  % in dB

tx_ppower = db2pow(5)*1e-3;                     % in watts
tx_gain = 9+ant_gain;                           % in dB

rx_gain = 15+ant_gain;                          % in dB
rx_nf = 4.5;                                    % in dB

transmitter = phased.Transmitter('PeakPower',tx_ppower,'Gain',tx_gain);
receiver = phased.ReceiverPreamp('Gain',rx_gain,'NoiseFigure',rx_nf,...
    'SampleRate',fs);

%%
% Automotive radars are generally mounted on vehicles, so they are often in
% motion. This example assumes the radar is traveling at a speed of 100
% km/h along x-axis. So the target car is approaching the radar at a
% relative speed of 4 km/h.

radar_speed = 100*1000/3600;
radarmotion = phased.Platform('InitialPosition',[0;0;0.5],...
    'Velocity',[radar_speed;0;0]);

%% Radar Signal Simulation
specanalyzer = dsp.SpectrumAnalyzer('SampleRate',fs,...
    'PlotAsTwoSidedSpectrum',true,...
    'Title','Spectrum for received and dechirped signal',...
    'ShowLegend',true);

%% run the simulation loop. 

rng(2022);
Nsweep = 64;
xr = complex(zeros(waveform.SampleRate*waveform.SweepTime,Nsweep));

for m = 1:Nsweep
    % Update radar and target positions
    [radar_pos,radar_vel] = radarmotion(waveform.SweepTime);
    [tgt_pos,tgt_vel] = carmotion(waveform.SweepTime);

    % Transmit FMCW waveform
    sig = waveform();
    txsig = transmitter(sig);
    
    % Propagate the signal and reflect off the target
    txsig = channel(txsig,radar_pos,tgt_pos,radar_vel,tgt_vel);
    txsig = cartarget(txsig);
    
    % Dechirp the received radar return
    txsig = receiver(txsig);    
    dechirpsig = dechirp(txsig,sig);
    
    % Visualize the spectrum
    specanalyzer([txsig dechirpsig]);
    
    xr(:,m) = dechirpsig;
end
%% Range and Doppler Estimation
% Before estimating the value of the range and Doppler, take a look at the zoomed range Doppler response of all
% 64 sweeps.

rngdopresp = phased.RangeDopplerResponse('PropagationSpeed',c,...
    'DopplerOutput','Speed','OperatingFrequency',fc,'SampleRate',fs,...
    'RangeMethod','FFT','SweepSlope',sweep_slope,...
    'RangeFFTLengthSource','Property','RangeFFTLength',2048,...
    'DopplerFFTLengthSource','Property','DopplerFFTLength',256);

figure
plotResponse(rngdopresp,xr);                     % Plot range Doppler map
axis([-v_max v_max 0 range_max])
clim = caxis;

%% the decimation process.

Dn = fix(fs/(2*fb_max));
for m = size(xr,2):-1:1
    xr_d(:,m) = decimate(xr(:,m),Dn,'FIR');
end
fs_d = fs/Dn;

%% Using the root MUSIC algorithm to extract both the beat frequency and the
% Doppler shift.

fb_rng = rootmusic(pulsint(xr_d,'coherent'),1,fs_d);% calulating the beat frequency 

rng_est = beat2range(fb_rng,sweep_slope,c)% convert to range


%%
%calculating the Doppler shift across the sweeps at the range of the target
%is occured.
peak_loc = val2ind(rng_est,c/(fs_d*2));
fd = -rootmusic(xr_d(peak_loc,:),1,1/tm);
v_est = dop2speed(fd,lambda)/2


