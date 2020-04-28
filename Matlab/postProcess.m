% Post processing script
% Should have TOF_results and algo_results in the workspace

close all;

algo_max = [];
for i = 1:4
    algo_max(i) = max(mean(algo_results{i}));
    TOF_max(i) = max(mean(TOF_results{i}));
    algo_stds(i) = max(std(algo_results{i}));
    TOF_stds(i) = max(std(TOF_results{i}));
end

algo_stds(1) = std(algo_results{1});
TOF_stds(1) = std(TOF_results{1});

%Describes the transfer time
transfer = TOF_max - algo_max;

%Generate bar graph for these results - breakdown by type of time
figure();
x = [1, 4, 9, 16];
y = [];
y(1,:) = TOF_max;
y(2,:) = transfer;
bar(x,y,'stacked');
xlabel('Number of servers');
ylabel('Seconds');
legend('Algorithm Runtime', 'Transfer Time');

%Generate line of best fit for results to linear increase
figure();
hold on;
errorbar(x, TOF_max, TOF_stds, '.', 'MarkerSize', 10);
errorbar(x, algo_max, algo_stds, '.', 'MarkerSize', 10);
xlabel('Number of servers');
ylabel('Seconds');
plotx = 1:0.1:20;
plot(plotx, TOF_max(1)./(plotx.^1));
legend('Measured (total)', 'Measured (algorithm only)', 'Theoretical');
hold off;

%Bar graph - breakdown by server load
figure();
y2 = [];
y2(:,4) = mean(algo_results{4})';   
y2(1:9,3) = mean(algo_results{3})';
y2(1:4,2) = mean(algo_results{2})';
y2(1,1) = mean(algo_results{1})';
bar(x, y2, 'stacked');
xlabel('Number of servers');
ylabel('Seconds');
title('Algorithm Runtime per Server');

%Plot - percentage that transfer time is of total time
figure();
plot(x, (transfer./TOF_max), '.', 'MarkerSize', 15);
xlabel('Number of servers');
ylabel('Transfer Time/Total Time');
title('Transfer Time Ratio');
axis([0, 20, 0, 0.4])
