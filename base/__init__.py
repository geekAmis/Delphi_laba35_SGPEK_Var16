import requests
import sqlite3
from bs4 import BeautifulSoup as bs 
import os
import time
import random
import base64
import hashlib
from flask import *
from flask_socketio import SocketIO, emit, join_room
import difflib
from tqdm import tqdm

def salth(string) ->str:
	dop = (int.from_bytes(string[-1].encode(), byteorder='big')*int.from_bytes(string[1].encode(), byteorder='big'))//9+7
	try:
		dop = dop.to_bytes((dop.bit_length() + 7) // 8, 'big').decode('ascii')
	except:
		try:
			dop = dop.to_bytes((dop.bit_length() + 7) // 8, 'big').decode('utf-8')
		except:
			dop = string[-1]+string[3]
	
	dop = dop.replace('"','S').replace(',','m').replace('.','_=_').replace('@','').replace(' ','4').replace('?','§')
	return str(str(string)+str(dop))

def base64_encode_md5(string) -> str:
	return salth(base64.b64encode(
			hashlib.md5(
				hashlib.sha256(
					string.encode('utf-8')
				).digest()
			).digest()).decode('utf-8', 'backslashreplace')[:-2:]).replace('Sm','+')

def encode_for_char(strings) -> str:
	end = ''
	for string in strings:
		end += base64_encode_md5(base64_encode_md5(string))
	return base64_encode_md5(base64_encode_md5(end))



app = Flask(__name__)
app.config['SECRET_KEY'] = encode_for_char('secret!')
socketio = SocketIO(app)