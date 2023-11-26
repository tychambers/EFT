#Updates Admin password hash in ServerConfig.db file
#New password = Admin123!!!
import sqlite3

#Change below to location of serverconfig file
db = "C:\EFT\db files\ServerConfig.db"

#Change Name = "" to desired Admin name
query = """Update Admin set PasswordHash = "$5$SyJGOOkn7+YGoG3c3dOuuX7S$lrNTbrwzwJaDbfX3pRJXv6ItsDCFpfLj6fK10KF8c2M=" where Name = 'Admin1234'"""

conn = sqlite3.connect(db)
c = conn.cursor()
c.execute(query)
conn.commit()
conn.close()