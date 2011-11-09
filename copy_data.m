source = '/media/ADATA/';
temp = '/home/meeg/matlab_online/temp/';
local = '/home/meeg/matlab_online/data/';
while true
for file=ls(source)'
%Make the filename into a column vector like Matlab expects
file = file';
[~, name, ext] = fileparts(file);
if strncmpi(ext,'.wfm',4)
if !exist(strcat(local,file),'file') && !exist(strcat(temp,file),'file')
fprintf('Copying %s\n',strcat(source,file));
copyfile(strcat(source,file),temp)
end
end
end
end
