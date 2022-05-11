<#
Title:    LogMD_Triage.ps1
Purpose:  Runs LogMD log harvestsing and send data to collection point
Author:   Elnao
#>

##Decompress Appropriate Master Digest File
Set-Location -Path C:\elnao\LOG-MD

$CitrixXAMD = "C:\elnao\LOG-MD\MD-Citrix-XA.zip"
$CitrixXDMD = "C:\elnao\LOG-MD\MD-Citrix-XD.zip"
$W10MD = "C:\elnao\LOG-MD\MD-W101909.zip"
$WS2012MD = "C:\elnao\LOG-MD\MD-WS2012.zip"
$WS2016MD = "C:\elnao\LOG-MD\MD-WS2016.zip"

$XAMDExists = Test-Path $CitrixXAMD
$XDMDExists = Test-Path $CitrixXDMD
$W10MDExists = Test-Path $W10MD
$WS2012MDExists = Test-Path $WS2012MD
$WS2016MDExists = Test-Path $WS2016MD

IF ($XAMDExists -eq $True) {Expand-Archive -Force -Path $CitrixXAMD -DestinationPath C:\elnao\LOG-MD}
ElseIF ($XDMDExists -eq $True) {Expand-Archive -Force -Path $CitrixXDMD -DestinationPath C:\elnao\LOG-MD}
ElseIF ($W10MDExists -eq $True) {Expand-Archive -Force -Path $W10MD -DestinationPath C:\elnao\LOG-MD}
ElseIF ($WS2012MDExists -eq $True) {Expand-Archive -Force -Path $WS2012MD -DestinationPath C:\elnao\LOG-MD}
ElseIF ($WS2016MDExists -eq $True) {Expand-Archive -Force -Path $WS2016MD -DestinationPath C:\elnao\LOG-MD}

#Run Log-MD Log Harvest.  This operation takes a short time to run.  
Set-Location -Path C:\elnao\LOG-MD
./LOG-MD-Pro.exe -ne -3 -ar -proc -rs -se -s -md

#Compress Existing Baselines and Reports
$compressdate = (Get-Date -Format FileDateTimeUniversal)
$filename = $env:COMPUTERNAME + "-LOG-MD-Harvest-Reports-" + $compressdate + ".zip"
Compress-Archive -path c:\elnao\log-md\*.csv -DestinationPath c:\elnao\$filename
Compress-Archive -path c:\elnao\log-md\*.txt -Update -DestinationPath c:\elnao\$filename

#Copy Log-MD Harvest Reports off of computer for analysis
Copy-Item "c:\elnao\$filename" \\fileserver\hashes\$filename

################################################################

#Run Log-MD Comparisons.  This operation takes a longer time to collect.  It could take an hour or more. 
Set-Location -Path C:\elnao\LOG-MD
./LOG-MD-Pro.exe -ne -rc -hc -md

#Delete Master Digest File
Remove-Item .\MasterDigest.txt
Remove-Item .\Whitelist_AutoRuns.txt

#Compress Log-MD Comparison Reports 
$compressdate = (Get-Date -Format FileDateTimeUniversal)
$filename2 = $env:COMPUTERNAME + "-LOG-MD-Comparison-Reports-" + $compressdate + ".zip"
Compress-Archive -path c:\elnao\log-md\Reg*.* -DestinationPath c:\elnao\$filename2
Compress-Archive -path c:\elnao\log-md\Hash*.* -update -DestinationPath c:\elnao\$filename2

#Copy Log-MD Comparison Reports off of computer for analysis
Copy-Item "c:\elnao\$filename2" \\fileserver\hashes\$filename2
