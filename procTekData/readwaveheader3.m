function x = readwaveheader3(fid)
  x.settype=fread(fid,1,'int');
  x.wfmcnt=fread(fid,1,'ulong');
  x.acquisition_counter=fread(fid,1,'uint64');
  x.transaction_counter=fread(fid,1,'uint64');
  x.slot_id=fread(fid,1,'int');
  x.is_static_flag=fread(fid,1,'int');
  x.wfm_update_specification_count=fread(fid,1,'ulong');
  x.imp_dim_ref_count=fread(fid,1,'ulong');
  x.exp_dim_ref_count=fread(fid,1,'ulong');
  x.data_type=fread(fid,1,'int');
  x.gen_purpose_counter=fread(fid,1,'uint64');
  x.accumulated_waveform_count=fread(fid,1,'ulong');
  x.target_accumulation_count=fread(fid,1,'ulong');
  x.curve_ref_count=fread(fid,1,'ulong');
  x.number_of_requested_fast_frames=fread(fid,1,'ulong');
  x.number_of_acquired_fast_frames=fread(fid,1,'ulong');
  x.summary_frame_type=fread(fid,1,'ushort');
  x.pix_map_display_format=fread(fid,1,'int');
  x.pix_map_max_value=fread(fid,1,'uint64');
  x.exp_dim_1_dim_scale=fread(fid,1,'float64');
  x.exp_dim_1_dim_offset=fread(fid,1,'float64');
  x.exp_dim_1_dim_size=fread(fid,1,'ulong');
  x.exp_dim_1_units=char(fread(fid,20,'char')');
  x.exp_dim_1_dim_extent_min=fread(fid,1,'float64');
  x.exp_dim_1_dim_extent_max=fread(fid,1,'float64');
  x.exp_dim_1_dim_resolution=fread(fid,1,'float64');
  x.exp_dim_1_dim_ref_point=fread(fid,1,'float64');
  x.exp_dim_1_format=fread(fid,1,'int');
  x.exp_dim_1_storage_type=fread(fid,1,'int');
  x.exp_dim_1_n_value=char(fread(fid,4,'char')');
  x.exp_dim_1_over_range=char(fread(fid,4,'char')');
  x.exp_dim_1_under_range=char(fread(fid,4,'char')');
  x.exp_dim_1_high_range=char(fread(fid,4,'char')');
  x.exp_dim_1_low_range=char(fread(fid,4,'char')');
  x.exp_dim_1_user_scale=fread(fid,1,'float64');
  x.exp_dim_1_user_units=char(fread(fid,20,'char')');
  x.exp_dim_1_user_offset=fread(fid,1,'float64');
  x.exp_dim_1_point_density=fread(fid,1,'float64');
  x.exp_dim_1_href=fread(fid,1,'float64');
  x.exp_dim_1_trigdelay=fread(fid,1,'float64');
  x.exp_dim_2_dim_scale=fread(fid,1,'float64');
  x.exp_dim_2_dim_offset=fread(fid,1,'float64');
  x.exp_dim_2_dim_size=fread(fid,1,'ulong');
  x.exp_dim_2_units=char(fread(fid,20,'char')');
  x.exp_dim_2_dim_extent_min=fread(fid,1,'float64');
  x.exp_dim_2_dim_extent_max=fread(fid,1,'float64');
  x.exp_dim_2_dim_resolution=fread(fid,1,'float64');
  x.exp_dim_2_dim_ref_point=fread(fid,1,'float64');
  x.exp_dim_2_format=fread(fid,1,'int');
  x.exp_dim_2_storage_type=fread(fid,1,'int');
  x.exp_dim_2_n_value=char(fread(fid,4,'char')');
  x.exp_dim_2_over_range=char(fread(fid,4,'char')');
  x.exp_dim_2_under_range=char(fread(fid,4,'char')');
  x.exp_dim_2_high_range=char(fread(fid,4,'char')');
  x.exp_dim_2_low_range=char(fread(fid,4,'char')');
  x.exp_dim_2_user_scale=fread(fid,1,'float64');
  x.exp_dim_2_user_units=char(fread(fid,20,'char')');
  x.exp_dim_2_user_offset=fread(fid,1,'float64');
  x.exp_dim_2_point_density=fread(fid,1,'float64');
  x.exp_dim_2_href=fread(fid,1,'float64');
  x.exp_dim_2_trigdelay=fread(fid,1,'float64');
  x.imp_dim_1_dim_scale=fread(fid,1,'float64');
  x.imp_dim_1_dim_offset=fread(fid,1,'float64');
  x.imp_dim_1_dim_size=fread(fid,1,'ulong');
  x.imp_dim_1_units=char(fread(fid,20,'char')');
  x.imp_dim_1_dim_extent_min=fread(fid,1,'float64');
  x.imp_dim_1_dim_extent_max=fread(fid,1,'float64');
  x.imp_dim_1_dim_resolution=fread(fid,1,'float64');
  x.imp_dim_1_dim_ref_point=fread(fid,1,'float64');
  x.imp_dim_1_spacing=fread(fid,1,'ulong');
  x.imp_dim_1_user_scale=fread(fid,1,'float64');
  x.imp_dim_1_user_units=char(fread(fid,20,'char')');
  x.imp_dim_1_user_offset=fread(fid,1,'float64');
  x.imp_dim_1_point_density=fread(fid,1,'float64');
  x.imp_dim_1_href=fread(fid,1,'float64');
  x.imp_dim_1_trigdelay=fread(fid,1,'float64');
  x.imp_dim_2_dim_scale=fread(fid,1,'float64');
  x.imp_dim_2_dim_offset=fread(fid,1,'float64');
  x.imp_dim_2_dim_size=fread(fid,1,'ulong');
  x.imp_dim_2_units=char(fread(fid,20,'char')');
  x.imp_dim_2_dim_extent_min=fread(fid,1,'float64');
  x.imp_dim_2_dim_extent_max=fread(fid,1,'float64');
  x.imp_dim_2_dim_resolution=fread(fid,1,'float64');
  x.imp_dim_2_dim_ref_point=fread(fid,1,'float64');
  x.imp_dim_2_spacing=fread(fid,1,'ulong');
  x.imp_dim_2_user_scale=fread(fid,1,'float64');
  x.imp_dim_2_user_units=char(fread(fid,20,'char')');
  x.imp_dim_2_user_offset=fread(fid,1,'float64');
  x.imp_dim_2_point_density=fread(fid,1,'float64');
  x.imp_dim_2_href=fread(fid,1,'float64');
  x.imp_dim_2_trigdelay=fread(fid,1,'float64');
  x.time_base_1_real_point_spacing=fread(fid,1,'ulong');
  x.time_base_1_sweep=fread(fid,1,'int');
  x.time_base_1_type_of_base=fread(fid,1,'int');
  x.time_base_2_real_point_spacing=fread(fid,1,'ulong');
  x.time_base_2_sweep=fread(fid,1,'int');
  x.time_base_2_type_of_base=fread(fid,1,'int');
end
