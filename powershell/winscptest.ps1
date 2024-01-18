try
{
    # Load WinSCP .NET assembly
    Add-Type -Path "C:\Users\tchambers\Desktop\Scripts\winscp_dll\WinSCP-6.1.2-Automation\WinSCPnet.dll"
 
    # Setup session options
    $sessionOptions = New-Object WinSCP.SessionOptions -Property @{
        Protocol = [WinSCP.Protocol]::Sftp
        HostName = "10.0.1.11"
        UserName = "user1"
        Password = "a"
        SshHostKeyFingerprint = "ssh-rsa 4096 CoskaQblsblo++HRHm1SNEhbW2ue5g/R5ETFj8cVxNw"
    }
 
    $session = New-Object WinSCP.Session
 
    try
    {
        # Connect
        $session.Open($sessionOptions)
 
        # Upload files
        $transferOptions = New-Object WinSCP.TransferOptions
        $transferOptions.TransferMode = [WinSCP.TransferMode]::Binary
 
        $transferResult =
            $session.PutFiles("C:\Users\tchambers\Desktop\test\*.txt", "/", $False, $transferOptions)
 
        # Throw on any error
        $transferResult.Check()
 
        # Print results
        foreach ($transfer in $transferResult.Transfers)
        {
            Write-Host "Upload of $($transfer.FileName) succeeded"
        }
    }
    finally
    {
        # Disconnect, clean up
        $session.Dispose()
    }
 
    exit 0
}
catch
{
    Write-Host "Error: $($_.Exception.Message)"
    exit 1
}