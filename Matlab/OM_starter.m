% AME-341b Special Experiment OPTICAL METHODS (OM). Specify the 'image_set'
% case and run.  Throughout this script there are several variables that
% need to be formulated into proper inputs; these are marked as "###".

clear; close all; clc;
setup_mode = 1;
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  specify the working directory where the a/b image pair is stored
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
working_dir = [pwd, '\img\']; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get the filenames of the a/b image pair in working_dir.  This will create
% a structure where file names are images(1).name for img_a and,  
% images(2).name for img_b.
images = dir([working_dir,'img*.jpg']);


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Load img_a and img_b and Pre-Process image pair:
%  flatten to 1D (grayscale) if the images are multidimensional (e.g., RGB)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:length(images)
    % load image data into a temporary variable
    temp = imread([working_dir,images(i).name]);
    % show original image
    %if setup_mode == 1
    %    figure(1);  subplot(2,2,i);
    %    imshow(temp);  title(images(i).name,'Interpreter','none'); hold on;
    %end

	% Assign flattened (grayscale) image data to the structure "IMAGES"; 
    % this data will be used for interrogation.
    images(i).data = flatten_rgb_image(temp,1);
end
% End of image Pre-Processing setup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n = 1; %Enter the number of servers here
[y,x,v,u] = runDICParallel(images(1).data, images(2).data, n);
fprintf('Processing complete!\n')


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Plot vectors on shifted image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;
imshow(imread([working_dir,images(2).name])); % show image 
hold on; % hold figure
quiver(y,x,v,u, 'r');   % plot displacement vectors
