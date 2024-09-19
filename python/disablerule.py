from win32com import client

eftServer = "localhost"
eftPort = "1100"
eftUser = "Admin123"
eftPassword = "Admin123!!!"
rule_name = "Backup and Cleanup"


EFT = client.Dispatch("SFTPComInterface.CIServer")

EFT.ConnectEx(eftServer, eftPort, 1, eftUser, eftPassword)

Sites = EFT.Sites()
num_of_sites = Sites.Count()
event_rule_types = EFT.AvailableEvents

for event_rule_type in event_rule_types:
    for site_number in range(1, num_of_sites):
        site = Sites.SiteByID(site_number)
        eRules = site.EventRules(event_rule_type.type)
        for iRule in range(eRules.count()):
            objEvent = eRules.Item(iRule)
            params = objEvent.GetParams()
            name = str(params.Name)
            if name == rule_name:
                params.Enabled = "false"
                try:
                    objEvent.SetParams(params)
                    print(f"{name} has been disabled")
                except:
                    print("Something went wrong")
