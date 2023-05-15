from __init__ import *

db_name = 'base.sqlite3'

new = input('Новую базу генерируем? (Y/n)').lower() == 'y'

if db_name in os.listdir() and new:
	os.remove(db_name)
if db_name not in os.listdir():  new = True

conn = sqlite3.connect(db_name)
cur = conn.cursor()

curcess = 5
max_students = 30
bukvs = "А Б".split(' ')
nominates = "ИТ СИС ИСИП ЭТ ИМ ИГ".split(' ')
names = "Игорь Фатэр Иван Сабина Ирина Виталя Максим Роман Паша Гриша Таня Ирис Кузя Пётр Алина Алиса Аркадий Олег Ольга Осип Бак Бахат".split(' ')
surnames = "Лис Академко Маленко Петренко Шикуски Махамедив Максимот Дарьяно Живало Вороно Нисано Ишики Шингаке".split(' ')
malenames = "Фрол Ино Шики Ашура Асуна Наруто Итаче Ромиданс".split(' ')
exams = "ОАиП,Матем.,Грф.Диз.,Экономика,Право,Родной Я-з,Английский Я-з,Физ-ра,ОС,Информатика,ОБЖ,Физика,Физика ИТ".split(',')

studies = []

def get_random_name():
	return f'{random.choice(surnames)} {random.choice(names)} {random.choice(malenames)}'

def exam_get():
	return random.sample(exams, 5)

def dolgs(mas):
	count = 0
	for i in mas:
		if i == 2:  count+=1
	return count
	

if new:
	for nomin in tqdm(nominates):
		for bukv in tqdm(bukvs,ascii=' #'):
			for curce in tqdm(range(1,random.randint(3,curcess)+1),ascii=' %^'):
				exam = exam_get()
				cur.execute(f'''
				   CREATE TABLE IF NOT EXISTS {nomin}{curce}{bukv}(
				       name text PRIMARY KEY, 
				       session text,
				       phone text,
				       birthday text,
				       parrent_male text,
				       parrent_female text,
				       vk_link text,
				       note text ,
				       exams text
				)''')
				studies.append({
					"group": f"{nomin}{curce}{bukv}",
					"students":[]
				})
				conn.commit()
				for i in range(0,random.randint(5,max_students)):
					name = get_random_name()
					session = [int(i) for i in f'{random.randint(2,5)} {random.randint(2,5)} {random.randint(2,5)} {random.randint(2,5)} {random.randint(2,5)}'.split(' ')]
					phone = "+7927"+str(random.randint(1000000,9999999))
					birthday = f'{random.randint(1,25)}.{random.randint(1,12)}.{random.randint(2005-int(curce)-2,2006-int(curce))}'
					parrent_male = f"{random.choice(names)} {name.split(' ')[2]} {random.choice(malenames)}"
					parrent_female = get_random_name()
					vk_link = f"https://vk.com/id{random.randint(1,99999999)}"
					cur.execute(f'''
						INSERT OR IGNORE INTO {nomin}{curce}{bukv} (name, session, phone, birthday, parrent_male, parrent_female, vk_link, note,exams) VALUES (
						'{name}',
						'{"".join([str(i) for i in session])}',
						'{phone}',
						'{birthday}',
						'{parrent_male}',
						'{parrent_female}',
						'{vk_link}',
						'Нет заметок',
						'{",".join([str(i) for i in exam])}'
					);
					''')
					conn.commit()
					studies[-1]["students"].append({
						"name": name,
						"session": session,
						"phone":f"{phone}",
						"birthday":f"{birthday}",
						"parrent_male":f"{parrent_male}",
						"parrent_female":f"{parrent_female}",
						"vk_link":vk_link,
						"note":"Нет заметок",
						"exams":exam,
						"exams_split": ",".join(exam),
						"session_split": ",".join([str(i) for i in session])
					})

	for item in studies:
		for student in item['students']:
			studies[studies.index(item)]['students'][item['students'].index(student)]['sum'] = sum(student['session'])/len(student['session'])
			studies[studies.index(item)]['students'][item['students'].index(student)]['dolgs'] = dolgs(student['session'])
	for item in range(0,len(studies)):
		studies[item]["students"].sort(key=lambda x: -(sum(x.get("session")) / len(x.get('session'))))

def change_student(json_object,group_id,student_id):
	sqlite_update_query = f"""Update {json_object[group_id]['group']} set name = ?, session = ?, 
		phone = ?, 
		birthday = ?, 
		vk_link = ?, 
		note = ?, 
		exams = ?
		where name = ?
	"""
	column_values = (
		json_object[group_id]["students"][student_id]["name"],
		"".join(str(i) for i in json_object[group_id]["students"][student_id]["session"]),
		json_object[group_id]["students"][student_id]["phone"],
		json_object[group_id]["students"][student_id]["birthday"],
		json_object[group_id]["students"][student_id]["vk_link"],
		json_object[group_id]["students"][student_id]["note"],
		json_object[group_id]["students"][student_id]["exams_split"],
		json_object[group_id]["students"][student_id]["name"]
	)
	cur.execute(sqlite_update_query, column_values)
	conn.commit()

