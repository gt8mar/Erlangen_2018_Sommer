% Luis Torres
% luis.torres@fau.de
% 
% This code is wrote to grab the coodinates in pixels given as
% by a *.rek file (the reconstructed object)
% 
% Updated at 19.05.2018

clear all;
close all;
clc;

dimX = 960;
dimY = 960;
%dimZ = 406;
dimZ = 381;

p1 = 0.0368;
p2 = -33.47;
p3 = 3.532.*10.^4;

x = [0:960];
f = p1.*x.^2 + p2.*x + p3;

% IMPORT one *.rek file
vol_raw = ReadRek('prapanch_pouring_1mm_glassBeads_180518_test5.rek', dimX, dimY, dimZ);
fig1 = figure(1);
imshow(vol_raw(:,:,77))

ii_0 = floor(dimX./2) ;
jj_0 = floor(dimY./2) + floor(0.02*dimX);

%R = floor(882./2);
R = floor(782./2);

% At this point we should look for the right "threshold value".
% Achtung! the threshold gray value cannot be obtained from a 3D object, that's why
% firstable we should reshape or 3D object vol_raw with reshape(*.rek,dimX*dimZ,dimY)

vol_2D = reshape(vol_raw, dimX*dimZ, dimY);

%Normally it is used the Otsu method 
%threshold = graythresh(vol_2D)

threshold = 0.44;
%threshold is a function of radius

vol_bw = im2bw(vol_2D,threshold);

%now we shall come back to our 3D object
%vol_3D = reshape(vol_2D, 960, 960, 406);
vol_3D = reshape(vol_bw, dimX, dimY, dimZ);

for ii = 1: dimX
      for jj = 1: dimY
          
          r = sqrt( (ii - ii_0).^2 + (jj - jj_0).^2  );
   
          if (r > R) 
              vol_3D(ii,jj,:) = 0.0;
          end
         
      end
end

vol_3D_EDM = bwdist(vol_3D,'euclidean');

vol_3D_EDM = vol_3D;

%is quite useful to see at each step one of our figures with imshow
fig2 = figure(2);
imshow(vol_3D_EDM(:,:,77))

%now the erosion proces
%firstable we should create a cube the number is the size of the cube in pixels
SE = strel('cube',4);

%this cube is gona erode our image
vol_erode = imerode(vol_3D_EDM, SE);

%now we should label our particles
vol_label = bwlabeln(vol_erode(:,:,:)); 

%see your particles one more time
fig3 = figure(3);
imshow(label2rgb(vol_label(:,:,77),@lines))

%now the centoids
s = regionprops(vol_label(:,:,:),'centroid')

%the last step is plotting your particles 
%bubbleplot3(x, y, z, r, color)

%with this lines we print the coordinates
%dlmwrite(['tracersTEST.data'],tracers)



