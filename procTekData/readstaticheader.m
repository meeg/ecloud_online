function x = readstaticheader(fid)
  x.byte_order_verification=fread(fid,1,'uint16');
  x.versioning_number=char(fread(fid,8,'char')');
  x.num_digits_in_byte_count=fread(fid,1,'uchar');
  x.number_of_bytes_to_the_end_of_file=fread(fid,1,'int32');
  x.number_of_bytes_per_point=fread(fid,1,'uchar');
  x.byte_offset_to_beginning_of_curve_buffer=fread(fid,1,'int32');
  x.horizontal_zoom_scale_factor=fread(fid,1,'int32');
  x.horizontal_zoom_position=fread(fid,1,'float32');
  x.vertical_zoom_scale_factor=fread(fid,1,'float32');
  x.vertical_zoom_position=fread(fid,1,'float64');
  x.waveform_label=char(fread(fid,32,'char')');
  x.n_number_of_fastframes_minus_one=fread(fid,1,'uint32');
  x.size_of_the_waveform_header=fread(fid,1,'uint16');
end


