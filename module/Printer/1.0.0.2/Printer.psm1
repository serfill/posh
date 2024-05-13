function Get-PRN-PrinterLogs {
    <#
    .SYNOPSIS
        Получение логов с сервера печати.
    .DESCRIPTION
        Получение логов с сервера печати.
    .PARAMETER ComputerName
        Имя компьютера. Netbios или FQDN.
    .PARAMETER MaxEvent
        Максимальное количество результатирующих сообщений.
    .PARAMETER Oldest
        Сортировка событий, если флаг отмечен, сортировка начинается со самого старого события.
    .EXAMPLE
        PS C:\> Get-PRN-PrinterLogs -ComputerName srv -MaxEvent 100 -Oldest
        Получение 100 первых событий на компьютере srv
    #>
    param(
        [parameter (Mandatory = $true, Position = 1)][string]$ComputerName,
        [parameter (Mandatory = $false, Position = 2)][int]$MaxEvent = 65535,
        [parameter (Mandatory = $false, Position = 3)][switch]$Oldest
    )

    foreach ($event in Get-WinEvent -ComputerName $ComputerName -Oldest:$Oldest -MaxEvents:$MaxEvent -FilterHashtable @{LogName = 'Microsoft-Windows-PrintService/Operational'; ID = 307 }) {

        $rxID = [regex]"Документ ([0-9]+)."
        $rxPort = [regex]"через порт ([0-9]+.[0-9]+.[0-9]+.[0-9]+)"
        $rxUserName = [regex]"которым владеет ([0-9a-zA-Z.]{1,})"
        $rxPrinterName = [regex]"распечатан на (.{1,}) через"
        $rxPrintSize = [regex]"Размер в байтах: ([0-9]+)."
        $rxPageCount = [regex]"Страниц напечатано: ([0-9]+)"
        $rxDocumentName = [regex]", (.{1,}), которым владеет"
        $rxComputer = [regex]" на (.{1,}),"
        
        $prop = @{
            ID             = ($rxID.Match($event.Message)).Groups[1].Value
            sAMAccountName = ($rxUserName.Match($event.Message)).Groups[1].Value
            Computer       = ($rxComputer.Match($event.Message)).Groups[1].Value
            Printer        = ($rxPrinterName.Match($event.Message)).Groups[1].Value
            Port           = ($rxPort.Match($event.Message)).Groups[1].Value
            Bytes          = ($rxPrintSize.Match($event.Message)).Groups[1].Value
            Pages          = ($rxPageCount.Match($event.Message)).Groups[1].Value
            Document       = ($rxDocumentName.Match($event.Message)).Groups[1].Value
            DateTime       = $event.TimeCreated    
        }
        New-Object -TypeName pscustomobject -Property $prop
    }
}

Function Get-PRN-Printer {
    <#
    .SYNOPSIS
        Получение списка принтеров с сервера печати.
    .DESCRIPTION
        Получение списка принтеров с сервера печати.
    .PARAMETER Filter
        Фильтр по принтерам, поддерживает маски замещения символов.
    .PARAMETER ComputerName
        Имя компьютера. DNS или FQDN.
    .PARAMETER OpenUrl
        Открывает WEB-сайт с адресом порта. Необходимо отфильтровать только одно значение.
    .PARAMETER Property
        Свойства объекта. Полный список свойств *.
    .EXAMPLE
        PS C:\> Get-PRN-Printer -ComputerName srv
        Выводит полный список принтеров с сервера srv. Список формируется с учетом прав к принтеру. Отображает список в контексте текущего пользователя
    .EXAMPLE
        PS C:\> Get-PRN-Printer -ComputerName srv -Filter *Printer01 -OpenUrl
        Выводит на экран параметры принтера, заканчивающегося на Printer01 с сервера srv. При этом в браузере Google chrome открывается веб сайт http://ip_port
    #>
    param (
        [parameter(Mandatory = $false, Position = 1)][string]$Filter = '*',
        [parameter(Mandatory = $false, Position = 2)][string]$ComputerName = 'S18-PR01',
        [Parameter(Mandatory = $false, Position = 3, HelpMessage = 'Open URL')][switch]$OpenUrl,
        [Parameter(Mandatory = $false, Position = 4, HelpMessage = 'Property List')][string[]]$Property = @('name', 'location', 'portname', 'drivername')
    )
    $Printer = Get-Printer -ComputerName $ComputerName -Name $Filter | Select-Object -Property $Property
    $Printer

    if ($OpenUrl) {
        if (($Printer | Measure-Object).Count -eq 1) {
            Start-Process -FilePath "chrome" -ArgumentList ("http://" + $Printer.PortName)
        }
        else {
            Write-Error -Message "Параметры фильтрации не позволяют открывать сайт. Количество выбранных принтеров больше 1."
        }
    }
}

