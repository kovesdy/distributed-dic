% Post processing script
% Should have TOF_results and algo_results in the workspace

for trial = 1:4
    TOF = TOF_results{trial};
    algo = algo_results{trial};
    for i = 1:5
        TOF{i} - algoTimes{i}'
    end
end