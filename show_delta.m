function show_delta(delta,dt,outputFile)
[Nturns Npoints] = size(delta);
max_n = floor(Nturns/dt);


for n = 1:max_n
clf;
fprintf('making time-domain plot at turn %d\n',(n-1)*dt);
hold on;
for i=0:10
plot(1:Npoints,delta(n*dt-i,:),'b')
end
%ylim([-0.1,0.1]);
if nargin>2
    print(gcf,'-dpng',strcat(outputFile,'_delta_',int2str((n-1)*dt),'.png'));
end
pause(0.5)
end
end