Function Set-PRN-PrinterRight {
    <#
    .SYNOPSIS
        Изменение прав доступа к принтеру.
    .DESCRIPTION
        Изменение прав доступа к принтеру. В качестве добавляемого объета может использоваться как учетная запись пользователя, так и группа.
        Возможны два варианта работы:
        С замещением всех прав - оставляет доступ по-умолчанию плюс права добавляемого объекта.
        С добавлением прав - добавляет к существующим правам новые права добавляемого объета.
        Предоставляет возможность печати и управлению очередью.
        .EXAMPLE
        PS C:\> Set-PRN-PrinterRight -Printer "Printer01" -ComputerName srv -Group "PRN-Printer01" -Reset
        Подключается к серверу srv и добавляет право печати группе PRN-Printer01 на принтер Printer01 со сбросом существующих разрешений
        .EXAMPLE
        PS C:\> Set-PRN-PrinterRight -Printer "Printer01" -ComputerName srv -User "Admin"
        Подключается к серверу srv и добавляет право печати группе пользователю Admin на принтер Printer01 добавляя новые права к уже существующим.
    .INPUTS
        Inputs (if any)
    .OUTPUTS
        Output (if any)
    .NOTES
        General notes
    #>
    param (
        [Parameter(Mandatory = $true, Position = 1, HelpMessage = 'Printer Name')][string]$Printer,
        [Parameter(Mandatory = $true, Position = 2, ParameterSetName = 'Group', HelpMessage = 'Group Name')][string]$Group,
        [Parameter(Mandatory = $true, Position = 2, ParameterSetName = 'User', HelpMessage = 'User Name')][string]$User,
        [Parameter(Mandatory = $false, Position = 3, HelpMessage = 'Server Name')][string]$ComputerName = "S18-PR01",
        [Parameter(Mandatory = $false, Position = 4, HelpMessage = 'Reset Access')][switch]$Reset
    )
    
    switch ($PSCmdlet.ParameterSetName) {
        "Group" { $AddSID = (Get-ADGroup -Identity $Group).SID }
        "User" { $AddSID = (Get-ADUser -Identity $User).SID }
    }

    $addSDDL = "(A;;SWRC;;;$AddSID)(A;CIIO;RC;;;$AddSID)(A;OIIO;RPWPSDRCWDWO;;;$AddSID)"
    $defSDDL = "G:SYD:(A;CIIO;RC;;;AC)(A;OIIO;RPWPSDRCWDWO;;;AC)(A;;SWRC;;;AC)(A;CIIO;RC;;;CO)(A;OIIO;RPWPSDRCWDWO;;;CO)(A;;LCSWSDRCWDWO;;;BA)(A;OIIO;RPWPSDRCWDWO;;;BA)"
    
    if ($Reset) {
        $NewSDDL = $defSDDL + $addSDDL
    }
    else {
        $NewSDDL = (Get-Printer -ComputerName $ComputerName -Name $Printer -Full).PermissionSDDL + $addSDDL
    }

    Set-Printer -ComputerName $ComputerName -Name $Printer -PermissionSDDL $NewSDDL -Verbose
}