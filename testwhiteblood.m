%% Original codes by Sarah Wait Zaranek
%% https://www.mathworks.com/matlabcentral/answers/3283-extracting-white-blood-cell-from-cell-samples#answer_4939

%%Reading in the image
myImage = imread('./bloodsmears/test2.jpg');
figure
imshow(myImage)
%%Extracting the blue plane 
bPlane = myImage(:,:,3)  - 0.5*(myImage(:,:,1)) - 0.5*(myImage(:,:,2));
figure
imshow(bPlane)
%%Extract out purple cells
%figure
BW = bPlane > 29;
%imshow(BW)
%%Remove noise 100 pixels or less
BW2 = bwareaopen(BW, 100);
%imshow(BW2)
%%Calculate area of regions
cellStats = regionprops(BW2, 'all');
cellAreas = [cellStats(:).Area];

%% create new figure to output superimposed images
% first display the original image
figure, imshow(myImage), hold on

%% Label connected components
[L Ne]=bwlabel(BW2);
propied=regionprops(L,'BoundingBox'); 
himage = imshow(BW2);

%% Get the total number of cells that have been added with bounding box
whitecount = size(propied,1);

%% Added bounding box to the white blood cells
hold on
for n=1:whitecount
  rectangle('Position',propied(n).BoundingBox,'EdgeColor','g','LineWidth',2)
end
hold off

%% Superimpose the two image
set(himage, 'AlphaData', 0.5);

%% Output total white blood cells onto the figure
title(sprintf('%i White Blood Cells Detected',whitecount),'fontsize',14);