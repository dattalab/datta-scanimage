function loadImage4Mapper(directory)
global state

% try to go to default/current directory
% try
%     cd(directory);
% catch
%     try
%         cd('C:\DATA');
%     catch
%     end
% end
directory = getDefaultCacheDirectory(progmanager, 'loadImage4MapperDirectory');
fname = getDefaultCacheValue(progmanager, 'loadImage4MapperFilename');
if isempty(fname)
    fname = 'image.tif';
end
% cd(directory);

% interactively select the file to open
[name, path] = uigetfile('*.*', 'Select an image file.', fullfile(directory, fname));
if isnumeric(name)
    return
end
fullname = fullfile(path, name);
% imgDir = path;

% load it

% % read in the image file & convert to RGB format
I = imread(fullname);
% R = ind2rgb(I, gray(256));
R = I;

hSliceImg = imagesc(R);
colormap gray;
set(gca, 'Visible', 'off');
daspect([1 1 1]);

% put its handle in the state directory so ephus mapper can find it
state.video.imageHandle = hSliceImg;
% get(state.video.imageHandle);

setDefaultCacheValue(progmanager, 'loadImage4MapperDirectory', path);
setDefaultCacheValue(progmanager, 'loadImage4MapperFilename', name);

return;