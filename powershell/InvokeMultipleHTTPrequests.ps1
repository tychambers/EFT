$user = 'user1'
$pass = 'a'

$pair = "$($user):$($pass)"

$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))

$basicAuthValue = "Basic $encodedCreds"

$Headers = @{
    Authorization = $basicAuthValue
}
foreach ($i in 1..100){
Invoke-WebRequest -Uri 'https://localhost' -Headers $Headers}