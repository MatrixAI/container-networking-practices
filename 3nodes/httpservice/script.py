from bottle import run, request, get
import psycopg2

def connect_db():
	return psycopg2.connect(host="10.0.5.3", port="1234")

@get('/insert/<string:path>')
def insert(string):
	conn = connect_db()
	cursor = conn.cursor()
	cursor.execute("INSERT INTO Test VALUES (%s)" % (string,))
	cursor.commit()
	cursor.close()
	return json.dumps('success')

	
