function [frame, curve] = mkframes(fid,frames)
tmpframe=readupdatespec(fid);
tmpcurve=readcurvespec(fid);
frame=tmpframe; curve=tmpcurve;
names=fieldnames(tmpframe);
for j=2:frames
	frame(j)=readupdatespec(fid);
end
for j=2:frames
	curve(j)=readcurvespec(fid);
end
end
