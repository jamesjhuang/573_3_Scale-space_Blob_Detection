% Downsampling Blob Detection
% CSE573 HW2
% Written by: James J. Huang

function blobDownsample(imPath, k, n, sigma, threshold)
    %% Loading and preprocessing
    % Load image
    im = imread(imPath);

    % Convert image to grayscale and double
    imG = rgb2gray(im);
    imG = im2double(imG);

    % Image dimensions
    w = size(imG, 2);
    h = size(imG, 1);
    
    % Generating Laplacian of Gaussian filter 
    LoG = sigma^2 * fspecial('log', 2*ceil(3*sigma) + 1, sigma);
    
    % Relative radius at each scale
    radius = zeros(n, 1);

    % Reducing image by a scale of 1/k and applying LoG
    filterResponse = cell(n, 1);
    localMax = zeros(h, w, n);
    scaled_image = cell(n, 1);
    upsampled_Response = zeros(h, w, n);
    for i = 1:n
       if i ~= 1
           scaled_image{i} = imresize(scaled_image{i-1}, 1/k, 'bicubic');
           radius(i) = sqrt(2) * k^i * sigma;
       else
           scaled_image{i} = imG;
           radius(i) = sqrt(2) * sigma;
       end
       filterResponse{i} = (imfilter(scaled_image{i}, LoG, 'replicate')).^2;
    end
    
    upsampled_Response(:, :, 1) = filterResponse{1};
    localMax(:, :, 1) = ordfilt2(upsampled_Response(:, :, 1), 9, ones(3));

    
    for i = 2:n
       up = imresize(filterResponse{i}, [h w], 'bicubic');
%        startRow = ceil(size(up,1)/2 - h/2);
%        endRow = ceil(size(up,1)/2 + h/2);
%        startCol = ceil(size(up,2)/2 - w/2);
%        endCol = ceil(size(up,2)/2 + w/2);
%        up = up(startRow:endRow - 1, startCol:endCol - 1);
%         up = up(1:h, 1:w);
       upsampled_Response(:, :, i) = up; 
       %localMax(:, :, i) = colfilt(up, [3 3], 'sliding', @max);
       localMax(:, :, i) = ordfilt2(up, 9, ones(3));
    end
    
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
    %~~~~~~~~~ Scale space suppression per pixel in all scales ~~~~~~~~~%
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
    % Initialize 3D matrix to store max pixel values of all scales
    scaleMax = zeros(h, w, n);
    
    for i = 1:numel(upsampled_Response(:,:,1))
        % Converting form index to subscripts helps avoid nested for-loops
        [y, x] = ind2sub([h w], i);
        % Looking for max value of pixel in 3rd dimension
        maxPixel = max(localMax(y, x, :));
        % Assigning the max value found to all pixels with same subscript 
        % in all scales
        scaleMax(y, x, :) = maxPixel;
    end     
    
    % First logical finds the scale where max value appears, second 
    % logical eliminates any max value lower than threshold
    upsampled_Response = (upsampled_Response == scaleMax) .* (upsampled_Response > threshold)...
                  .* upsampled_Response;
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
    
    % Finding x, and y coordinates of surviving maxima along with the
    % scale at which it is located, and converting that to radius 
    [y, x, z] = ind2sub(size(upsampled_Response), find(upsampled_Response > 0));
    circY = y;
    circX = x;
    circR = radius(z);
    
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
    
    % Plotting detected blobs on image
    show_all_circles(imG, circX, circY, circR);
    title({'Downsample method', strcat(num2str(numel(circR)), ' circles')}, 'FontSize', 30); 
    xlabel(strcat('threshold = ', num2str(threshold)), 'FontSize', 30);
    
    
end
