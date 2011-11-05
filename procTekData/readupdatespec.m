function x = readupdatespec(fid)
  x.real_point_offset=fread(fid,1,'uint32');
  x.tt_offset=fread(fid,1,'float64');
  x.frac_sec=fread(fid,1,'float64');
  x.gmt_sec=fread(fid,1,'int32');
end


