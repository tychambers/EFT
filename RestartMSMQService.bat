::Stops EFT Service, then MSMQ. Starts Both again. Run as admin

NET STOP "EFT Server"
PAUSE
NET STOP "MSMQ"
PAUSE
NET START "MSMQ"
PAUSE
NET START "EFT Server"
PAUSE
