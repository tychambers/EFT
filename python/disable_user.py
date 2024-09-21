from win32com import client

eftServer = "localhost"
eftPort = "1100"
eftUser = "Admin123"
eftPassword = "Admin123!!!"
username = "user1"


EFT = client.Dispatch("SFTPComInterface.CIServer")

EFT.ConnectEx(eftServer, eftPort, 0, eftUser, eftPassword)

Sites = EFT.Sites()
num_of_sites = Sites.Count()

user_list = []
for site_number in range(1, (num_of_sites + 1)):
    site = Sites.SiteByID(site_number)
    user_list = site.GetUsers()
    for user in user_list:
        if user == username:
            site.EnableUsers(user, False)
