from base import *

#encode = encode_for_char(input("String: "))



@app.errorhandler(404)
def page_not_found(e):
	# note that we set the 404 status explicitly
	return render_template('404.html'), 404

@app.errorhandler(403)
def page_access_denied(e):
	# note that we set the 404 status explicitly
	return render_template('403.html'), 403



@app.route('/', methods=['GET', 'POST'])
def index():
	load_base()
	return jsonify(studies)

@app.route('/current',methods=['GET'])
def current_return():
	if request.method == 'GET' and request.args.get('all') != None:
		return jsonify(studies[int(request.args.get('group'))]["students"])
	return jsonify(studies[int(request.args.get('group'))]["students"][int(request.args.get('student'))])

@app.route('/users', methods=['GET', 'POST'])
def users():
	if request.method == 'GET' and int(request.args.get('user')) <= len(basa)-1:
		load_base()
		return jsonify(basa[int(request.args.get('user'))])

@app.route('/get_name/<group>/<name>/', methods=['GET'])
def get_of_name(group,name):
	if group != '' and name != '':
		for index in studies:
			if index["group"].lower() == group.lower():
				for student in index["students"]:
					if student["name"].lower().replace(' ','') == name.lower().replace(' ',''):
						return jsonify(student)
				return jsonify({'error_msg':f"Not Found Name {name}."})
		return jsonify({'error_msg':f"Not Found group {group}."})
	else:
		jsonify({'error_msg':f'group and name must be in base and don\'t be zerro string | Group = {group} | name = {name}.'})

@app.route('/panel/<group>/',methods=['GET'])
def panel_change_pers(group):
	index_name = -13
	if group != '':
		for index in studies:
			if index["group"].lower() == group.lower():
				index_name = studies.index(index)

	if index_name != -13:
		return render_template('panel.html',index_name=index_name,json_data=Markup(studies),group_name=studies[index_name]['group'])
	else:
		return jsonify({'error_msg':'Error Group Name.'})

@app.route('/test/')
def testter():
	return render_template('test_server.html')

@app.route('/change/<int:group>/<int:student>')
def changer(group,student):
	return render_template('index.html',data=Markup(studies),index_group=group,index_student=student)

@app.route('/close/<group_name>')
def closed_window(group_name):
	return render_template('form.html',gname=group_name)

@app.route('/go',methods=['GET'])
def gogo_search_student_by_name():
	if str(request.args.get('name')) == '' or request.args.get('name') == None:
		return jsonify({'error_msg':'Empty value "name".','error_code':500})
	else:
		for data in studies:
			for student in data["students"]:
				if student["name"].lower() == request.args.get('name').lower():
					student["group"] = data["group"]
					return jsonify(student)
	return jsonify({'error_msg':'Not Found student by "name" = {}.'.format(request.args.get('name')),'error_code':404})



@socketio.on('change_data')
def handle_message(datan):
	load_base()
	print(studies[datan["need"][0]]["students"][datan["need"][1]]["name"])
	studies[datan["need"][0]]["students"][datan["need"][1]]["name"] = datan["peers"]["name"]
	studies[datan["need"][0]]["students"][datan["need"][1]]["phone"] = datan["peers"]["phone"]
	studies[datan["need"][0]]["students"][datan["need"][1]]["birthday"] = datan["peers"]["birthday"]
	studies[datan["need"][0]]["students"][datan["need"][1]]["vk_link"] = datan["peers"]["vk_link"]
	studies[datan["need"][0]]["students"][datan["need"][1]]["note"] = datan["peers"]["note"]
	studies[datan["need"][0]]["students"][datan["need"][1]]["session"] = datan["session"]
	studies[datan["need"][0]]["students"][datan["need"][1]]["dolgs"] = dolgs([int(i) for i in datan['session']])
	studies[datan["need"][0]]["students"][datan["need"][1]]["sum"] = sum([int(i) for i in datan['session']])/len(datan['session'])
	studies[datan["need"][0]]["students"][datan["need"][1]]["session_split"] = ",".join([str(i) for i in datan["session"]])
	change_student(studies,datan["need"][0],datan["need"][1])

def shozest(text1,text2):
	try:
		text1 = text1.lower().replace(' ','')
		text2 = text2.lower().replace(' ','')
		mat = difflib.SequenceMatcher(None, text1, text2)
		if mat.ratio() > 0.22:
			return mat.ratio()
		return 0.22
	except Exception as error:
		print(f'--------------------------\nError in recognize.\n \n{error} \n --------------------------')
		if text1.split(' ')[0:len(text1.split(' '))-2] == text2.split(' ')[0:len(text2.split(' '))-2]:
			return 0.8
		elif text1 == text2:
			return 1.0
		elif text1.split(' ')[0] == text2.split(' ')[0]:
			return 0.43
		else:
			return 0.22

def search_max_return_index(mas):
	max_= 0
	for i in mas:
		if i > max_:
			max_ = i
	return (mas.index(max_),max_)

@app.route('/search_ai/<name>/')
def search_student(name):
	curok = []
	stud_list = []
	if name == '':
		return jsonify({'error_msg':'Имя должно быть заполнено.'})
	else:
		for data in studies:
			for student in data["students"]:
				curok.append(shozest(name,student["name"]))
				stud_list.append((student,data["group"]))

		stud = search_max_return_index(curok)[0]
		print(search_max_return_index(curok)[1])
		stud_list[stud][0]["group"] = stud_list[stud][1]
		return jsonify(stud_list[stud][0])
		return jsonify({'error_msg': 'Not Found.','error_code':404})


@app.route('/search/<name>/')
def search_withoutAll(name):
	if name == '':
		return jsonify({'error_msg':'Имя должно быть заполнено.'})
	else:
		for data in studies:
			for student in data["students"]:
				if student["name"].lower().replace(' ','') == name.lower().replace(' ',''):
					return jsonify(student)
	
	return jsonify({'error_msg': 'Not Found.','error_code':404})

@app.route('/user/<group>/',methods=['GET'])
def user_info(group):
	if group != '':
		load_base()
		for index in studies:
			if index["group"].lower() == group.lower():
				return jsonify(index["students"][int(request.args.get('user'))])

		return jsonify({'error_msg':'Not Found.'})
	else:
		return jsonify({'error_msg':'Group = None.'})


socketio.run(app, host=f'localhost', port=80)