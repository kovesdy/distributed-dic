from flask import Flask, request, abort
import json
app = Flask(__name__)

@app.route('/', methods=['POST'])
def hello_world():
	data = json.loads(request.get_json())
	if 'password' in data and validate(data['password']):
		return {"array":data['array']}
	else:
		abort(401); #Unauthorized

def validate(password):
	#TODO change to OS variable (set in linux server)
	return password == '12345'

#def runAlgo(img, array, bounds):
