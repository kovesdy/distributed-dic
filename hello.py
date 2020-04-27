# -*- coding: utf-8 -*-
"""
Created on Sun Apr 26 17:15:53 2020

@author: mende
"""

from flask import Flask, request, abort
import math
import json
import operator
import numpy
from numpy import array, power, amax, argmax
app = Flask(__name__)

@app.route('/', methods=['POST'])
def hello_world():
	data = json.loads(request.get_json())
	if 'password' in data and validate(data['password']):
		(y,x,v,u) = runAlgo(data['img_a'], data['img_b'], data['img_box_width'],
			data['img_x_start'], data['img_y_start'], data['img_x_length'], data['img_y_length'])
		returnDic = {"y":y, "x":x, "v":v, "u":u}
		return returnDic
	else:
		abort(401); #Unauthorized

def validate(password):
	#TODO change to OS variable (set in linux server)
	return password == '12345'

def runAlgo(img_a, img_b, img_box_width, img_x_start, img_y_start, img_x_length, img_y_length):
    # Ax = Ay = Bx = By = img_box_width
    search_box_width = 2*img_box_width; # Sx = Sy = 2*Ax
    shift_dist = img_box_width // 2; # shiftx = shifty = Ax/2
    step = 1; # Change for optimal speed
    y = [];
    x = [];
    v = [];
    u = [];
    img_a = array(img_a)
    img_b = array(img_b)
    gorg = (search_box_width - img_box_width)//2;
    
    for p in range(gorg + img_x_start, img_x_start + img_x_length - search_box_width, shift_dist):
        # Progress indicator...
        print(str(100*p/(img_x_start + img_x_length - search_box_width)) + "% completed\n");
        
        for q in range(gorg + img_y_start, img_y_start + img_y_length - search_box_width, shift_dist):
            # pixel array A
            A = img_a[p:p + img_box_width, q:q + img_box_width]; 
            A_avg = sum(sum(A)) / (img_box_width^2); # I_a average value
            
            C = array([[0 for g in range(0, gorg*2)] for h in range(0, gorg*2)]);
            # Find the displacement of A by correlating this pixel array with all possible destinations B(K,L) in search box S of img_b
            for i in range(-gorg, gorg, step): # x pixel shift within S
                for j in range(-gorg, gorg, step): # y pixel shift within S
                    # pixel array B (size(A) = size(B) < size(S))
                    B = img_b[i+p:i+p+img_box_width, j+q:j+q+img_box_width];
                    B_avg = sum(sum(B)) / (img_box_width^2); # I_b average value
                    
                    # Calculate the correlation coefficient, C, for this pixel array
                    # Evaluate C at all possible locations (index shifts I, J).
                    # The best correlation determines the displacement of A into img_b.
                    a1 = A - A_avg
                    b1 = B - B_avg
                    C[i+gorg, j+gorg] = sumSumArrMult(a1, b1) / math.pow(sum(sum(power(a1, 2))) * sum(sum(power(b1,2))), 0.5);
                    
            actualMax = amax(C, axis=0) #Gets max value of each COLUMN (axis=0 option)
            maxIndex = argmax(C, axis=0)
            maxi = amax(actualMax)
            yInd = argmax(actualMax)
            xInd = maxIndex[yInd]; # x index of max value of C
            
            y.append(numpy.int16(q + gorg).item());
            x.append(numpy.int16(p + gorg).item());
            v.append(numpy.int16(yInd - gorg).item());
            u.append(numpy.int16(xInd - gorg).item());
    return (y,x,v,u)


#Scalar multiplication
#Assumes and b are the same size
def sumSumArrMult(a, b):
    c = 0; #Initialize to the same size
    n = len(a)
    for f in range(0, n):
        for g in range(0, n):
            c += a[f,g] * b[f,g]
    return c