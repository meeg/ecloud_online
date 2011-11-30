function show_spec(delta,outputFile)

if exist('OCTAVE_VERSION')
	fprintf('No spectrograms in Octave\n');
	return
end

clf
[Npoints Nturns] = size(delta)

delta_rms = sqrt(mean((delta-mean(delta,2)*ones(1,Nturns)).^2,2));
plot(delta_rms)
if nargin>1
	print(gcf,'-dpng',strcat(outputFile,'_delta_rms.png'));
end


%clf
%if Nturns>2^12
%	nfft=2^11;
%	increment=2^8;
%else
%	nfft=2^8;
%	increment=2^5;
%end

%nfft = 2^(nextpow2(Nturns)-4);

scale = min(nextpow2(Nturns)-2,10);
nfft = 2^scale
increment = 2^(scale-3);

colormap(jet);

[max_rms rms_peak] = max(delta_rms)

left_min = min(delta_rms(1:rms_peak))
left_threshold = left_min+0.1*(max_rms-left_min)
right_min = min(delta_rms(rms_peak:end))
right_threshold = right_min+0.1*(max_rms-right_min)

for i=5:5:Npoints
	if i<rms_peak
		if delta_rms(i)<left_threshold
			continue
		end
	else
		if delta_rms(i)<right_threshold
			continue
		end
	end
	fprintf('making spectrogram of point %d\n',i);
	[S F T P] = spectrogram(delta(i,:),nfft,nfft-increment,nfft);
	freqs = F/(2*pi);
	freq_indices=find(freqs>0.15 & freqs<0.25);
	surf(T*2*pi,freqs(freq_indices),10*log10(P(freq_indices,:)),'edgecolor','none');
	view(0,90);
	%contourf(T,freqs(freq_indices),10*log10(P(freq_indices,:)));
	if nargin>1
		print(gcf,'-dpng',strcat(outputFile,'_spectrogram_',int2str(i),'.png'));
	end
end
end
