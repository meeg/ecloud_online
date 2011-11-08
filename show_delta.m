function show_delta(delta,dt)
[Nturns Npoints] = size(delta);
max_n = floor(Nturns/dt);


for n = 1:max_n
clf;
hold on;
for i=0:10
plot(1:Npoints,delta(n*dt-i,:),'g')
end
%ylim([-0.1,0.1]);
sleep(0.5)
end
end