def load_base():
	global studies
	studies = []
	sql_query = """
		SELECT name FROM sqlite_master 
		WHERE type='table';
	"""

	print(f'Update DataBase from {db_name}')
	
	cur.execute(sql_query)
	base_names = [i[0] for i in cur.fetchall()]
	for name_this in tqdm(base_names):
		studies.append(
			{
				"group": name_this,
				"students":[]
			}
		)
		rows = cur.execute(f"SELECT * FROM {name_this}").fetchall()
		for row in rows:
			studies[-1]["students"].append(
				{
					"name": row[0],
					"session": [int(i) for i in list(row[1])],
					"phone": row[2] ,
				    "birthday": row[3] ,
				    "parrent_male": row[4] ,
				    "parrent_female": row[5] ,
				    "vk_link": row[6] ,
				    "note": row[7]  ,
				    "exams": row[8].split(','),
				    "exams_split": row[8],
				    "session_split": ",".join(list(row[1])),
				    "sum": sum([int(i) for i in list(row[1])])/len(row[1]),
				    "dolgs": dolgs([int(i) for i in list(row[1])])
				}	
			)

if not new:
	load_base()

basa = [
	{
		"name": "lolix",
		"login": "all",
		"password": encode_for_char("".join([random.choice(list("qwertyuiop[]asdfghjkl;'zxcvbnm,./?><MNBVCXZASDFGHJKL:}{POIUYTREWQ!@#$%^&*()_+=-0987654321")) for i in range(0,33)]))
	},
	{
		"name": "lolix1",
		"login": "alli",
		"password": encode_for_char("".join([random.choice(list("qwertyuiop[]asdfghjkl;'zxcvbnm,./?><MNBVCXZASDFGHJKL:}{POIUYTREWQ!@#$%^&*()_+=-0987654321")) for i in range(0,33)]))
	},
	{
		"name": "lolix2",
		"login": "alla",
		"password": encode_for_char("".join([random.choice(list("qwertyuiop[]asdfghjkl;'zxcvbnm,./?><MNBVCXZASDFGHJKL:}{POIUYTREWQ!@#$%^&*()_+=-0987654321")) for i in range(0,33)]))
	},
	{
		"name": "lolix3",
		"login": "allo",
		"password": encode_for_char("".join([random.choice(list("qwertyuiop[]asdfghjkl;'zxcvbnm,./?><MNBVCXZASDFGHJKL:}{POIUYTREWQ!@#$%^&*()_+=-0987654321")) for i in range(0,33)]))
	},
	{
		"name": "lolix3",
		"login": "allo",
		"password": encode_for_char("".join([random.choice(list("qwertyuiop[]asdfghjkl;'zxcvbnm,./?><MNBVCXZASDFGHJKL:}{POIUYTREWQ!@#$%^&*()_+=-0987654321")) for i in range(0,33)]))
	},
	{
		"name": "adminDelphi",
		"login": "DelphiAdmin",
		"password": encode_for_char("".join([random.choice(list("0D1E2LP3H4I5A6D7M8I9N-")) for i in range(1,len(list("0D1E2LP3H4I5A6D7M8I9N-"))-1)]))
	},
	{
		"name": "lolix3",
		"login": "allo",
		"password": encode_for_char("".join([random.choice(list("qwertyuiop[]asdfghjkl;'zxcvbnm,./?><MNBVCXZASDFGHJKL:}{POIUYTREWQ!@#$%^&*()_+=-0987654321")) for i in range(0,33)]))
	},
	{
		"name": "lolix3",
		"login": "allo",
		"password": encode_for_char("".join([random.choice(list("qwertyuiop[]asdfghjkl;'zxcvbnm,./?><MNBVCXZASDFGHJKL:}{POIUYTREWQ!@#$%^&*()_+=-0987654321")) for i in range(0,33)]))
	},
	{
		"name": "lolix3",
		"login": "allo",
		"password": encode_for_char("".join([random.choice(list("qwertyuiop[]asdfghjkl;'zxcvbnm,./?><MNBVCXZASDFGHJKL:}{POIUYTREWQ!@#$%^&*()_+=-0987654321")) for i in range(0,33)]))
	},
	{
		"name": "lolix3",
		"login": "allo",
		"password": encode_for_char("".join([random.choice(list("qwertyuiop[]asdfghjkl;'zxcvbnm,./?><MNBVCXZASDFGHJKL:}{POIUYTREWQ!@#$%^&*()_+=-0987654321")) for i in range(0,33)]))
	},
	{
		"name": "lolix3",
		"login": "allo",
		"password": encode_for_char("".join([random.choice(list("qwertyuiop[]asdfghjkl;'zxcvbnm,./?><MNBVCXZASDFGHJKL:}{POIUYTREWQ!@#$%^&*()_+=-0987654321")) for i in range(0,33)]))
	},
	{
		"name": "lolix33",
		"login": "allo",
		"password": encode_for_char("".join([random.choice(list("qwertyuiop[]asdfghjkl;'zxcvbnm,./?><MNBVCXZASDFGHJKL:}{POIUYTREWQ!@#$%^&*()_+=-0987654321")) for i in range(0,33)]))
	}
]