#Script for Get User List ap per created date
$Start = Get-Date -Day 01 -Month 06 -Year 2016 -Hour 00
$End = Get-Date -Day 03 -Month 02 -Year 2017 -Hour 23 -Minute 59
Get-ADUser -SearchBase “OU=test,DC=test,DC=dc,DC=net” -Filter * -Properties | ? { ($_.whenCreated -gt $Start) -and ($_.whenCreated -le $End) } | Format-Table Name,WhenCreated,DistinguishedName -Autosize -Wrap | Out-File D:\UserData\Desktop\1.txt