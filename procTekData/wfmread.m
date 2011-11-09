% TODO: missing endian verification
% TODO: missing data type verification 8bit integer only
% TODO: not tested with version 1 and 2
% TODO: respect coffset

% Use: x=wfmread(filename)
% raw data are in x.v. Additional info are in x.staticheader, x.waveheader, 
% x.curve, x.frame


function x = wfmread(fn)
  fid=fopen(fn,'r');
  x.staticheader=readstaticheader(fid);
  switch (x.staticheader.versioning_number)
  case ':WFM#001'
    x.waveheader=readwaveheader1(fid);
  case ':WFM#002'
    x.waveheader=readwaveheader2(fid);
  case ':WFM#003'
    x.waveheader=readwaveheader3(fid);
  end
  x.frames=x.staticheader.n_number_of_fastframes_minus_one+1;
  [x.frame, x.curve]= mkframes(fid,x.frames);
  x.points=x.curve(1).end_of_curve_buffer_offset;
fprintf('Done reading headers\n');
  x.v=fread(fid,[x.points,x.frames],'schar')';
fprintf('Done reading data\n');
  fclose(fid);
end

