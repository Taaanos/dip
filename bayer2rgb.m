function [xc]=bayer2rgb(xb,M,N,method)
%OUTPUT
%xc: Colored Image with interpolation method (MxNx3 matrix)
%INPUTS
%xb: grayscale image (2D matrix)
%M,N: desired resize dimensions (intiger)
%method: Method of interpolation 'linear' 'nearest' 'cubic' (string)
%bayer2rbg takes a black and white RAW image and outputs a colored one resized
%at MxN dimensions
%Notes about resize: It will transform the picture to M/N ratio

%DEBUG: Debug flag 1 = yes, 0 = no. Flag prints additional info
DEBUG = 0;
%Show images gray, demosaiced, interpolated. 1 = yes, 0 = no
IMDISP = 0;

if(IMDISP)
    figure(1)
    imshow(xb) %show grayscale image
end

xc = zeros(M,N,3); %preallocate for final MxN image(colored,resized)

%debayer for original dimensions

M0=size(xb,1);
N0=size(xb,2);

xcbayer = zeros(M0,N0,3); %preallocate for xb dimensions ROWSxCOLUMNSx3
% array that will host the RGB channels

%todo: Color Mask for each color on bayer. Make it the same dimensions as
%the image with repmat. Multiply the Gray with the masks. Alternative to
%seperate the color channels

% Bayer filter
%    G B G
%    R G R
%    G B G

%Red Channel
%even rows odd columns
xcbayer(2:2:end,1:2:end,1) = xb(2:2:end,1:2:end);

%Green Channel
%odd rows odd columns
%even rows even columns
xcbayer(1:2:end,1:2:end,2) = xb(1:2:end,1:2:end);
xcbayer(2:2:end,2:2:end,2) = xb(2:2:end,2:2:end);

%Blue Channel
%odd rows even columns
xcbayer(1:2:end,2:2:end,3) = xb(1:2:end,2:2:end);
if(IMDISP)
    figure(8);
    imshow(xcbayer);
    figure(9)
    imshow(xcbayer(300:500,500:700,:))
end
if(DEBUG)
    fprintf('Red')
    xcbayer(1:1:5,1:1:5,1)
    fprintf('Green')
    xcbayer(1:1:5,1:1:5,2)
    fprintf('Blue')
    xcbayer(1:1:5,1:1:5,3)
end
%Output grid resized for given MxN dimensions
%q stands for query
%meshgrid creates a "map"
[xq,yq] = meshgrid(linspace(1,M0,M),linspace(1,N0,N));

%vectorize each channel for griddata

%preallocate

%green = (M0xN0)/2
greenRow = zeros (1,(M0*N0)/2);
greenCol = zeros (1,(M0*N0)/2);
greenVal = zeros (1,(M0*N0)/2);
%blue = (M0xN0)/4
blueRow = zeros (1,(M0*N0)/4);
blueCol = zeros (1,(M0*N0)/4);
blueVal = zeros (1,(M0*N0)/4);
%red = (M0xN0)/4
redRow = zeros (1,(M0*N0)/4);
redCol = zeros (1,(M0*N0)/4);
redVal = zeros (1,(M0*N0)/4);

%Vectorize with find()
[greenRow,greenCol,greenVal] = find(xcbayer(:,:,2));
[blueRow,blueCol,blueVal]    = find(xcbayer(:,:,3));
[redRow,redCol,redVal]       = find(xcbayer(:,:,1));

if(DEBUG)
    greenRow(1:5)
    greenCol(1:5)
    greenVal(1:5)
end

%todo: Data is vectorized. Find neighbors with diff() and manually
%interpolate.

%Griddata
%red

temp = griddata(redRow,redCol,redVal,xq,yq,method);
xc(:,:,1) = temp';
%green
temp = griddata(greenRow,greenCol,greenVal,xq,yq,method);
xc(:,:,2) = temp';
%blue
temp = griddata(blueRow,blueCol,blueVal,xq,yq,method);
xc(:,:,3) = temp';

if (IMDISP)
    figure(3)
    imshow(xc)
end
end
