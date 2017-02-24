try
{
   #script for move Temp Data 
$time = Get-Date
Write-Host "Script start time $time " | Out-File d:\movelog.txt -Append
$Defaultpath = "D:\old data\datashare\"

$backupIT = New-Item -Path $Defaultpath -name (get-date -f MM-dd-yyyy_HH_mm_ss) -ItemType directory
$IT = New-Item -path $backupIT -name "ASIN Temp Scan IT" -ItemType directory
$Finance = New-Item -path $backupIT -name "ASIN Temp Scan Finance" -ItemType directory
$Production = New-Item -path $backupIT -name "ASIN Temp Scan Production" -ItemType directory
$Purchase = New-Item -path $backupIT -name "ASIN Temp Scan Purchase" -ItemType directory
$Reimbursement = New-Item -path $backupIT -name "ASIN Temp Scan Reimbursement" -ItemType directory
$Sales = New-Item -path $backupIT -name "ASIN Temp Scan Sales" -ItemType directory
$Telesales =New-Item -path $backupIT -name "ASIN Temp Scan Telesales" -ItemType directory
$Accentiv =New-Item -path $backupIT -name "ASIN Temp Scan Accentiv" -ItemType directory
$CEO =New-Item -path $backupIT -name "ASIN Temp Scan CEO Office" -ItemType directory
$Contact =New-Item -path $backupIT -name "ASIN Temp Scan Contact Center" -ItemType directory

$comIT = Get-ChildItem "D:\Datashare\ASIN Temp Scan IT\*" -Recurse | Where-Object {$_.LastWriteTime -le (get-date).AddDays(-2)}|move -Destination $IT -ErrorAction Continue
$comfin = Get-ChildItem "D:\Datashare\ASIN Temp Scan Finance\*" -Recurse | Where-Object {$_.LastWriteTime -le (get-date).AddDays(-2)}|move -Destination $Finance -ErrorAction Continue
$comprod = Get-ChildItem "D:\Datashare\ASIN Temp Scan Production\*" -Recurse | Where-Object {$_.LastWriteTime -le (get-date).AddDays(-2)}|move -Destination $Production -ErrorAction Continue
$compurch = Get-ChildItem "D:\Datashare\ASIN Temp Scan Purchase\*" -Recurse | Where-Object {$_.LastWriteTime -le (get-date).AddDays(-2)}|move -Destination $Purchase -ErrorAction Continue
$comrem = Get-ChildItem "D:\Datashare\ASIN Temp Scan Reimbursement\*" -Recurse | Where-Object {$_.LastWriteTime -le (get-date).AddDays(-2)}|move -Destination $Reimbursement -ErrorAction Continue
$comsales = Get-ChildItem "D:\Datashare\ASIN Temp Scan Sales\*" -Recurse | Where-Object {$_.LastWriteTime -le (get-date).AddDays(-2)}|move -Destination $Sales -ErrorAction Continue
$comteles = Get-ChildItem "D:\Datashare\ASIN Temp Scan Telesales\*" -Recurse | Where-Object {$_.LastWriteTime -le (get-date).AddDays(-2)}|move -Destination $Telesales -ErrorAction Continue
$comAcce = Get-ChildItem "D:\Datashare\ASIN Temp Scan Accentiv\*" -Recurse | Where-Object {$_.LastWriteTime -le (get-date).AddDays(-2)}|move -Destination $Accentiv -ErrorAction Continue
$comCon = Get-ChildItem "D:\Datashare\ASIN Temp Scan Contact Center\*" -Recurse | Where-Object {$_.LastWriteTime -le (get-date).AddDays(-2)}|move -Destination $Contact -ErrorAction Continue

}
catch [System.Net.WebException],[System.Exception]
{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
  Send-MailMessage -From Sa-asi-espada-in@edenred.com -To mahesh.pawar@edenred.com -Cc ERIN-InfrastructureTeam-IN@edenred.com -Subject "File server Folder Move Error" -SmtpServer 172.30.117.51 -Body "Error Occured  $FailedItem. ERROR:- $ErrorMessage"

}
finally
{
    send-Mailmessage -from sa-asi-espada-in@edenred.com -to mahesh.pawar@edenred.com -Cc ERIN-InfrastructureTeam-IN@edenred.com -subject "File Server Folder Successful" -SmtpServer 172.30.117.51 -body "Backup Successful" 
    Write-Host "Script End time $time " | Out-File d:\movelog.txt -Append
}