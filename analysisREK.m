% Luis Torres and Marcus Forst
% luis.torres@fau.de
% marcus.forst@temple.edu 
%
% This code is wrote to grab the coodinates in pixels given as
% by a *.rek file (the reconstructed object)
% 
% Updated 11.06.2018 by Marcus Forst

clear all;
close all;
clc;

dimX = 960;
dimY = 960;        
dimZ = 347;                                                                 % Here give the number of cuts as your z dimension

% IMPORT one *.rek file
vol_raw = ReadRek('prapanch_pouring_1mm_glassBeads_230518_test8.rek', dimX, dimY, dimZ);
fig1 = figure(1);
imshow(vol_raw(:,:,77))

ii_0 = floor(dimX./2) ;
jj_0 = floor(dimY./2) ;                                  

R = floor(782./2);                                                          

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Binarization (make it black and white)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% At this point we should look for the right "threshold value".
% Achtung! The threshold gray value cannot be obtained from a 3D object, 
% that's why first we should reshape our 3D object vol_raw with 
% reshape(*.rek,dimX*dimZ,dimY)

vol_2D = reshape(vol_raw, dimX*dimZ, dimY);
clear vol_raw;

% We choose this threshold based on what gives us the most clear image
threshold = 0.44;
vol_bw = imbinarize(vol_2D,threshold);
clear vol_2D;

% Now we shall come back to our 3D object
vol_3D = reshape(vol_bw, dimX, dimY, dimZ);
clear vol_bw;

for ii = 1: dimX
      for jj = 1: dimY
          
          r = sqrt( (ii - ii_0).^2 + (jj - jj_0).^2  );
   
          if (r > R) 
              vol_3D(ii,jj,:) = 0;
          end
         
      end
end

clear R

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Euclidean Distance Map (Figure out the radius of the particles by seeing
% how far their center is from the outside)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Switch Polarization and make EDM
vol_3D = imcomplement(vol_3D);
vol_3D_EDM = bwdist(vol_3D,'euclidean');

% Contour map showing EDM gradient
fig5 = figure(5);
imcontour(vol_3D_EDM(:,:,77))
%dlmwrite('EDM.csv',vol_3D_EDM)

% Here we return to the original vol_3D data in order to begin eroding
vol_3D_EDM = imcomplement(vol_3D);

% Initial Binary (Black and white) image
fig2 = figure(2);
imshow(vol_3D_EDM(:,:,77))


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EROSION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% We erode using a sphere. # is the size of the radius in pixels         
SE = strel('sphere',3);                                                    
vol_erode = imerode(vol_3D_EDM, SE);                                        
clear vol_3D_EDM;                                                           
clear vol_3D;                                                                            

% Label our particles
vol_label = bwlabeln(vol_erode(:,:,:)); 
clear vol_erode;

% Particles after erosion, each has a different color
fig3 = figure(3);
imshow(label2rgb(vol_label(:,:,77),@lines))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Centroids
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Creates an array of centroid coordinates
s = regionprops(vol_label(:,:,:),'centroid')
centroids = cat(1, s.Centroid);
clear vol_label
clear s

% Write a file with the centroid coordinates
dlmwrite('Test8Cent.csv', centroids)

% Plot the centroids on a 3D plot
fig4 = figure(4);
scatter3(centroids(:,1), centroids(:,2), centroids(:,3), 1)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Optional, expensive bubbleplot of one layer; I do not recommend using a
% lot of iterations here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% fig5= figure(5);
% hold on
% for aa = 1:3000
%    bubbleplot3(centroids(aa,1), centroids(aa,2), centroids(aa,3), 5)
% end


