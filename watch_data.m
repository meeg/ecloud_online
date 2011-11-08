temp = '/home/meeg/matlab_online/temp/';
local = '/home/meeg/matlab_online/data/';
while true
for file=ls(temp)'
%Make the filename into a column vector like Matlab expects
file = file';
[~, name, ext] = fileparts(file);
printf('%s\n',ext)
if strncmpi(ext,'.wfm',4)
if strcmp(name(end-2:end),'Ch2')
view_data(strcat(temp,file));
end
movefile(strcat(temp,file),local)
end
end
end
