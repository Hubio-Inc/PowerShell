#How To Get Stats From CenturyLink – Shorthand
#v1.1 – By Sean Davis

#Region Authentication

#Build Auth Token
$Auth = @{
 username = "YOUR_ACCOUNT_USERNAME"
 password = "YOUR_ACCOUNT_PASSWORD"
}
$AuthToken = $Auth | ConvertTo-JSON

#Init Headers
$Headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"

#Login And Receive Token
$LogonUrl = "https://api.ctl.io/v2/authentication/login"
$LogonResponse = Invoke-RestMethod -Method Post -Headers $Headers -URI $LogonUrl -Body $AuthToken -ContentType "application/json" -SessionVariable "Session"

#Format The Bearer Token
$Bearer = $LogonResponse.bearerToken
$BearerToken = " Bearer " + $Bearer

#Add The Token to The Header To Be Used For All Future Requests
$Headers.Add("Authorization",$BearerToken)

#Make The Session Global For The Persistence Of The User Session Or Two Weeks, Whichever Comes First
$Session = $global:Session

#endregion


#Region Main

#Go Get The Server Stats For A Single Server, For All Servers, Insert Loop Here. I can't do all the work for you :)

#Set Timespan and Interval
#This Is Taking The Max Aggregate of 14 Days And Sampling At 1 Hour Intervals.
#You Would Be Better Served To Do Sample Intervals Linked To How Often The Cron For Inventory Runs And Then Sample a Single Interval For Obvious Performance Reasons
$StartDate = $($(Get-Date).AddDays(-13)).ToShortDateString()
$EndDate = $(Get-Date).ToShortDateString()
$SampleInterval = "00:01:00:00"

#Build API Request
$AccountAlias = "" #Your Account Alias, See API Docs
$ServerID = "ServerName" #Server Name, See API Docs
$APIURL = "https://api.ctl.io/v2/servers/$AccountAlias/$ServerID/statistics?type=hourly&start=$StartDate&end=$EndDate&sampleInterval=$SampleInterval"
$ServerStats = Invoke-RestMethod -Method GET -Headers $Headers -URI $APIURL -SessionVariable "Session"

#Show Server Statistics Results
$ServerStats.Stats | FT -Auto

#endregion
