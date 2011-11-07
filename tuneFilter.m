function deltaFiltered = tuneFilter(delta,mintune,maxtune)
% based on read2Ch_single_bunch.m
[Nturns Npoints] = size(delta);

tune = 1/2*[linspace(0,1,Nturns/2) linspace(1,0,Nturns/2)]';

filterMask = (tune>mintune & tune<maxtune)*ones(1,Npoints);
deltaFourier = fft(delta);
deltaFourierFiltered = filterMask.*deltaFourier;
deltaFiltered = real(ifft(deltaFourierFiltered));
