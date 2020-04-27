% Arpad Kovesdy
% AME341bL - Junior Project
% Distributed Computing System

%Select threading system (not process worker system) for parallel
%processing
%parpool('threads');
function [y,x,v,u] = runDICParallel(img_a, img_b, n)
    %Send n number of requests to n servers
    tic
    for idx = 1:4
        %Create an asyncronous thread to send and collect the POST response
        f(idx) = parfeval(@distCompute, 1, [1,2;3,4]);
    end
    result = afterAll(f, @(r) disp('Completed all tasks'), 0);
    fetchOutputs(result);

    d2s = 24*3600;
    for idx = 1:4
        scheduleStart = d2s*datenum(f(idx).CreateDateTime);
        actualStart = d2s*datenum(f(idx).StartDateTime);
        finish = d2s*datenum(f(idx).FinishDateTime);
        disp(finish-scheduleStart);
        %Total times are from parfeval command to complete array returned (s)
        totalTimes(idx) = finish-scheduleStart;
        %Time of flight (TOF) are from the http script is started to array
        %returned (s)
        TOF(idx) = finish-actualStart;
    end
    toc
end