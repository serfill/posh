function Local-InvokePasswordRoll
{
<#
.SYNOPSIS

Этот сценарий можно использовать для установки случайных паролей для локальных учетных записей на удаленных машинах. Сочетание "имя пользователя/пароль/имя сервера" будет сохранено в CSV-файле. Пароли учетных записей, хранящиеся в CSV-файле, можно зашифровать с помощью пароля администратора, убедившись, что открытые пароли учетных записей не записаны на диск. Зашифрованные пароли можно расшифровать с помощью другой функции из этого файла: ConvertTo-CleartextPassword


Function: Invoke-PasswordRoll
Author: Microsoft
Version: 1.0

.DESCRIPTION

Этот сценарий можно использовать для установки случайных паролей для локальных учетных записей на удаленных машинах. Сочетание "имя пользователя/пароль/имя сервера" будет сохранено в CSV-файле. Пароли учетных записей, хранящиеся в CSV-файле, можно зашифровать с помощью пароля администратора, убедившись, что открытые пароли учетных записей не записаны на диск. Зашифрованные пароли можно расшифровать с помощью другой функции из этого файла: ConvertTo-CleartextPassword

.PARAMETER ComputerName

Массив компьютеров, на которых будет выполняться сценарий с помощью удаленного взаимодействия PowerShell.

.PARAMETER LocalAccounts

Массив локальных учетных записей, пароли которых необходимо изменить.

.PARAMETER TsvFileName

Файл, в который будут сохранены полученные сочетания "имя пользователя/пароль/имя сервера".

.PARAMETER EncryptionKey

Пароль, с помощью которого будет зашифрован TSV-файл. Используется шифрование AES. Будут зашифрованы только пароли, хранящиеся в TSV-файле; имена пользователя и сервера будут открытыми.

.PARAMETER PasswordLength

Длина паролей, которые будут созданы случайным образом для локальных учетных записей.

.PARAMETER NoEncryption

Не шифруйте пароли учетных записей, хранящиеся в TSV-файле. Это приведет к записи открытых паролей на диск.

.EXAMPLE

. .\Invoke-PasswordRoll.ps1    #Загружает функцию в этой файл сценария
Invoke-PasswordRoll -ComputerName (Get-Content computerlist.txt) -LocalAccounts @("administrator","CustomLocalAdmin") -TsvFileName "LocalAdminCredentials.tsv" -EncryptionKey "Password1"

Подключается ко всем компьютерам, указанным в файле computerlist.txt. Если "администратор" локальной учетной записи и/или CustomLocalAdmin существуют в системе, пароль изменяется на случайно созданный 20-символьный (по умолчанию). Сочетания "имя пользователя/пароль/имя сервера" сохраняются в файле LocalAdminCredentials.tsv, а пароли учетных записей шифруются по протоколу AES с помощью пароля Password1.

.EXAMPLE

. .\Invoke-PasswordRoll.ps1    #Загружает функцию в этой файл сценария
Invoke-PasswordRoll -ComputerName (Get-Content computerlist.txt) -LocalAccounts @("administrator") -TsvFileName "LocalAdminCredentials.tsv" -NoEncryption -PasswordLength 40

Подключается ко всем компьютерам, указанным в файле computerlist.txt. Если "администратор" локальной учетной записи существует в системе, его пароль изменяется на случайно созданный 40-символьный. Сочетания "имя пользователя/пароль/имя сервера" сохраняются в файле LocalAdminCredentials.tsv в незашифрованном виде.

.NOTES
Требования: –установленная оболочка PowerShell версии 2 или более поздней –удаленное взаимодействие PowerShell должно быть включено во всех системах, в которых будет запущен сценарий

Поведение сценария: –если локальная учетная запись существует в системе, но не указана в параметре LocalAccounts, сценарий вызовет окно предупреждения, чтобы уведомить о существовании локальной учетной записи. При этом выполнение сценария будет продолжено. –если локальная учетная запись указана в параметре LocalAccounts, но не существует на компьютере, ничего не произойдет (учетная запись НЕ будет создана). –функцию ConvertTo-CleartextPassword, содержащуюся в этом файле, можно использовать для шифрования паролей, которые хранятся в зашифрованном виде в TSV-файле. –если к серверу, указанному в параметре ComputerName, не удастся подключиться, PowerShell отобразит сообщение об ошибке. –корпорация Майкрософт рекомендует компаниям регулярно свертывать пароли всех локальных и доменных учетных записей.

#>
    [CmdletBinding(DefaultParameterSetName="Encryption")]
    Param(
        [Parameter(Mandatory=$true)]
        [String[]]
        $ComputerName,

        [Parameter(Mandatory=$true)]
        [String[]]
        $LocalAccounts,

        [Parameter(Mandatory=$true)]
        [String]
        $TsvFileName,

        [Parameter(ParameterSetName="Encryption", Mandatory=$true)]
        [String]
        $EncryptionKey,

        [Parameter()]
        [ValidateRange(6,120)]
        [Int]
        $PasswordLength = 8,

        [Parameter(ParameterSetName="NoEncryption", Mandatory=$true)]
        [Switch]
        $NoEncryption,

        [Parameter(Mandatory=$false)][switch]$DefaultPassword
    )

    #Пароль по умолчанию
    $DefPasswd = 'Admin$2012'

    #Загружает все необходимые классы.net
    Add-Type -AssemblyName "System.Web" -ErrorAction Stop


    #Параметр ScriptBlock, который будет запущен на каждом компьютере, указанном в параметре ComputerName
    $RemoteRollScript = {
        Param(
            [Parameter(Mandatory=$true, Position=1)]
            [String[]]
            $Passwords,

            [Parameter(Mandatory=$true, Position=2)]
            [String[]]
            $LocalAccounts,

            #Он существует, поэтому можно записать имя сервера, к которому был подключен сценарий. Это может быть полезно, так как иногда легко запутаться в записях DNS.
            [Parameter(Mandatory=$true, Position=3)]
            [String]
            $TargettedServerName
        )

        $LocalUsers = Get-WmiObject Win32_UserAccount -Filter "LocalAccount=true" | Foreach {$_.Name}

        #Проверьте, существуют ли на компьютере учетные записи локальных пользователей, пароли которых не будут свернуты с помощью этого сценария
        foreach ($User in $LocalUsers)
        {
            if ($LocalAccounts -inotcontains $User)
            {
                Write-Warning "Server: '$($TargettedServerName)' has a local account '$($User)' whos password is NOT being changed by this script"
            }
        }

        #Измените пароль для всех указанных локальных учетных записей, существующих на этом сервере
        $PasswordIndex = 0
        foreach ($LocalAdmin in $LocalAccounts)
        {
            $Password = $Passwords[$PasswordIndex]    

            if ($LocalUsers -icontains $LocalAdmin)
            {
                try
                {
                    $objUser = [ADSI]"WinNT://localhost/$($LocalAdmin), user"
                    $objUser.psbase.Invoke("SetPassword", $Password)

                    $Properties = @{
                        TargettedServerName = $TargettedServerName
                        Username =  $LocalAdmin
                        Password = $Password
                        RealServerName = $env:computername
                        DateTime = get-date
                    }

                    $ReturnData = New-Object PSObject -Property $Properties
                    Write-Output $ReturnData
                }
                catch
                {
                    Write-Error "Error changing password for user:$($LocalAdmin) on server:$($TargettedServerName)"
                }
            }

            $PasswordIndex++
        }
    }


    #Создавайте пароль на клиентском компьютере, на котором выполняется сценарий, а не на удаленной машине. Параметр System.Web.Security недоступен в профиле .NET Client. Совершение этого вызова #     на клиентском компьютере, на котором выполняется сценарий, позволяет использовать полноценную установленную среду выполнения .NET только на одном компьютере (в отличие от систем со свернутыми паролями).
    function Create-RandomPassword
    {
        Param(
            [Parameter(Mandatory=$true)]
            [ValidateRange(6,120)]
            [Int]
            $PasswordLength
        )

        $Password = [System.Web.Security.Membership]::GeneratePassword($PasswordLength, $PasswordLength / 4)

        #Это не должно завершиться неудачей, но я всегда проверяю работоспособность на этом этапе
        if ($Password.Length -ne $PasswordLength)
        {
            throw new Exception("Password returned by GeneratePassword is not the same length as required. Required length: $($PasswordLength). Generated length: $($Password.Length)")
        }
        if ($DefaultPassword) {
            return $DefPasswd
        } else {
            return $Password
        }
    }


    #Основная функция — создание пароля и передача его на машины для изменения паролей указанных локальных учетных записей
    if ($PsCmdlet.ParameterSetName -ieq "Encryption")
    {
        try
        {
            $Sha256 = new-object System.Security.Cryptography.SHA256CryptoServiceProvider
            $SecureStringKey = $Sha256.ComputeHash([System.Text.UnicodeEncoding]::Unicode.GetBytes($EncryptionKey))
        }
        catch
        {
            Write-Error "Error creating TSV encryption key" -ErrorAction Stop
        }
    }

    foreach ($Computer in $ComputerName)
    {
        #Необходимо создать по одному паролю для каждой учетной записи, которая может быть изменена
        $Passwords = @()
        for ($i = 0; $i -lt $LocalAccounts.Length; $i++)
        {
            $Passwords += Create-RandomPassword -PasswordLength $PasswordLength
        }

        Write-Output "Connecting to server '$($Computer)' to roll specified local admin passwords"
        $Result = Invoke-Command -ScriptBlock $RemoteRollScript -ArgumentList @($Passwords, $LocalAccounts, $Computer) -ComputerName $Computer
        #Если используется шифрование, зашифруйте пароль с помощью ключа, предоставленного пользователем, прежде чем записывать его на диск
        if ($Result -ne $null)
        {
            if ($PsCmdlet.ParameterSetName -ieq "NoEncryption")
            {
                $Result | Select-Object Username,Password,TargettedServerName,RealServerName,DateTime | Export-Csv -Append -Path $TsvFileName -NoTypeInformation -Encoding Default
            }
            else
            {
                #Отфильтровывает возвращенные записи $null
                $Result = $Result | Select-Object Username,Password,TargettedServerName,RealServerName

                foreach ($Record in $Result)
                {
                    $PasswordSecureString = ConvertTo-SecureString -AsPlainText -Force -String ($Record.Password)
                    $Record | Add-Member -MemberType NoteProperty -Name EncryptedPassword -Value (ConvertFrom-SecureString -Key $SecureStringKey -SecureString $PasswordSecureString)
                    $Record.PSObject.Properties.Remove("Password")
                    $Record | Select-Object Username,EncryptedPassword,TargettedServerName,RealServerName,DateTime | Export-Csv -Append -Path $TsvFileName -NoTypeInformation -Encoding Default
                }
            }
        }
    }
}


