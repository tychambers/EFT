#create event rule

######################################################################################

$baseURL = "http://localhost:4450/admin"
$AdminUser = "Admin123"
$password = "Admin123!!!"
$site = "MySite"

#######################################################################################

# Only to ignore certificates errors
add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;

        public class IDontCarePolicy : ICertificatePolicy {
        public IDontCarePolicy() {}
        public bool CheckValidationResult(
            ServicePoint sPoint, X509Certificate cert,
            WebRequest wRequest, int certProb) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = new-object IDontCarePolicy 
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12


# authentication
$authBody = "{""userName"": ""$AdminUser"", ""password"": ""$password"", ""authType"": ""EFT""}"
$auth = Invoke-RestMethod -Uri "$baseURL/v1/authentication" -Method 'POST' -Body $authBody

$authToken = $auth.authToken
$authHeader = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$authHeader.Add("Authorization", "EFTAdminAuthToken $authToken")

#get site info
$siteList = Invoke-RestMethod -Uri "$baseURL/v2/sites" -Method 'GET' -Headers $authHeader

#resolves SiteID by Site Name
foreach ($x in $siteList.data){
    if ($site -eq $x.attributes.name)
        {$id = $siteList.data.IndexOf($x)}}

$siteID = $siteList.data[$id].id

$update = 
'{
    "data": {
  "id": "80568ef8-e2d2-4741-bbc2-806f45cc4cbf",
  "attributes": {
      "info": {
        "Description": "Execute a specified action one time or repeat at a specified interval.",
        "Enabled": true,
        "Folder": "00000000-0000-0000-0000-000000000000",
        "Name": "testrule1",
        "Next": "00000000-0000-0000-0000-000000000000",
        "Remote": false,
        "Type": "Timer"
        },
      "statements": {
        "StatementsList": [
          {
            "ActionStatement": {
              "Action": {
                "MailAction": {
                  "AddressesBCC": [],
                  "AddressesCC": [],
                  "AddressesTO": [
                    "test@globalscape.com"
                  ],
                  "Attach": "",
                  "CopyToClient": false,
                  "From": "",
                  "Subject": "Globalscape EFT Enterprise Notification: %EVENT.NAME%",
                  "Template": "This message was sent to you automatically by Globalscape EFT Enterprise on the following event: %EVENT.NAME%.\r\nServer Local Time: %EVENT.TIME%\r\n%EVENT.NAME%"
                }
              },
              "IfFailedActions": [
                {
                  "StopAction": {
                    "Enabled": false,
                    "Result": "StopThisRule"
                  }
                }
              ]
            },
            "ConditionStatement": {
              "Conditions": [],
              "ElseAttachedStatements": [],
              "IfAttachedStatements": [],
              "Operator": "Or"
            },
            "LoopDatasetStatement": {
              "Params": {
                "DatasetName": "",
                "EndLoopRow": 0,
                "OrderingColumn": "",
                "SortOrder": "Original",
                "StartLoopRow": 0,
                "UseEndLoopRow": false,
                "UseStartLoopRow": false
              },
              "Statements": []
            },
            "Type": "Action"
          }
        ]
      },
      "trigger": {
        "TimerParams": {
          "DailyInfo": {
            "DayPeriod": 1,
            "EveryWeekDay": true
          },
          "EndDateEnabled": false,
          "EndDateTime": 1597772631,
          "EndTimeEnabled": false,
          "HolidayCalendarID": "00000000-0000-0000-0000-000000000000",
          "MonthlyInfo": {
            "DayPeriod": 1,
            "MonthPeriod": 1,
            "RelativeDay": "First",
            "UseFixedDayIndexInMonth": true,
            "Weekday": "Sunday"
          },
          "Recurrence": "Daily",
          "RepeatEnabled": false,
          "RepeatPattern": "Hours",
          "RepeatRate": 1,
          "RundayCalendarID": "00000000-0000-0000-0000-000000000000",
          "StartDateTime": 1597772631,
          "WeeklyInfo": {
            "WeekDayFlags": 1,
            "WeekPeriod": 1
          },
          "YearlyInfo": {
            "DayPeriod": 1,
            "Month": "January",
            "RelativeDay": "First",
            "UseFixedDayIndexInFixedMonth": true,
            "Weekday": "Sunday"
          }
         }
    }
  }
}
}'

$update = $update | ConvertFrom-Json
$update = $update | ConvertTo-Json -Depth 10

$post_eventrule = Invoke-RestMethod -Uri "$baseURL/v2/sites/$siteID/event-rules" -Method 'POST' -Headers $authHeader -Body $update