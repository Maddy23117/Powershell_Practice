Function Get-ComputerInfo
{
 <#
        .DESCRIPTION
        Check the computer Information

        .PARAMETER ComputerName
        Specify the computername(s)
             
        .EXAMPLE
        Get-DiskSizeInfo
        
         .EXAMPLE
        Get-ComputerInfo -ComputerName S1,S2
             
		on the Computers S1 and S2

		.EXAMPLE
        Get-Content -Path "c:\computer.txt" | Get-ComputerInfo 

        Get the drive(s), Disk(s) space, and the FreeSpace (GB and Percentage)
		for each computers listed in Computers.txt

        .NOTES
    	NAME  : Get-ComputerInfo
		AUTHOR: Abhinav Joshi
		EMAIL : Abhinav.joshi1293@hotmail.com
		DATE  : 29/12/2015
	#>
 
    [CmdletBinding()]
    PARAM ([Parameter(Mandatory = $true,
    ValueFromPipeline=$True,
    HelpMessage="Enter computername ")]
    [string[]]$ComputerName = $env:COMPUTERNAME)

Begin
{
"####################Connecting TO $ComputerName########################" `
}#Setup
Process {
 Foreach($computer in $computername){

Write-output ""
Write-output ""
Write-output "             $computer Information "

#Checking Computer Online or Not 
if(Test-Connection $computer -Count 3 -Quiet -ErrorAction SilentlyContinue ){
   try
   {

    Write-Verbose -Message "$computer - Collecting Information From system" 
     # Computer computer
    $ComputerSystem = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $computer

    # Operating System
    Write-Verbose -Message "$computer - Collecting Operating System INFO"
    $OperatingSystem = Get-WmiObject -Class win32_OperatingSystem -ComputerName $computer

    # BIOS
    Write-Verbose -Message "$computer - Collecting BIOS INFO"
    $Bios = Get-WmiObject -class win32_BIOS -ComputerName $computer

    #Username
    Write-Verbose -Message "$computer - collecting Username"
    $user = Get-WMIObject -class Win32_ComputerSystem -ComputerName $Computer

    #hotfix info
    Write-Verbose -Message "$computer - Collecting Hotfix"
    $hotfix = Get-WmiObject -Class win32_quickfixengineering | Select-Object "hotfixid","Description","installedon" | ft -AutoSize


    #Disk INFo
    Write-Verbose -Message "ComputerName: $computer - Getting Disk(s) information"

    #Set All parameters set for the Query 
    $param = @{'computername' = $computer;
                'Class'="Win32_LogicalDisk";
                'Filter' = "DriveType=3";
                'ErrorAction'='SilentlyContinue'}
    #Running Query on current computer 
    
     $disks = Get-WmiObject @param

    #try OK variable 
    $ok = $true
    
    Write-Verbose -Message "ComputerName: $computer - All information Collected"
    
   }#try

   catch 
   {

   switch ($_)
                {
                    { $_.Exception.ErrorCode -eq 0x800706ba } `
                        { $err = 'Unavailable (Host Offline or Firewall)'; 
                            break; }
                    { $_.CategoryInfo.Reason -eq 'UnauthorizedAccessException' } `
                        { $err = 'Access denied (Check User Permissions)'; 
                            break; }
                    default { $err = $_.Exception.Message }
                }

                Write-Warning "$computer - $err"
 }
if ($ok){
Write-Verbose "$computername - preparing report"

  # Prepare Output
    $Properties = @{
        ComputerName = $Computer
        Manufacturer = $ComputerSystem.Manufacturer
        Model = $ComputerSystem.Model
        OperatingSystem = $OperatingSystem.Caption
        OperatingSystemVersion = $OperatingSystem.Version
        SerialNumber = $Bios.SerialNumber
        'physical memory'=($ComputerSystem.TotalPhysicalMemory/1GB).ToString('N') +" GB"
        'Login User' = $user.username
        }
         # Output Information
New-Object -TypeName PSobject -Property $Properties 


 foreach ($disk in $Disks) {
					
# Prepare for each disk 
Write-Verbose -Message "ComputerName: $Computer - $($Disk.deviceid)"
$output1 =	 	@{'ComputerName'=$computer;
                	'Drive'=$disk.deviceid;
					'FreeSpace(GB)'=("{0:N2}" -f($disk.freespace/1GB));
					'Size(GB)'=("{0:N2}" -f($disk.size/1GB));
					'PercentFree'=("{0:P2}" -f(($disk.Freespace/1GB) / ($disk.Size/1GB)))}



  $R1 = New-Object -TypeName PSObject -Property $output1					
  # Output the disk information
  Write-Output -InputObject $R1 | ft -AutoSize
}

Write-Output $hotfix
 }
else{

Write-Error "Computer not Found" -ErrorAction SilentlyContinue
 Write-Output "Computer Not Online"
Add-Content -Path .\Error.txt -Value $Error
    }
  }
}

}
}