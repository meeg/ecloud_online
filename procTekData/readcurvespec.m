function x = readcurvespec(fid)
  x.state_flags=fread(fid,1,'int32');
  x.type_of_check_sum=fread(fid,1,'int32');
  x.check_sum=fread(fid,1,'int16');
  x.precharge_start_offset=fread(fid,1,'uint32');
  x.data_start_offset=fread(fid,1,'uint32');
  x.postcharge_start_offset=fread(fid,1,'uint32');
  x.postcharge_stop_offset=fread(fid,1,'uint32');
  x.end_of_curve_buffer_offset=fread(fid,1,'uint32');
end

