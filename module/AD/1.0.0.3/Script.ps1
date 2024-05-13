$File = $PSScriptRoot + "\Config.ps1"
. $File > $null

if (!($ADDN)) {
    $ADDN = (Get-ADDomain).DistinguishedName
}

if (!($NUDN)) {
    Write-Host "Defalut value of Distinguished path for NEW users: OU=Users,OU=ABAKAN,$ADDN" -BackgroundColor DarkGreen
    $NUDN = Read-Host -Prompt "Enter new name or press Enter for accept automatic value" 
    if ($NUDN.Length -eq 0) {
        $NUDN = "OU=Users,OU=ABAKAN," + $ADDN
    }
}

if (!($RMDN)) {
    Write-Host "Defalut value of Distinguished path for DELETED users: OU=Users,OU=Disabled,OU=ABAKAN,$ADDN" -BackgroundColor DarkGreen
    $RMDN = Read-Host -Prompt "Enter new name or press Enter for accept automatic value" 
    if ($RMDN.Length -eq 0) {
        $RMDN = "OU=Users,OU=Disabled,OU=ABAKAN," + $ADDN
    }
}

'$ADDN="'+$ADDN+"""" >> $File
'$NUDN="'+$NUDN+"""" >> $File
'$RMDN="'+$RMDN+"""" >> $File
