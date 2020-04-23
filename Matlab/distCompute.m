function newArr = distCompute(img)
    %Import HTTP functions
    import matlab.net.*
    import matlab.net.http.*
    
    %Testing locally:
    %url = 'http://127.0.0.1:5000';
    %Main use:
    url = 'http://ec2-54-153-109-202.us-west-1.compute.amazonaws.com:5000';
    
    %Form request body
    sendData.password = "12345";
    sendData.array = img;
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
        if (resp.Body.Data.array == sendData.array)
            newArr = resp.Body.Data.array;
        end
    elseif(resp.StatusCode == 401)
        fprintf('Wrong password sent to server.\n');
    else
        fprintf('Exited with status:');
        disp(resp.StatusCode);
    end
end