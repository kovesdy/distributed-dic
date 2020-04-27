# -*- coding: utf-8 -*-
"""
Created on Sun Apr 26 17:15:53 2020

@author: mende
"""

from flask import Flask, request, abort
import json
app = Flask(__name__)

@app.route('/', methods=['POST'])
def hello_world():
	data = json.loads(request.get_json())
	if 'password' in data and validate(data['password']):
		(y,x,v,u) = runAlgo(data['img_a'], data['img_b'], data['img_box_width'],
			data['img_x_start'], data['img_y_start'], data['img_x_length'], data['img_y_length'])
		return {"y":y, "x":x, "v":v, "u":u}
	else:
		abort(401); #Unauthorized

def validate(password):
	#TODO change to OS variable (set in linux server)
	return password == '12345'

def runAlgo(img_a, img_b, img_box_width, img_x_start, img_y_start, img_x_length, img_y_length):
    # Ax = Ay = Bx = By = img_box_width
    search_box_width = 2*img_box_width; # Sx = Sy = 2*Ax
    shift_dist = img_box_width / 2; # shiftx = shifty = Ax/2
    k = 0; # Loop control variable
    step = 1; # Change for optimal speed
    y = [];
    x = [];
    v = [];
    u = [];
    
    for p in range((search_box_width - img_box_width)/2 + img_x_start, img_x_start + img_x_length - search_box_width, shift_dist):
        # progress indicator...
        print('' + 100*p/(img_x_start + img_x_length - search_box_width) + '% completed\n');
        
        for q in range((search_box_width - img_box_width)/2 + img_y_start, img_y_start + img_y_length - search_box_width, shift_dist):
            # pixel array A
            A = float(img_a[range(p,p + img_box_width), range(q,q + img_box_width)]); 
            A_avg = sum(sum(A)) / (img_box_width^2); # I_a average value
            
            C = [[0 for g in range(0, search_box_width-img_box_width)] for h in range(0, search_box_width-img_box_width)];
            # Find the displacement of A by correlating this pixel array with all possible destinations B(K,L) in search box S of img_b
            for i in range(-(search_box_width-img_box_width)/2, (search_box_width-img_box_width)/2, step): # x pixel shift within S
                for j in range(-(search_box_width-img_box_width)/2, (search_box_width-img_box_width)/2, step): # y pixel shift within S
                    # pixel array B (size(A) = size(B) < size(S))
                    B = float(img_b[range(i+p,i+p+img_box_width), range(j+q,j+q+img_box_width)]);
                    B_avg = sum(sum(B)) / (img_box_width^2); # I_b average value
                    
                    # Calculate the correlation coefficient, C, for this pixel array
                    # Evaluate C at all possible locations (index shifts I, J).
                    # The best correlation determines the displacement of A into img_b.
                    C[i+(search_box_width-img_box_width)/2, j+(search_box_width-img_box_width)/2] = sum(sum((A - A_avg)*(B - B_avg))) / (sum(sum((A - A_avg)^2)) * sum(sum(B-B_avg)^2))^(1/2);
                    
            [actualMax, maxIndex] = max[C];
            [maxi, yInd] = max(actualMax); # Second result is the y index of max. value of C
            xInd = maxIndex[yInd]; # x index of max value of C
            
            y.append(q + (search_box_width - img_box_width)/2);
            x.append(p + (search_box_width - img_box_width)/2);
            v.append(yInd - (search_box_width - img_box_width)/2);
            u.append(xInd - (search_box_width - img_box_width)/2);
            k = k + 1;
    return (y,x,v,u)