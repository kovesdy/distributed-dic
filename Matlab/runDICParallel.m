%Send n number of requests to servers
for idx = 1:4
    %Create an asyncronous thread to send and collect the POST response
    f(idx) = parfeval(@distCompute, 1, [1,2;3,4]);
end
afterAll(f, @(r) disp(r), 0);