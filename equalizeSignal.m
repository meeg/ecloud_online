function [deltaPROC t] = equalizeSignal(delta,time,meta)
% Recover_signal_new : Equalize (Deconvolution) the pick-up sigma using
% the CABLE, PICK-UP and FILTER transfer function.

%addpath('../Common Files/')

% Wideband Pickup Gain (measured 32101, assumed equal across pickups)
Kscale = 4.2;

% Data for different pick-ups
switch meta.pickup
	case 31901
		% Data for 319.01 (2x real length)
		a0 = 6.51e-5;
		a1 = 3.31e-10;
	case 32101
		% Data for 321.01 (2x real length)
		a0 = 8.21e-5;
		a1 = 3.35e-10;
	case 31798
		% Data for 317.98 (2x real length)
		a0 = 4.2825606743214e-5;
		a1 = 2.430268150833e-10;
	case 31931
		% Data for 319.31 (2x real length)
		a0 = 5.55e-5;
		a1 = 3.29e-10;
end

% Find final attenuation values, grab from loaded metadata
Att_delta = meta.attenuation.preHybrid ...
	* meta.attenuation.hybridCommon * meta.attenuation.delta;

% frequency vectors
f = (0:meta.nPoints-1)/meta.nPoints/meta.sampleTime;

% Make frequency vector into what the frequencies actually are
if rem(meta.nPoints, 2)
	% number of points is odd
	fp = f(1:(meta.nPoints+1)/2);
	fn = -fp(2:end);
	f  = [fp fliplr(fn)];
else
	% number of points is even
	fp = f(1:meta.nPoints/2+1);
	fn = -fp(2:end-1);
	f  = [fp fliplr(fn)];
end

% Pick-up physical properties
L = 0.375;	% pickup length
v = 300e6;	% particle velocity
a = 2.48;	% TODO

w = 2*pi*f;		% frequencies of interest
x1 = 2*w*L/v;	% ??, radians...

t1 = sin(x1);			%
t2 = exp(a) - cos(x1);	%

img = x1.*t1 + a.*t2;	% sinc like?
rel = x1.*t2 - a.*t1;	%

% What is this? The time expected time response of the stripline?
fun_mag = Kscale*(x1./sqrt(a^2+x1.^2)).*sqrt(1 + exp(-2*a) - 2*exp(-a)*cos(x1));


fun_dirB = fun_mag.*exp(1i*atan2(img,rel));

tf_p = exp((-a0*(1+1j)*0.707*sqrt(2*fp)-a1*fp)/2);
tf_n = exp((-a0*(1-1j)*0.707*sqrt(2*abs(fn))+a1*fn)/2);

tf_c = [tf_p fliplr(tf_n)];

% Filter to cut the very high frequencies
f_cut_start = 2e9;
f_cut_end = 3e9;

LIM_cut = ones(size(tf_c));
k1p = find(f<f_cut_start & f>0);
k2p = find(f<f_cut_end & f>0);
Np = max(k2p) - max(k1p);

k1n = find(f>-f_cut_start & f<0);
k2n = find(f>-f_cut_end & f<0);
Nn = min(k1n) - min(k2n);

sp = max(k1p):min(k1n);
LIM_cut(sp) = [(1+cos(pi*(0:Np-1)/Np))/2 zeros(1,min(k2n)-max(k2p)+1) (1-cos(pi*(0:Nn-1)/Nn))/2];

% High Pass Filter
fHP = 10e6;
LIM_hpf = abs(f) >= fHP;

% Get an 8th ordered bessel LPF at 800MHz
f_LP = 800e6;
LIM_lpf = besselFilter(f,8,f_LP);

% Give back DC response to the LPF
LIM_lpf(f==0) = 1;

% Find the final
LIM = LIM_cut .* LIM_hpf .* LIM_lpf;

% Save information on filtering
meta.filter.hpf = fHP;
meta.filter.lpf = f_LP;
meta.filter.cut_start = f_cut_start;
meta.filter.cut_end = f_cut_end;





% Deconvolution --------------------------------

fun_dirB(1) = fun_dirB(2); % why?

% Pre-allocate Output Array
deltaPROC = zeros(meta.nTurns, meta.nPoints);

% Calculate Correction Signal
deltaCorrection = LIM./(2*tf_c.*fun_dirB*Att_delta);

% Start FFT optimization
%fftw('planner','measure');

% Equalize across turns
for turn = 1:meta.nTurns
	
	OSC_delta_meas = fft(delta(turn,:));
	
	delta_freq = deltaCorrection.*OSC_delta_meas;
	
	deltaPROC(turn,:) = real(ifft(delta_freq));
	
end

end

function TF = besselFilter(f,order,cutoff)
% BESSELFILTER calculate the complex transfer function of a bessel filter
%
%   TF = besselFilter(f,order,cutoff)

% Adjust the cutoff frequency
f_LP = cutoff / pi;

% Define the bessel polynomial
y = @(n,x) sqrt((2/pi)* x) .* exp(x) .* besselk(-n-.5,x); % note, x should be 1/x, but cancels with next

% Define the reverse bessel polynomial
theta = @(n,x) x.^n .* y(n,x);								% note, x should be 1/x, but cancels with previous

% This is the definition of the Bessel Filter
TF = theta(order,1e-9)./theta(order,-1i/f_LP*f);

end
