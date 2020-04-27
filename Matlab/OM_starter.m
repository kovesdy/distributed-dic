% AME-341b Special Experiment OPTICAL METHODS (OM). Specify the 'image_set'
% case and run.  Throughout this script there are several variables that
% need to be formulated into proper inputs; these are marked as "###".

clear; close all; clc;
setup_mode = 1;
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  specify the working directory where the a/b image pair is stored
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
working_dir = [pwd, '\large\']; 
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
    if setup_mode == 1
        figure(1);  subplot(2,2,i);
        imshow(temp);  title(images(i).name,'Interpreter','none'); hold on;
    end

	% Assign flattened (grayscale) image data to the structure "IMAGES"; 
    % this data will be used for interrogation.
    images(i).data = flatten_rgb_image(temp,1);
end
% End of image Pre-Processing setup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Correlation Parameters for the image pair:
%  image box and search box dimensions (in pixels);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  For each image box in img_a, calculate the displacement.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% nx*ny = total number of displacement calculations (grid points).  This is
% a function of the image size and the Correlation Parameters from above.

nx = size(temp, 1);
ny = size(temp, 2);

if (nx > 600) % Speeds up runtime for larger images
    step = 4;
else
    step = 1;
end

Ax = nx / 8;
Ay = ny / 8;
Bx = Ax;
By = Ay;
Sx = 2*Ax;
Sy = 2*Ay;
shiftx = Bx/2;
shifty = By/2;
k = 1; % Loop control variable

for p = (Sx-Bx)/2+1:shiftx:nx-Sx+1
    % progress indicator...
    fprintf('%.0f%%...\n',100*p/(nx-Sx+1))
    
    for q = (Sy-By)/2+1:shifty:ny-Sy+1

        % pixel array A
        A = double(images(1).data(p:p+Ax-1, q:q+Ay-1));  % specify array indices and convert to a double
        % NOTE: imshow does not like doubles, so imshow(uint8(A)) will display A nicely
        A_avg = sum(sum(A)) / (Ax*Ay); % I_a average value

        % Find the displacement of A by correlating this pixel array with all 
        % possible destinations B(K,L) in search box S of img_b.
        for i = -(Sx-Bx)/2:step:(Sx-Bx)/2  % x pixel shift within S
            for j = -(Sy-By)/2:step:(Sy-By)/2 % y pixel shift within S
                
                % pixel array B      HINT: size(A) = size(B) < size(S)
                B = double(images(2).data(i+p:i+p+Bx-1, j+q:j+q+By-1)); % specify array indices within S and convert to a double
                B_avg = sum(sum(B)) / (Bx*By); % I_b average value

                % Calculate the correlation coefficient, C, for this pixel array.
                % Evaluate C at all possible locations (index shifts I,J).
                % The best correlation determines the displacement of A into img_b.
				%  Note: Double sum below effectively implements Double Riemann sum across k and l in lecture
                C(i+(Sx-By)/2+1, j+(Sy-By)/2+1) = sum(sum( (A - A_avg).*(B - B_avg) )) / sqrt(sum(sum( (A - A_avg).^2 ))*sum(sum( (B - B_avg).^2 )));
            end % j
        end % i
        [actualMax, maxIndex] = max(C);
        [maxi, yInd] = max(actualMax); % Second result is the y index of max. value of C
        xInd = maxIndex(yInd); % x index of max value of C
        
        y(k) = q+(Sy-By)/2+1;
        x(k) = p+(Sx-By)/2+1;
        v(k) = yInd - (Sy-By)/2 - 1;
        u(k) = xInd - (Sx-By)/2 - 1;
        k = k+1;
    end % q
end % p

fprintf('Processing complete!\n')


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Plot vectors on shifted image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;
imshow(imread([working_dir,images(2).name])); % show image 
hold on; % hold figure
quiver(y,x,v,u, 'r');   % plot displacement vectors
