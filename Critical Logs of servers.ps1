 ## Thank you for Downloading ##
 ## Tested and used please use Administrator credentials for results.##
 ##$$ Thanks & Regards, Mahesh Pawar (IT) $$##
$logs = "Application", "System"
$yesterday = (get-date) - (New-TimeSpan -day 1)
$s = "C:\ServerList.txt"
foreach ($server in Get-Content $s)
   {$server; get-winevent -logname System -computername $server | where {$_.LevelDisplayName -eq "Critical"}}
  
   