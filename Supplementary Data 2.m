% input the filename
%{
The file shoule be in the following format:
number test_1 test_2 test_3 ... test_n
#      #      #      #      ... #
%}
filename = 'filename.xls';
% load data
data = readtable(filename);
% get the size of data
data_size = size(data);
% get the test times
test_num = data_size(2) - 1;
% assume the first M groups of data are linear
% in this case, we set M = 4
M = 4;

% get column of "number"
original_number = data.("number");
% obtain test results
test_list = [];
for i = 1:test_num
    test_list = [test_list, data.("test_" + num2str(i))];
end

% calculate average result
average = mean(test_list, 2);

% eliminate average value of zero
proc_number = [];
proc_average = [];
for i = 1:length(average)
    if average(i) ~= 0
        proc_number = [proc_number, original_number(i)];
        proc_average = [proc_average, average(i)];
    end
end
% save origin number
origin_number = proc_number;
% log10 operation
proc_number = log10(proc_number);
proc_average = log10(proc_average);

% start the fitting process
for i = M:length(proc_number)
    x = proc_number(1:i);
    y = proc_average(1:i);

    % use poly to fit the curv
    f = polyfit(x, y, 1);

    % prediction
    y_pred = polyval(f, x);

    % calculate the deviation
    deviation = y - y_pred;

    % calculate the mean and var of deviation
    mean_dev = mean(deviation);
    var_dev = var(deviation);

    % verify that the next one meets the requirements
    if i == length(proc_number)
        fprintf("The max plastic number in linear part is: %d \n", origin_number(i));
        fprintf("Fitting curve is f(x) = (%fx) + (%f)", f(1), f(2));
        break
    end
    next_x = proc_number(i+1);
    next_y = proc_average(i+1);
    next_y_pred = polyval(f, next_x);
    next_deviation = next_y_pred - next_y;
    % check if next_dev var is smaller than var_dev
    if (next_deviation - mean_dev)^2 <= var_dev
        continue
    else
        fprintf("The max plastic number in linear part is: %d \n", origin_number(i));
        fprintf("Fitting curve is f(x) = (%fx) + (%f)", f(1), f(2));
        break
    end
end










