temp = '/home/meeg/matlab_online/temp/';
local = '/home/meeg/matlab_online/data/';
plots = '/home/meeg/matlab_online/plots/';
while true
    listing = dir(temp);
    files = listing.name;
%    files
    for item=listing'
        file=item.name;
%        disp(file)
    %Make the filename into a column vector like Matlab expects
%fprintf('%s\n',file)
[~, name, ext] = fileparts(file);
%fprintf('%s\n',ext)
if strncmpi(ext,'.wfm',4)
if strcmp(name(end-2:end),'Ch2')
view_data(strcat(temp,file),plots);
end
movefile(strcat(temp,file),local);
end
end
pause(1)
end
