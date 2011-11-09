function show_spec(delta,outputFile)

if exist('OCTAVE_VERSION')
    fprintf('No spectrograms in Octave\n');
    return
end

clf
nfft=2^11;
increment=200;

for i=50:5:150
fprintf('making spectrogram of point %d\n',i);
[S F T P] = spectrogram(delta(:,i),nfft,nfft-increment,nfft,1);
surf(T,F,10*log10(P),'edgecolor','none');
axis tight;
ylim([0.15 0.25])
view(0,90);
%	set(gca,'YLim',[0.15 0.45])
pause(0.5)
if nargin>1
    print(gcf,'-dpng',strcat(outputFile,'_spectrogram_',int2str(i),'.png'));
end
end
end
