%% WHITE BLOOD CELLS

%% Original codes by Sarah Wait Zaranek
%% https://www.mathworks.com/matlabcentral/answers/3283-extracting-white-blood-cell-from-cell-samples#answer_4939

%%Reading in the image
myImage = imread('./bloodsmears/test6.jpg');
figure
imshow(myImage)
title("Original Image", 'fontsize',14);
%%Extracting the blue plane 
bPlane = myImage(:,:,3)  - 0.5*(myImage(:,:,1)) - 0.5*(myImage(:,:,2));
%figure
%imshow(bPlane)
%title('Extracted White Blood Cells','fontsize',14);
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


%% RED BLOOD CELLS
%% Extracting the red plane 
rPlane = myImage(:,:,1)- 0.4*(myImage(:,:,3)) - 0.6*(myImage(:,:,2));
%figure
%imshow(rPlane)
%title('Extracted Red Blood Cells','fontsize',14);
%% Extract out red cells
BWr = rPlane > 19;
%figure
%imshow(BW)
%%Remove noise 100 pixels or less
BWr2 = bwareaopen(BWr, 100);
%imshow(BW2)
%%Calculate area of regions
cellStatsr = regionprops(BWr2, 'all');
cellAreasr = [cellStatsr(:).Area];

%% create new figure to output superimposed images
% first display the original image
figure, imshow(myImage), hold on

%% Label connected components
[Lr Ner]=bwlabel(BWr2);
propiedr=regionprops(Lr,'BoundingBox'); 
himager = imshow(BWr2);

%% Get the total number of cells that have been added with bounding box
redcount = size(propiedr,1);

%% Added bounding box to the red blood cells
hold on
for n=1:redcount
  rectangle('Position',propiedr(n).BoundingBox,'EdgeColor','r','LineWidth',2)
end
hold off

%% Superimpose the two image
set(himager, 'AlphaData', 0.5);

%% Output total red blood cells onto the figure
title(sprintf('%i Red Blood Cells Detected',redcount),'fontsize',14);

%% Calculate percentages
totalCells = whitecount + redcount;
wbcPercent = (whitecount ./ totalCells) .* 100;
rbcPercent = (redcount ./ totalCells) .* 100;

figure
title('Results','fontsize',14);
text(0,.7,sprintf('Total Blood Cells: %i',totalCells),'FontSize',14)
text(0,.5,sprintf('White Blood Cells: %i %%',vpa(wbcPercent)),'FontSize',14)
text(0,.3,sprintf('Red Blood Cells: %i %%',vpa(rbcPercent)),'FontSize',14)