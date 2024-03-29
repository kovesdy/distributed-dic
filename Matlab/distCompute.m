function [y,x,v,u,algoTime] = distCompute(img_a, img_b, img_box_width, img_x_start, ...
    img_y_start, img_x_length, img_y_length, step, i)
    %i is the number of request, so that we can send them NOT to
    %consecutive servers
    %Import HTTP functions
    import matlab.net.*
    import matlab.net.http.*
    %{
    %Testing locally:
    url = 'http://127.0.0.1:5000';
    %Main use:
    %}
    n_servs = 9; %Total number of servers
    switch mod(i, n_servs)
        case 0
            url = 'http://ec2-54-153-109-202.us-west-1.compute.amazonaws.com:5000';    
        case 1
            url = 'http://ec2-54-153-127-88.us-west-1.compute.amazonaws.com:5000';
        case 2
            url = 'http://ec2-204-236-180-243.us-west-1.compute.amazonaws.com:5000';
        case 3
            url = 'http://ec2-54-153-102-11.us-west-1.compute.amazonaws.com:5000';
        case 4
            url = 'http://ec2-13-52-242-33.us-west-1.compute.amazonaws.com:5000';
        case 5
            url = 'http://ec2-3-101-25-193.us-west-1.compute.amazonaws.com:5000';
        case 6
            url = 'http://ec2-54-176-41-10.us-west-1.compute.amazonaws.com:5000';
        case 7
            url = 'http://ec2-13-52-243-17.us-west-1.compute.amazonaws.com:5000';
        case 8
            url = 'http://ec2-52-53-197-114.us-west-1.compute.amazonaws.com:5000';
    end
    
    %Form request body
    sendData.password = "12345";
    sendData.img_a = img_a;
    sendData.img_b = img_b;
    sendData.img_box_width = img_box_width;
    sendData.img_x_start = img_x_start;
    sendData.img_y_start = img_y_start;
    sendData.img_x_length = img_x_length;
    sendData.img_y_length = img_y_length;
    sendData.step = step;
    body = MessageBody(jsonencode(sendData));

    %Create header for the request
    %We are transmitting json objects to the server
    contentTypeField = matlab.net.http.field.ContentTypeField('application/json');
    %We will only accept json responses back
    type_json = matlab.net.http.MediaType('application/json','q','.5');
    acceptField = matlab.net.http.field.AcceptField(type_json);
    header = [acceptField contentTypeField];

    %Formulate a POST request and send to designated URI
    r = RequestMessage(RequestMethod.POST, header, body);
    uri = URI(url);
    resp = send(r,uri);

    %Read status code to check for success
    if(resp.StatusCode == 200)
        fprintf('Request successful.\n');
        y = resp.Body.Data.y;
        x = resp.Body.Data.x;
        u = resp.Body.Data.u;
        v = resp.Body.Data.v;
        algoTime = resp.Body.Data.timeElapsed;
    elseif(resp.StatusCode == 401)
        fprintf('Wrong password sent to server.\n');
    else
        fprintf('Exited with status:');
        disp(resp.StatusCode);
    end
end