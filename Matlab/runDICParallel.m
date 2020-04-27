% Arpad Kovesdy
% AME341bL - Junior Project
% Distributed Computing System
function [y,x,v,u,TOF,algoTime] = runDICParallel(img_a, img_b, n, step)
    %Send n number of requests to n servers
    
    %nx and ny are the dimensions of img_a
    [nx, ~] = size(img_a);
    nx_server = nx/sqrt(n);
    
    %Start the total process timer
    tic
    idx = 1;
    for x_loc = 0:nx_server:(nx-nx_server)
        for y_loc = 0:nx_server:(nx-nx_server)
            %Compensate for search box overrun detection
            
            if(x_loc <= nx-nx_server-(2*nx/8))
                x_length = nx_server+(2*nx/8);
            else
                x_length = nx_server;
            end
            if(y_loc <= nx-nx_server-(2*nx/8))
                y_length = nx_server+(2*nx/8);
            else
                y_length = nx_server;
            end
            
            %{
            x_length = nx_server;
            y_length = nx_server;
            %}
            %Create an asyncronous thread to send and collect the POST response
            f(idx) = parfeval(@distCompute,5, img_a, img_b, floor(nx/8), ...
                floor(x_loc), floor(y_loc), floor(x_length), floor(y_length), ...
                step, idx);
            idx = idx + 1;
        end
    end
    %result = afterAll(f, @(r) disp('Completed all tasks'), 0);
    [y,x,v,u,algoTime] = fetchOutputs(f);

    d2s = 24*3600;
    for idx2 = 1:idx-1
        scheduleStart = d2s*datenum(f(idx2).CreateDateTime);
        actualStart = d2s*datenum(f(idx2).StartDateTime);
        finish = d2s*datenum(f(idx2).FinishDateTime);
        %Total times are from parfeval command to complete array returned (s)
        totalTimes(idx2) = finish-scheduleStart;
        %Time of flight (TOF) are from the http script is started to array
        %returned (s)
        TOF(idx2) = finish-actualStart;
    end
    toc
end