function Local-ConvertToCleartextPassword
{
<#
.SYNOPSIS
Эту функцию можно использовать для расшифровки паролей, которые были сохранены в зашифрованном виде с помощью функции Invoke-PasswordRoll.

Function: ConvertTo-CleartextPassword
Author: Microsoft
Version: 1.0

.DESCRIPTION
Эту функцию можно использовать для расшифровки паролей, которые были сохранены в зашифрованном виде с помощью функции Invoke-PasswordRoll.


.PARAMETER EncryptedPassword

Зашифрованный пароль, сохраненный в TSV-файле.

.PARAMETER EncryptionKey

Пароль, используемый для шифрования.


.EXAMPLE. .\Invoke-PasswordRoll.ps1    #Загружает функцию в этой файл сценария
ConvertTo-CleartextPassword -EncryptionKey "Password1" -EncryptedPassword 76492d1116743f0423413b16050a5345MgB8AGcAZgBaAHUAaQBwADAAQgB2AGgAcABNADMASwBaAFoAQQBzADEAeABjAEEAPQA9AHwAZgBiAGYAMAA1ADYANgA2ADEANwBkADQAZgAwADMANABjAGUAZQAxAGIAMABiADkANgBiADkAMAA4ADcANwBhADMAYQA3AGYAOABkADcAMQA5ADQAMwBmAGYANQBhADEAYQBjADcANABkADIANgBhADUANwBlADgAMAAyADQANgA1ADIAOQA0AGMAZQA0ADEAMwAzADcANQAyADUANAAzADYAMAA1AGEANgAzADEAMQA5ADAAYwBmADQAZAA2AGQA"

Расшифровывает зашифрованный пароль, сохраненный в TSV-файле.

#>
    Param(
        [Parameter(Mandatory=$true)]
        [String]
        $EncryptedPassword,

        [Parameter(Mandatory=$true)]
        [String]
        $EncryptionKey
    )

    $Sha256 = new-object System.Security.Cryptography.SHA256CryptoServiceProvider
    $SecureStringKey = $Sha256.ComputeHash([System.Text.UnicodeEncoding]::Unicode.GetBytes($EncryptionKey))

    [SecureString]$SecureStringPassword = ConvertTo-SecureString -String $EncryptedPassword -Key $SecureStringKey
    Write-Output ([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($SecureStringPassword)))
} 

