% Read Fraunhofer X-Ray rekonstruction files
%
% This function loads a Fraunhofer Reconstruction (*.rek)
% from a file to a matrix.
%
% Usage:        vol_raw = ReadRek(filename, dim1, dim2, dim3)
%
% Arguments:
%               filename is the path to the volume that 
%               should be loaded_graphics_toolkits.
%
%               dim1, dim2, dim3 are the x,y,z dimensions
%               of the volume.
%
% Returns:      vol_raw will be a triple indexed matrix


function vol_raw = ReadRek(filename, dim1, dim2, dim3)

fin=fopen(filename,'r'); %Open file
header=fread(fin,1024,'uint16=>uint16'); % Read header
I=fread(fin, dim1*dim2*dim3,'uint16=>uint16'); % Read image data
fclose(fin); % Close file

% Reshape into a matrix 
vol_raw = reshape(I, dim1, dim2, dim3);

 end