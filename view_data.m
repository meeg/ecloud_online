function [delta deltaFiltered] = view_data(filename,plots)
[path, name, ext] = fileparts(filename);

fprintf('running view_data\n')
[delta time meta] = rawData2Tensor(filename);
[Nturns Npoints] = size(delta);
delta_minusmean = delta-ones(Nturns,1)*mean(delta,1);

deltaFiltered = tuneFilter(delta,0.17,0.20);

if nargin>1
show_delta(deltaFiltered,2000,strcat(plots,name));
show_spec(delta,strcat(plots,name));
else
show_delta(deltaFiltered,2000);
show_spec(delta);
end
end

