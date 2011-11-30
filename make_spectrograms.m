function [] = make_spectrograms(date,filename)
ecloud_root = '/afs/slac.stanford.edu/g/arda/ecloud';

license('checkout','signal_toolbox')
dat = load(strcat(ecloud_root,'/DataProcessed/',date,'/',filename,'.mat'))

if length(size(dat.delta))==2
delta = cast(dat.delta,'double');
sigma = cast(dat.sigma,'double');
else
delta = cast(dat.delta(:,:,1),'double');
sigma = cast(dat.sigma(:,:,1),'double');
end
outputFile = strcat(ecloud_root,'/DataProcessed/',date,'/spectrograms/',filename);
plot(mean(sigma,2))
	print(gcf,'-dpng',strcat(outputFile,'_sigma.png'));
plot(mean(delta,2))
	print(gcf,'-dpng',strcat(outputFile,'_delta.png'));

show_spec(delta,outputFile);

exit
end
