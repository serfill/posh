﻿function Get-PRN-PrinterLogs {
    param(
        [parameter (Mandatory = $true, Position = 1)][string]$ComputerName,
        [parameter (Mandatory = $false, Position = 2)][int]$MaxEvent = 65535,
        [parameter (Mandatory = $false, Position = 3)][switch]$Oldest
    )

    foreach ($event in Get-WinEvent -ComputerName $ComputerName -Oldest:$Oldest -MaxEvents:$MaxEvent -FilterHashtable @{LogName='Microsoft-Windows-PrintService/Operational';ID=307}) {

        $rxID = [regex]"Документ ([0-9]+)."
        $rxPort = [regex]"через порт ([0-9]+.[0-9]+.[0-9]+.[0-9]+)"
        $rxUserName = [regex]"которым владеет ([0-9a-zA-Z.]{1,})"
        $rxPrinterName = [regex]"распечатан на (.{1,}) через"
        $rxPrintSize = [regex]"Размер в байтах: ([0-9]+)."
        $rxPageCount = [regex]"Страниц напечатано: ([0-9]+)"
        $rxDocumentName = [regex]", (.{1,}), которым владеет"
        $rxComputer = [regex]" на (.{1,}),"
        
        $prop = @{
            ID = ($rxID.Match($event.Message)).Groups[1].Value
            sAMAccountName = ($rxUserName.Match($event.Message)).Groups[1].Value
            Computer = ($rxComputer.Match($event.Message)).Groups[1].Value
            Printer = ($rxPrinterName.Match($event.Message)).Groups[1].Value
            Port = ($rxPort.Match($event.Message)).Groups[1].Value
            Bytes = ($rxPrintSize.Match($event.Message)).Groups[1].Value
            Pages = ($rxPageCount.Match($event.Message)).Groups[1].Value
            Document = ($rxDocumentName.Match($event.Message)).Groups[1].Value
            DateTime = $event.TimeCreated    
        }
        New-Object -TypeName pscustomobject -Property $prop
    }
}

Function Get-PRN-Printer {
    param (
        [parameter(Mandatory = $false, Position = 1)][string]$Filter = '*',
        [parameter(Mandatory = $false, Position = 2)][string]$ComputerName = 'S18-PR01'
    )
    Get-Printer -ComputerName $ComputerName -Name $Filter | select name, location, portname, drivername | Sort-Object location
}

Function Set-PRN-PrinterRight {
    param (
        [Parameter(Mandatory=$true,Position=1,HelpMessage='Printer Name')][string]$Printer,
        [Parameter(Mandatory=$true,Position=2,HelpMessage='Server Name')][string]$ComputerName,
        [Parameter(Mandatory=$true,Position=3,ParameterSetName='Group',HelpMessage='Group Name')][string]$Group,
        [Parameter(Mandatory=$true,Position=3,ParameterSetName='User',HelpMessage='User Name')][string]$User,
        [Parameter(Mandatory=$false,Position=4,HelpMessage='Reset Access')][switch]$Reset
    )
    
    switch ($PSCmdlet.ParameterSetName) {
        "Group" { $AddSID = (Get-ADGroup -Identity $Group).SID }
        "User" {$AddSID = (Get-ADUser -Identity $User).SID}
    }

    $addSDDL = "(A;;SWRC;;;$AddSID)(A;CIIO;RC;;;$AddSID)(A;OIIO;RPWPSDRCWDWO;;;$AddSID)"
    $defSDDL = "G:SYD:(A;CIIO;RC;;;AC)(A;OIIO;RPWPSDRCWDWO;;;AC)(A;;SWRC;;;AC)(A;CIIO;RC;;;CO)(A;OIIO;RPWPSDRCWDWO;;;CO)(A;;LCSWSDRCWDWO;;;BA)(A;OIIO;RPWPSDRCWDWO;;;BA)"
    
    if ($Reset) {
        $NewSDDL = $defSDDL + $addSDDL
    } else {
        $NewSDDL = (Get-Printer -ComputerName $ComputerName -Name $Printer -Full).PermissionSDDL + $addSDDL
    }

    Set-Printer -ComputerName $ComputerName -Name $Printer -PermissionSDDL $NewSDDL -Verbose
}