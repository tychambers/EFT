import sqlite3
import ast
from time import strftime, localtime
import csv

db = "C:\EFT\Site db\SiteConfig.402cba8a-841a-4343-adfa-7d385bdaa8db.db"

query = """
SELECT * FROM "Client";
"""

conn = sqlite3.connect(db)
c = conn.cursor()
c.execute(query)
records = c.fetchall()

pw_list = []
for record in records:
    name = record[1]
    stats = ast.literal_eval(record[14])
    epoch_time = stats["PasswordChangedTime"]
    password_changed_time = strftime('%H:%M:%S %m-%d-%Y', localtime(epoch_time))
    # print(f"{name} Last Changed Password: {password_changed_time}")

    #Everything below is for exporting the Name and Change time to a csv
    #for print only uncomment line 22 and comment below
    
    pw_dict = {}
    pw_dict["Name"] = name
    pw_dict["Password Changed Time"] = password_changed_time
    pw_list.append(pw_dict)

field_names = ["Name", "Password Changed Time"]

#change C:\ location to your desired destination for csv file
with open("C:\EFT\Site db\pwchangetime.csv", 'w') as csvfile:
    writer = csv.DictWriter(csvfile, fieldnames=field_names)
    writer.writeheader()
    writer.writerows(pw_list)
