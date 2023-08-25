% Initialize the filenames of the photos and the sample volume to be analyzed
FileName = {'1-1.JPG', '1-2.JPG', '1-3.JPG'};
Sample_volume = 0.94;

% Initialize variables to store total pixels and pixels list
sum_pixels = 0;
pixels_list = [];

% Loop through each photo and analyze for particles
for i = 1:length(FileName)
    
    % Load the image
    image = imread(FileName{i});

    % Trim the image to remove the alpha channel if it exists
    rgbImage = image(:,:,1:3);
    figure(i); 
    imshow(rgbImage);

    % Extract the red channel
    red = image(:,:,1);

    % Automatic threshold
    intensity2_auto = 25/255;

    % Convert the red image to binary using the threshold
    r_b = im2bw(red, intensity2_auto);
    figure(i); 
    imshow(r_b);
    
    
    % Calculate the area of all objects in the image
    stats = regionprops(r_b, 'Area');
    A = [stats.Area];
    % Find all the highlights
    B = find(A >= 0);
    circle_area = A(B);
    
    % Update the total pixel count and pixels list
    sum_pixels = sum_pixels + sum(circle_area);
    pixels_list = [pixels_list, sum(circle_area)];

end

% Calculate average pixel count and total pixel count
average = sum_pixels/length(FileName);
total = sum_pixels;

% Define thresholds and names for each size category
sizes = { '10 micrometer', '1 micrometer', '500 nanometer', '50 nanometer' };
thresholds = [8152, 3069, 13681, 18286];
upper_bounds = [90151, 52602, 70143, 127953];
coefficients = [1884, 2820, 4389, 2337];
offsets = [2045, -6788, -940, 19658];
scale_factors = [100, 100000, 1000000, 100000000];

% Classification and quantification based on different size thresholds
for i = 1:length(sizes)
    if average < thresholds(i)
        result_1 = "negative";
    else 
        result_1 = "positive";
    end

    if average > upper_bounds(i)
        result_2 = "Dilution required.\n";
    else 
        result_2 = "";
    end

    if average > thresholds(i) && average < upper_bounds(i)
        result = (average-offsets(i))/coefficients(i)*scale_factors(i)*(100/Sample_volume);
        result_list = (pixels_list-offsets(i))/coefficients(i)*scale_factors(i)*(100/Sample_volume);
        result_std = std(result_list);
    else
        result = "/";
        result_std = "/";
    end

    fprintf("\n\nPositive/negative? \nif %s: %s.\n", sizes{i}, result_1);
    if ~isempty(result_2)
    fprintf("%s",result_2);
end
    fprintf("Quantity concentration (n/mL) (average ± standard deviation): %s ± %s.\n", result, result_std);
    
end

  %  fprintf("Average pixel area: %d.\n", floor(average))