function deltaFiltered = view_data(filename)
[delta time meta] = rawData2Tensor(filename);
[Nturns Npoints] = size(delta);
delta_minusmean = delta-ones(Nturns,1)*mean(delta,1);

deltaFiltered = tuneFilter(delta,0.17,0.20);

show_delta(deltaFiltered,2000);
end
