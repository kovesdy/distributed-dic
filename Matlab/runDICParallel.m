% Arpad Kovesdy
% AME341bL - Junior Project
% Distributed Computing System
function [y,x,v,u] = runDICParallel(img_a, img_b, n)
    %Send n number of requests to n servers
    
    %nx and ny are the dimensions of img_a
    [nx, ~] = size(img_a);
    nx_server = nx/sqrt(n);
    
    %Start the total process timer
    tic
    idx = 1;
    for x_loc = 0:nx_server:(nx-nx_server)
        for y_loc = 0:nx_server:(nx-nx_server)
            %Create an asyncronous thread to send and collect the POST response
            f(idx) = parfeval(@distCompute,4, img_a, img_b, nx_server/4, ...
                x_loc, y_loc, nx_server, nx_server);
            idx = idx + 1;
        end
    end
    %result = afterAll(f, @(r) disp('Completed all tasks'), 0);
    [y(idx), x(idx), v(idx), u(idx)] = fetchOutputs(f);

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