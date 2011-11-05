function x = readcurvespec(fid)
  x.state_flags=fread(fid,1,'int');
  x.type_of_check_sum=fread(fid,1,'int');
  x.check_sum=fread(fid,1,'short');
  x.precharge_start_offset=fread(fid,1,'ulong');
  x.data_start_offset=fread(fid,1,'ulong');
  x.postcharge_start_offset=fread(fid,1,'ulong');
  x.postcharge_stop_offset=fread(fid,1,'ulong');
  x.end_of_curve_buffer_offset=fread(fid,1,'ulong');
end