function Local-GetLocalUsers
{

    Param(
        [parameter(Mandatory=$true, Position=1)][string]$ComputerName
    )

$RemoteRollScript = {
        Param(
            #Он существует, поэтому можно записать имя сервера, к которому был подключен сценарий. Это может быть полезно, так как иногда легко запутаться в записях DNS.
            [Parameter(Mandatory=$true, Position=1)]
            [String]
            $TargettedServerName
        )

        $LocalUsers = Get-WmiObject Win32_UserAccount -Filter "LocalAccount=true" | Foreach {$_.Name}
    Write-Warning -Message $TargettedServerName
        #Проверьте, существуют ли на компьютере учетные записи локальных пользователей, пароли которых не будут свернуты с помощью этого сценария
        foreach ($User in $LocalUsers)
        {
                Write-Host $User
        }
    }
    
    $result = Invoke-Command -ComputerName $ComputerName -ScriptBlock $RemoteRollScript -ArgumentList @($ComputerName)
    $result 
}

function Local-GetSoftware 
{
    Param(
        [parameter(Mandatory=$true, Position=1)][string]$ComputerName
    )
}

function Local-GetLocalProfile
{
    param (
        [parameter(Mandatory=$true, Position=1)][string]$computerName
    )

    $RemoteScript = {
        $FullSize = [math]::Round((Get-ChildItem C:\Users -Recurse | Measure-Object -Property Length -Sum).Sum/1Gb, 3)
        $DocsOnly = 0

        foreach ($usersPath in Get-ChildItem C:\Users -Directory) {
            $folder = "Documents", "Desktop", "Pictures"
            foreach ($userfolder in $folder)
            {
                $p = $userspath.FullName + "\" + $userfolder
                $p
                $DocsOnly = $DocsOnly + (Get-ChildItem -path $p -Recurse | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
            }
        }

        $total = [math]::Round($DocsOnly/1Gb, 3)

        $prop = @{
            computerName = $computerName
            FullSize = $FullSize
            DocOnly = $total
        }

        return New-Object -TypeName psobject -Property $prop
    }
}

function Local-GetLocalProfilesSize
{
    param (
        [parameter(Mandatory=$true, Position=1)][string]$computerName
    )

    $RemoteScript = {
        $FullSize = (Get-ChildItem C:\Users -Recurse | Measure-Object -Property Length -Sum).Sum
        $DocsOnly = 0

        foreach ($usersPath in Get-ChildItem C:\Users -Directory) {
            $folder = "Documents", "Desktop", "Pictures"
            foreach ($userfolder in $folder)
            {
                $p = $userspath.FullName + "\" + $userfolder
                $DocsOnly = $DocsOnly + (Get-ChildItem -path $p -Recurse | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
            }
        }

        $total = $DocsOnly

        $prop = @{
            FullSize = $FullSize
            DocOnly = $total
        }

        return New-Object -TypeName psobject -Property $prop
    }

    Invoke-Command -ComputerName $computerName -ScriptBlock $RemoteScript -ArgumentList @($computerName)
}

function Local-RemoveTeamViwer
{
    param (
        [parameter(Mandatory=$true, Position=1)][string]$computerName
    )

    $RemoteScript = {
        $paths = "c:\Program Files (x86)\TeamViewer\uninstall.exe", "c:\Program Files\TeamViewer\uninstall.exe"
        $p = ""
        foreach($path in $paths) {
            if(Test-Path -Path $path) {
                Start-Process -FilePath $path -ArgumentList "/S"
                $p = $path
            }
        }

        $prop = @{
            PathResult = $p
        }

        return New-Object -TypeName psobject -Property $prop
    }

    Invoke-Command -ComputerName $computerName -ScriptBlock $RemoteScript -ArgumentList @($computerName)

}