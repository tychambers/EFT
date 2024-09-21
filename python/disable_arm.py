from win32com import client

eftServer = "localhost"
eftPort = "1100"
eftUser = "Admin123"
eftPassword = "Admin123!!!"


EFT = client.Dispatch("SFTPComInterface.CIServer")

EFT.ConnectEx(eftServer, eftPort, 0, eftUser, eftPassword)

EFT.EnableARM = False
EFT.ApplyChanges()


