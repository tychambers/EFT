#I recommend creating the rule in EFT then exporting the .json file
#copy and paste json contents to use as $update

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
  "data": [
    {
      "attributes": {
        "info": {
          "Description": "Execute a specified action one time or repeat at a specified interval.",
          "Enabled": false,
          "Folder": "00000000-0000-0000-0000-000000000000",
          "Name": "test rule",
          "Next": "446aa15c-e2bb-4514-ae91-8cef45518621",
          "Remote": false,
          "Type": "Timer",
          "apiVersion": "v2",
          "eventRuleVersion": "416"
        },
        "statements": {
          "StatementsList": [
            {
              "ActionStatement": {
                "Action": {
                  "UploadAction": {
                    "ConnectionProfileGUID": "6c1e9dfc-6f86-4538-9e4b-7147f50f023a",
                    "LocalPath": "C:\\Users\\tchambers\\Desktop\\awetest\\dummy file.txt",
                    "RemotePath": "/%SOURCE.FILE_NAME%",
                    "RemoveSource": false,
                    "TransferSettings": {
                      "Connection": {
                        "CertificateSettings": {
                          "CertId": "00000000-0000-0000-0000-000000000000",
                          "CertPath": "",
                          "KeyPath": "",
                          "Passphrase": "UpKUJq1sD4Yfb1Hz8ZFiRw=="
                        },
                        "EnableAutoLogin": false,
                        "Host": "",
                        "Password": "UpKUJq1sD4Yfb1Hz8ZFiRw==",
                        "Port": "21",
                        "Protocol": "FTP",
                        "TrustedPubKey": "",
                        "User": ""
                      },
                      "Transfer": {
                        "ASCIIFileExts": [
                          "TXT",
                          "INF",
                          "HTML",
                          "HTM"
                        ],
                        "ClearCommandChannel": false,
                        "ClearDataChannel": false,
                        "ConnectionTimeout": 30,
                        "CustomProxyCommands": [],
                        "DataPortMode": "AUTO",
                        "DelayBetweenRetries": 30,
                        "HomeIP": "0.0.0.0",
                        "HostName": "",
                        "MaxConcurrentThreads": 1,
                        "NumberOfConnectionRetries": 0,
                        "PASVPortMax": 65535,
                        "PASVPortMin": 0,
                        "Password": "UpKUJq1sD4Yfb1Hz8ZFiRw==",
                        "Port": 21,
                        "PreserveLocalTimeStamp": false,
                        "PreserveRemoteTimeStamp": false,
                        "ProxySeparator": "@",
                        "ProxySubType": 0,
                        "ProxyType": "FTP",
                        "SOCKSSettings": {
                          "Auth": false,
                          "HostName": "",
                          "Password": "UpKUJq1sD4Yfb1Hz8ZFiRw==",
                          "Port": 1080,
                          "Type": "None",
                          "Use": false,
                          "UserName": ""
                        },
                        "TransferEncoding": "AutoDetect",
                        "UseProxy": false,
                        "UserName": "",
                        "ValidateFileIntegrity": false
                      },
                      "TransferAdditional": {
                        "DeleteSourceIfMoveSkipped": true,
                        "OverwriteType": "Overwrite",
                        "PrePostCommandSettings": {
                          "ContinueOnFailPost": false,
                          "ContinueOnFailPre": false,
                          "PostCommandArg": "",
                          "PostCommandArgDelimiter": 32,
                          "PostCommandType": "None",
                          "PreCommandArg": "",
                          "PreCommandType": "None"
                        },
                        "RenameDestinationFile": false,
                        "RenameDestinationFileTo": "",
                        "SyncSettings": {
                          "SyncDeleteFileIfNotPresent": false,
                          "SyncDirectionType": "MirrorRemote",
                          "SyncFolders": false,
                          "SyncIncludeSubfolders": false,
                          "SyncOverwriteType": "Overwrite"
                        },
                        "TreatMissingSourceAsSuccess": false
                      }
                    }
                  }
                },
                "IfFailedActions": [
                  {
                    "StopAction": {
                      "Enabled": true,
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
            },
            {
              "ActionStatement": {
                "Action": {
                  "DownloadAction": {
                    "ConnectionProfileGUID": "00000000-0000-0000-0000-000000000000",
                    "LocalPath": "C:\\Users\\tchambers\\Desktop\\aws test\\",
                    "RemotePath": "C:\\Users\\tchambers\\Desktop\\awetest\\dummy file2.txt",
                    "RemoveSource": false,
                    "TransferSettings": {
                      "Connection": {
                        "CertificateSettings": {
                          "CertId": "00000000-0000-0000-0000-000000000000",
                          "CertPath": "",
                          "KeyPath": "",
                          "Passphrase": "UpKUJq1sD4Yfb1Hz8ZFiRw=="
                        },
                        "EnableAutoLogin": false,
                        "Host": "",
                        "Password": "UpKUJq1sD4Yfb1Hz8ZFiRw==",
                        "Port": "0",
                        "Protocol": "Local",
                        "TrustedPubKey": "",
                        "User": ""
                      },
                      "Transfer": {
                        "ASCIIFileExts": [
                          "TXT",
                          "INF",
                          "HTML",
                          "HTM"
                        ],
                        "ClearCommandChannel": false,
                        "ClearDataChannel": false,
                        "ConnectionTimeout": 30,
                        "CustomProxyCommands": [],
                        "DataPortMode": "AUTO",
                        "DelayBetweenRetries": 30,
                        "HomeIP": "0.0.0.0",
                        "HostName": "",
                        "MaxConcurrentThreads": 1,
                        "NumberOfConnectionRetries": 0,
                        "PASVPortMax": 65535,
                        "PASVPortMin": 0,
                        "Password": "UpKUJq1sD4Yfb1Hz8ZFiRw==",
                        "Port": 21,
                        "PreserveLocalTimeStamp": false,
                        "PreserveRemoteTimeStamp": false,
                        "ProxySeparator": "@",
                        "ProxySubType": 0,
                        "ProxyType": "FTP",
                        "SOCKSSettings": {
                          "Auth": false,
                          "HostName": "",
                          "Password": "UpKUJq1sD4Yfb1Hz8ZFiRw==",
                          "Port": 1080,
                          "Type": "None",
                          "Use": false,
                          "UserName": ""
                        },
                        "TransferEncoding": "UTF8",
                        "UseProxy": false,
                        "UserName": "",
                        "ValidateFileIntegrity": false
                      },
                      "TransferAdditional": {
                        "DeleteSourceIfMoveSkipped": true,
                        "OverwriteType": "Overwrite",
                        "PrePostCommandSettings": {
                          "ContinueOnFailPost": false,
                          "ContinueOnFailPre": false,
                          "PostCommandArg": "",
                          "PostCommandArgDelimiter": 32,
                          "PostCommandType": "None",
                          "PreCommandArg": "",
                          "PreCommandType": "None"
                        },
                        "RenameDestinationFile": false,
                        "RenameDestinationFileTo": "",
                        "SyncSettings": {
                          "SyncDeleteFileIfNotPresent": false,
                          "SyncDirectionType": "MirrorRemote",
                          "SyncFolders": false,
                          "SyncIncludeSubfolders": false,
                          "SyncOverwriteType": "Overwrite"
                        },
                        "TreatMissingSourceAsSuccess": false
                      }
                    }
                  }
                },
                "IfFailedActions": [
                  {
                    "StopAction": {
                      "Enabled": true,
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
            },
            {
              "ActionStatement": {
                "Action": {
                  "CompressAction": {
                    "Action": "Compress",
                    "AdvancedOptions": 0,
                    "CompressionLevel": 4,
                    "CompressionMethod": "DEFLATE",
                    "DestSpec": "C:\\Users\\tchambers\\Desktop\\aws test\\%SOURCE.FILE_NAME%",
                    "Encrypt": false,
                    "Format": "Zip",
                    "IncludeSubFolders": false,
                    "OverwriteBehavior": "Never",
                    "OverwriteReadOnlyFiles": false,
                    "Password": "UpKUJq1sD4Yfb1Hz8ZFiRw==",
                    "SourceSpec": "C:\\Users\\tchambers\\Desktop\\awetest\\%SOURCE.FILE_NAME%"
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
            "EndDateTime": 1700844397,
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
            "StartDateTime": 1700844397,
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
      },
      "id": "4bffbbba-6d5f-4917-a3e3-036b6e09f98d",
      "relationships": {
        "ConnectionProfiles": [
          {
            "id": "6c1e9dfc-6f86-4538-9e4b-7147f50f023a",
            "name": "test"
          }
        ]
      },
      "type": "eventRule"
    }
  ]
}'

$update = $update | ConvertFrom-Json
$update = $update | ConvertTo-Json -Depth 10

$post_eventrule = Invoke-RestMethod -Uri "$baseURL/v2/sites/$siteID/event-rules" -Method 'POST' -Headers $authHeader -Body $update
