<# ********** Get Java Versions from Host *********

    07/23/2020 - Jason Franklin
    #Script to get Java versions on multiple hosts

************************************************* #>

#Get credentials for service account login
#Change "ServiceAccountName" with desired service account
#You will be prompted for the ServiceAccount password of the remote hosts you are trying reach

$cred = Get-Credential ServiceAccount

#Change this to the path where you placed the script and the .txt file

$path = 'C:\Users\YourDirectory'

#Get content of server list file

$servers = get-content $path\GetJavaVersions.txt

Foreach ($hostName in $servers) {

$sess = New-PSSession -Credential $cred -ComputerName $hostname
Invoke-Command -session $sess -scriptblock {

# Check java versions from registry
$UninstallReg = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
(gp $UninstallReg).DisplayName -like '*Java*'

#Set paths below for where you have Java setup. Example (C:,D:,E:,F: etc.)
$OracleDir = '\\?\E:\Oracle'
if (-not (Test-Path $OracleDir -PathType Container)) {
    $OracleDir = '\\?\F:\Oracle'
    if (-not (Test-Path $OracleDir -PathType Container)) { throw 'Oracle directory not found, this script expects either an E:\Oracle or F:\Oracle folder to traverse for the search pattern.' }
}

}
}

# Define search criteria - strings seperated by vertical pipe '|'
$SearchStr = "JAVA_HOME=C|set JRE_HOME=C|SET JAVA_HOME_LOCATION=C|JAVA_HOME_1_|set SUN_JAVA_HOME=C|set DEFAULT_SUN_JAVA_HOME=C|JavaHome=C|
set BEA_JAVA_HOME=C|set DEFAULT_BEA_JAVA_HOME=C|C\:\\Program Files\\Java|C\\\:\\\\Program Files\\\\Java"

Get-ChildItem -LiteralPath $OracleDir -Recurse | Where-Object { $_.Name -like "*.properties*" -or $_.Name -like "*.config*" -or $_.Name -like "*.bat*" -or $_.Name -like "*.cmd*" -or $_.Name -like "*.py*" } |
Select-String $SearchStr | Select-Object Filename, LineNumber, Line, Path | Export-Csv -Path C:\Users\jfrank3\Scripts\Java.csv -NoTypeInformation

#Display the sessions
$servers | Sort ServerName 
