% AME-341b Special Experiment OPTICAL METHODS (OM).
% By: Arpad Kovesdy
% Spring 2020, 4/7/2020

clear; close all; clc;
setup_mode = 1;
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  specify the working directory where the a/b image pair is stored
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
working_dir = 'img\';  % keep the "\" at the end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get the filenames of the a/b image pair in working_dir.  This will create
% a structure where file names are images(1).name for img_a and,  
% images(2).name for img_b.
images = dir([working_dir,'img*.jpg']);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Load img_a and img_b and Pre-Process image pair:
%  flatten to 1D (grayscale) if the images are multidimensional (e.g., RGB)
%  This block uses the function 'flatten_rgb_image' which we provided; make
%  sure this function is in your Matlab path.
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
%Could be either A or B, but they should be the same size (assume)

%Define initial variables
[nx, ny] = size(images(1).data);
if (working_dir == "smallActual\")
    search_size = 4;
    S_x = floor(nx/search_size);
    S_y = floor(ny/search_size);
    A_x = floor(nx/search_size/4);
    A_y = floor(ny/search_size/4);
    B_x = A_x;
    B_y = A_y;
    x = []; %Define arrays for plotting final vectors
    y = [];
    u = [];
    v = [];
    shift_x = floor(S_x/8);
    shift_y = floor(S_y/8);
    step = 1;
elseif (working_dir == "largeActual\")
    search_size = 4;
    S_x = floor(nx/search_size);
    S_y = floor(ny/search_size);
    A_x = floor(nx/search_size/2);
    A_y = floor(ny/search_size/2);
    B_x = A_x;
    B_y = A_y;
    x = []; %Define arrays for plotting final vectors
    y = [];
    u = [];
    v = [];
    shift_x = floor(S_x/4);
    shift_y = floor(S_y/4);
    step = 4;
else %For generic other images
    search_size = 4;
    S_x = floor(nx/search_size);
    S_y = floor(ny/search_size);
    A_x = floor(nx/search_size/2);
    A_y = floor(ny/search_size/2);
    B_x = A_x;
    B_y = A_y;
    x = []; %Define arrays for plotting final vectors
    y = [];
    u = [];
    v = [];
    shift_x = floor(S_x/4);
    shift_y = floor(S_y/4);
    step = 1;
end
divx = floor((S_x-B_x)/2);
divy = floor((S_y-B_y)/2);


for p = divx:shift_x:nx-S_x
    %Progress indicator
    fprintf('%.0f%%...\n',100*p/nx)
    
    for q = divy:shift_y:ny-S_y

        % pixel array A = Image 1
        A = double(images(1).data(p:p+A_x, q:q+A_y));  % specify array indices and convert to a double
        % NOTE: imshow does not like doubles, so imshow(uint8(A)) will display A nicely
        
        % Find the displacement of A by correlating this pixel array with all 
        % possible destinations B(K,L) in search box S of img_b.
        for i = -divx:step:divx % x pixel shift within S
            for j = -divy:step:divy % y pixel shift within S
                
                % pixel array B      HINT: size(A) = size(B) < size(S)
                B = double(images(2).data(p+i+1:p+i+B_x+1, q+j+1:q+j+B_y+1)); % specify array indices within S and convert to a double
                
                A_avg = sum(sum(A))/B_x/B_y;
                B_avg = sum(sum(B))/B_x/B_y;
                
                % Calculate the correlation coefficient, C, for this pixel array.
                % Evaluate C at all possible locations (index shifts I,J).
                % The best correlation determines the displacement of A into img_b.
				%  Note: Double sum below effectively implements Double Riemann sum across k and l in lecture
                C(i+1+divx, j+1+divy) = sum(sum( (A - A_avg).*(B - B_avg) ))/...
                          sqrt(sum(sum( (A - A_avg).^2 ))*sum(sum( (B - B_avg).^2 )));
            end % j
        end % i
        %Set x and y locations as the center of A
        x_ind = ((p-divx)/shift_x) + 1;
        y_ind = ((q-divy)/shift_y) + 1;
        x(x_ind,y_ind) = p + (A_x/2);
        y(x_ind,y_ind) = q + (A_y/2);
        %These x and y will be used for plotting purposes of these
        %correlation coefficient locations
        %Find high value in C and its location in the array
        [u_temp, a_u] = max(C);
        [v_temp, a_v] = max(u_temp);
        %The actual location of max correlation is offset by (divy, divx)
        %since the grid assumes that the center is 100% correlation
        %however that index is in the middle of the array
        u(x_ind,y_ind) = a_u(a_v) - divx;
        v(x_ind,y_ind) = a_v - divy;
    end % q
end % p

fprintf('Processing complete!\n')


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Plot vectors on shifted image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;
imshow(images(2).data); % show image (B, shifted final image) as background
hold on;         % hold figure
quiver(y,x,v,u, 'r');   % plot displacement vectors

%Enter conversion from pixel to mm (from calibration grid)
pixels_per_mm = 25.1;

%Calculate fault line location
threshold = 0.01; %Movement threshold (pixels/pixel)
fault_x = abs(mean(u))./nx; %Sum columns and scale by size of image
fault_y = abs(mean(v,2))./ny; %Sum rows and scale by size of image
x_fault_detect = false;
y_fault_detect = false;
for i = 2:length(fault_x)
    if (fault_x(i)-fault_x(i-1) > threshold)
        x_fault_detect = true;
        del_fault = shift_x/2; %Uncertainty in fault line location, pixels
        fault_loc = del_fault*i; %Fault line location, pixels
        break;
    end
end
%Declare if there is an up-down fault
if (~x_fault_detect)
    fprintf('No fault line detected in y direction\n');
else
    fprintf('Fault detected in y direction\n');
    %Draw in fault line
    fault_line = x(i) - (shift_y/2);
    plot([fault_line, fault_line],[0,nx],'c--');
    fprintf('Fault line located at: %.2f mm\n', fault_line/pixels_per_mm);
end
for j = 2:length(fault_y)
    if (fault_y(j)-fault_y(j-1) > threshold)
        y_fault_detect = true;
        del_fault = shift_y/2; %Uncertainty in fault line location, pixels
        fault_loc = del_fault*j; %Fault line location, pixels
        break;
    end
end
%Declare if there is an side-to-side fault
if (~y_fault_detect)
    fprintf('No fault line detected in x direction\n');
else
    fprintf('Fault detected in x direction\n');
    %Draw in fault line
    %fault_line = fault_loc-S_y+(A_y/2)+(del_fault/2); %y location of fault line
    fault_line = x(j) - (shift_x/2);
    plot([0,nx],[fault_line, fault_line],'c--');
    fprintf('Fault line located at: %.2f mm\n', fault_line/pixels_per_mm);
end

%Calculate displacement due to shift
if (x_fault_detect)
    del_y = mean(fault_x(i:end))*nx/pixels_per_mm; 
    fprintf('Image shifted: %.1f mm\n', del_y);
elseif (y_fault_detect)
    del_x = mean(fault_y(j:end))*ny/pixels_per_mm;
    del_del_x = 1/pixels_per_mm; %1 pixel is the uncertainty
    fprintf('Image shifted: %.2f +/- %.2f mm\n', del_x, del_del_x);
end

fprintf('Fault Line uncertainty: %.2f mm\n', del_fault/pixels_per_mm);
fprintf('Displacement uncertainty: %.2f mm\n', 1/pixels_per_mm);