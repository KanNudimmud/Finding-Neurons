%% Segmentation for Brain Cells (Neurons)
% Data downloaded from:
% http://atlas.brain-map.org/atlas?atlas=1&plate=100960324#atlas=1&plate=100960324
%% Load the image
% Read the image and diplay it
mouse = imread('mouse_coronal.jpg');
figure(1)
imshow(mouse)
title('Coronal Slice of the Mouse Brain')

% Cut out subsection
subsec = squeeze(mean( mouse(1073:2335,2180:3803,:) ,3));

% Visualize the subsection
figure(2)
imagesc(subsec), axis image
colormap gray

%% Segmentation
% Create a histogram to find an appropriate threshold manually
figure(3)
hist(subsec(:),500)

% Create a binarized thresholded map
thresh = 210;
threshmap = subsec < thresh;

% Extract the info about the 'islands' in that map
units = bwconncomp(threshmap);

% Display the subsection with islands
figure(4)
imagesc(subsec), hold on
contour(threshmap,1,'r')
axis image, colormap gray
zoom on

% Determine size of islands and make a histogram
unitsizes = cellfun(@length,units.PixelIdxList);
figure(5)
hist(unitsizes,900)
set(gca,'xlim',[0 250])
xlabel('Unit size (pixels)'), ylabel('Count')

% Choose a pixel threshold
pixthresh = 10;

% Reconstruct the threshmap
threshmapFilt = false(size(threshmap));
for ui=1:units.NumObjects
    
    % skip this unit if too small
    if unitsizes(ui) < pixthresh
        continue;
    end    
    
    threshmapFilt(units.PixelIdxList{ui}) = 1;
end

% Redraw on previous map
figure(4),hold on
contour(threshmapFilt,1,'b','linew',2)

%% Show clusters respect to their size
% Create a color map 
sizecolormap = nan(size(subsec));
for ui=1:units.NumObjects
    sizecolormap(units.PixelIdxList{ui}) = log(unitsizes(ui));
end

% Create an alpha map (transparency)
alphmap = ones(size(subsec));
alphmap(~isfinite(sizecolormap)) = 0;

% Display neuron clusters according to their size
figure(6), clf
imagesc(sizecolormap,'Alphadata',alphmap)
set(gca,'clim',[0 7])
%% end