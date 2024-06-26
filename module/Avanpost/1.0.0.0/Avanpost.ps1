$LogPath = "D:\work\powershell\Avanpost\Logs\"
$inPath = "D:\work\powershell\Avanpost\in"
$outPath = "D:\work\powershell\Avanpost\out"

$AdminPath = "\\S18-FS01\Departments\IT-отдел\!Общая\CARDs\"
$HomePath = "\\ABAKAN\dfs\Homes\" + $UserLogin + "\"
$tmplFile = "\\S18-FS01\Departments\IT-отдел\!Общая\CARDs\_Template.dotx"


$prod = $true

function Tools-Translale
{
    <#
    .SYNOPSIS
        Функция транслитерации символов с RU-LAT
    .DESCRIPTION
        Функция транслитерации символов с RU-LAT
    .EXAMPLE
        Tools-Translale -inString "Тестовая строка"
        
    .INPUTS
        Inputs (if any)
    .OUTPUTS
        Output (if any)
    .NOTES
        General notes
    #>
    param([string]$inString)

    $Translit_To_LAT = @{
        [char]'а' = "a"
        [char]'А' = "A"
        [char]'б' = "b"
        [char]'Б' = "B"
        [char]'в' = "v"
        [char]'В' = "V"
        [char]'г' = "g"
        [char]'Г' = "G"
        [char]'д' = "d"
        [char]'Д' = "D"
        [char]'е' = "e"
        [char]'Е' = "E"
        [char]'ё' = "e"
        [char]'Ё' = "E"
        [char]'ж' = "zh"
        [char]'Ж' = "Zh"
        [char]'з' = "z"
        [char]'З' = "Z"
        [char]'и' = "i"
        [char]'И' = "I"
        [char]'й' = "i"
        [char]'Й' = "I"
        [char]'к' = "k"
        [char]'К' = "K"
        [char]'л' = "l"
        [char]'Л' = "L"
        [char]'м' = "m"
        [char]'М' = "M"
        [char]'н' = "n"
        [char]'Н' = "N"
        [char]'о' = "o"
        [char]'О' = "O"
        [char]'п' = "p"
        [char]'П' = "P"
        [char]'р' = "r"
        [char]'Р' = "R"
        [char]'с' = "s"
        [char]'С' = "S"
        [char]'т' = "t"
        [char]'Т' = "T"
        [char]'у' = "u"
        [char]'У' = "U"
        [char]'ф' = "f"
        [char]'Ф' = "F"
        [char]'х' = "kh"
        [char]'Х' = "Kh"
        [char]'ц' = "tc"
        [char]'Ц' = "Tc"
        [char]'ч' = "ch"
        [char]'Ч' = "Ch"
        [char]'ш' = "sh"
        [char]'Ш' = "Sh"
        [char]'щ' = "shch"
        [char]'Щ' = "Shch"
        [char]'ъ' = "" # "``"
        [char]'Ъ' = "" # "``"
        [char]'ы' = "y" # "y`"
        [char]'Ы' = "Y" # "Y`"
        [char]'ь' = "" # "`"
        [char]'Ь' = "" # "`"
        [char]'э' = "e" # "e`"
        [char]'Э' = "E" # "E`"
        [char]'ю' = "iu"
        [char]'Ю' = "Iu"
        [char]'я' = "ia"
        [char]'Я' = "Ia"
    }

    $outChars=""

    foreach ($c in $inChars = $inString.ToCharArray())
    {
        if ($Translit_To_LAT[$c] -cne $Null )
            {$outChars += $Translit_To_LAT[$c]}
        else
            {$outChars += $c}
    }
    Write-Output $outChars
}

function New-StrongPassword {
    param (
        [Parameter(Mandatory=$true,Position=1,HelpMessage='Длина пароля')][int]$LengthPassword
    )
    Add-Type -AssemblyName System.Web
    
    $res = $true
    $StrictedChars = "O0lI{}[]|"
    [string]$StrongPasswd = [System.Web.Security.Membership]::GeneratePassword($LengthPassword,1)

    for($i=0; $i -lt $StrictedChars.Length; $i++) {
        if($StrongPasswd.Contains($StrictedChars[$i])) {
            $res = $false
            break
        }
    }

    if ($res) {
        return $StrongPasswd
    } else {
        New-StrongPassword -LengthPassword $LengthPassword
    }
}

Function Write-AVPLog {
    param (
        [Parameter(Mandatory=$true,Position=1,HelpMessage='User')]$User,
        [Parameter(Mandatory=$true,Position=2,HelpMessage='Module')][string]$Module,
        [Parameter(Mandatory=$true,Position=3,HelpMessage='Level')][string]$Level,
        [Parameter(Mandatory=$true,Position=4,HelpMessage='Message')][string]$Message
    )
    
    $str += (Get-Date -Format "yyyy.MM.dd HH:mm:ss.fff K") + ";"
    
    $str += $Module + ";"
    $str += $Level + ";" 
    $str += $Message

    $str | Out-File -FilePath (Join-Path -Path $LogPath -ChildPath ($user.Family + " " + $User.Name + " " + $User.Surname + ".log")) -Encoding default -Append -Force
}

function New-AVPHomeDrive {
    param (
        [Parameter(Mandatory = $true, Position = 1)]$User
    )

    $ParentDirectory = "\\S18-FS02\homes$\"
    $FullPath = $ParentDirectory + $User.Login

    if (!(Test-Path -Path $FullPath)) {
        if($prod) {
            New-Item -Path $FullPath -ItemType Directory -Force
            New-Item -Path ($FullPath + "\!scan\") -ItemType Directory -Force 
            Add-NTFSAccess -Path $FullPath -Account $User.Login -AccessRights FullControl -AppliesTo ThisFolderSubfoldersAndFiles
        }
        Write-AVPLog -User $User -Module $MyInvocation.MyCommand -Level "INFO" -Message ("Создан домашний каталог: " + $FullPath)
    }
}

function New-AVPWorkDrive {
    param (
        [Parameter(Mandatory = $true, Position = 1)]$User
    )

    $ParentDirectory = "\\ABAKAN\dfs\Departments\"
    
    $Name = $User.Family + " " + $User.Name

    switch ($User.Department) {
        "IT-отдел" { $pathDep = "IT-отдел" }
        "Бухгалтерия" { $pathDep = "Бухгалтерия" }
        "Клиентская служба" { $pathDep = "Клиентская служба" }
        "МКЦ " { $pathDep = "МКЦ" }
        "ОПЗЧ №1" { $pathDep = "ОПЗЧ №1" }
        "ОПЗЧ №2" { $pathDep = "ОПЗЧ №2" }
        "Отдел продаж легковых авто №1" { $pathDep = "ОПЛА №1" }
        "Отдел продаж легковых авто №2" { $pathDep = "ОПЛА №2" }
        "Отдел продаж подержанных автомобилей" { $pathDep = "ОППА" }
        "Склад" { $pathDep = "Склад" }
        "Служба сервиса" { $pathDep = "Служба сервиса" }
        "Снабжение" { $pathDep = "Снабжение" }
        "Управление" { $pathDep = "Управление" }
        "Цех дополнительного оборудования" { $pathDep = "Цех дополнительного оборудования" }
        "Цех технического обслуживания и ремонта" { $pathDep = "Цех технического обслуживания и ремонта" }
    }

    $fullpath = $ParentDirectory + $pathDep + "\" + $Name
    if (!(Test-Path -Path ($fullpath))) {
        if($prod) {
            New-Item -Path $fullpath -ItemType Directory | Out-Null
            Add-NTFSAccess -Path $fullpath -Account $User.Login -AccessRights Modify -AppliesTo ThisFolderSubfoldersAndFiles
            Write-AVPLog -User $User -Module $MyInvocation.MyCommand -Level "INFO" -Message ("Создан рабочий диск: " + $fullpath)
        }
    }
}

function Import-AVPNewUser {
    param (
        [Parameter(Mandatory=$true,Position=1,HelpMessage='Path')][string]$Path
    )
    
    $srcString = Get-Content -Path $Path -Encoding Default

    $User = $srcString.Split(";")

    $login = Tools-Translale -inString ($User[1] + "." + $User[0])

    Write-Host ("Automatic generate login: " + $login) -BackgroundColor DarkRed
    $newLogin = Read-Host -Prompt "Enter new name or press Enter for accept automatic value"
    if ($newLogin.Length -gt 0) {
        $login = $newLogin
    }

    $UserObj = [PSCustomObject]@{
        Family = $User[0]
        Name = $User[1]
        Surname = $User[2]
        BirthDate = $User[3]
        EmployeeID = $User[4]
        Company = $User[5]
        Department = $User[6]
        Title = $User[7]
        Phone = $User[8]
        login = $login
        password = New-StrongPassword -LengthPassword 10
        FilePath = $Path
    }

    Write-AVPLog -User $UserObj -Module $MyInvocation.MyCommand -Level "INFO" -Message ("Импорт строки: " + $srcString)

    return $UserObj
} 

function Check-AVPUserAccess {
    param (
        [Parameter(Mandatory=$true,Position=1,HelpMessage='Пользователь')]$User,
        [Parameter(Mandatory=$true,Position=2,HelpMessage='Information System')]
        [ValidateSet("ActiveDirectory", "Exchange")]
        [string]$System
    )
        switch ($User.Title) {
            "Системный администратор" { 
                $ActiveDirectory = $true 
                $Exchange = $true
                Write-AVPLog -User $User -Module $MyInvocation.MyCommand -Level "INFO" -Message ("Определена должность: " + $User.Title)
            }
            Default {
                $ActiveDirectory = $false
                $Exchange = $false
                Write-AVPLog -User $User -Module $MyInvocation.MyCommand -Level "WARN" -Message ("Применяются настройки по-умолчанию. Должность: " + $User.Title)
            }
        }
    
        switch ($System) {
            "ActiveDirectory" { return $ActiveDirectory }
            "Exchange" {return $Exchange}
            Default { return $false}
        }
}
function Fill-AVPADGroup {
    param (
        [Parameter(Mandatory=$true,Position=1,HelpMessage='User')]$User
    )
    
    $DefaultGroups = "18-DG-INF-AllUsers", "18-SG-AS-OTRSUsers"

    switch ($User.Department) {
        "IT-отдел" { $DepartmentPrefix = "IT" }
        "Бухгалтерия" { $DepartmentPrefix = "BUH" }
        "Отдел продажи запасных частей №1" { $DepartmentPrefix = "OPZCH1" }
        "Отдел продажи запасных частей №1" { $DepartmentPrefix = "OPZCH2" }
        "Отдел кадров" { $DepartmentPrefix = "KADR" }
        "Отдел продажи легковых авто №1" { $DepartmentPrefix = "OPLA1" }
        "Отдел продажи легковых авто №2" { $DepartmentPrefix = "OPLA2" }
        "Отдел продаж подержанных автомобилей" { $DepartmentPrefix = "OPPA" }
        "Склад" { $DepartmentPrefix = "SKLAD" }
        "Служба сервиса" { $DepartmentPrefix = "SS" }
        "Снабжение" { $DepartmentPrefix = "SNAB" }
        "Управление" { $DepartmentPrefix = "MNG" }
        "Цех дополнительного оборудования" { $DepartmentPrefix = "CDO" }
        "Цех технического обслуживания и ремонта" { $DepartmentPrefix = "CTOIR" }
        "Маляоно-кузовной цех" { $DepartmentPrefix = "MKC" }
    }

    $GroupName = "18-SG-ORG-" + $DepartmentPrefix
    $DefaultGroups += $GroupName

    Foreach ($Group in $DefaultGroups) {
        if($prod) {
            Add-ADGroupMember -Identity $Group -Members $User.login
        }
        
        Write-AVPLog -User $User -Module $MyInvocation.MyCommand -Level "INFO" -Message ("Пользователь: " + $User.login + " добавлен в группу: " + $Group)
    }

}
function Check-AVPADUser {
    param (
        [Parameter(Mandatory=$true,Position=1,HelpMessage='Пользователь')]$User
    )
 
    $sAMAccountName = $User.login
    $EmployeeID = $User.EmployeeID

    if (Get-ADUser -LDAPFilter "(&(sAMAccountName=$sAMAccountName)(EmployeeID=$EmployeeID))") {
        $ADUser = Get-ADUser -LDAPFilter "(&(sAMAccountName=$sAMAccountName)(EmployeeID=$EmployeeID))"
        Write-AVPLog -User $User -Module $MyInvocation.MyCommand -Level "WARN" -Message ("Пользователь найден. SID:" + $ADUser.SID.Value)
        return $true
    } else {
        Write-AVPLog -User $User -Module $MyInvocation.MyCommand -Level "INFO" -Message "Пользователь не найден"
        return $false
    }
}
function New-AVPADUser {
    param (
        [Parameter(Mandatory=$true,Position=1,HelpMessage='User')]$User
    )
    
    if ((Check-AVPADUser -User $User) -eq $false -and (Check-AVPUserAccess -User $User -System ActiveDirectory) -eq $true ) {
        Write-AVPLog -User $User -Module $MyInvocation.MyCommand -Level "INFO" -Message ("Создаем нового пользователя: " + $User.Family + " " + $User.Name + " " + $User.Surname)
        if ($prod) {
            New-ADUser  -Name ($User.Family + " " + $User.Name) `
                        -DisplayName ($User.Family + " " + $User.Name + " " + $User.Surname) `
                        -GivenName $User.Name `
                        -Surname $User.Family `
                        -Department $User.Department `
                        -Title $User.Title `
                        -UserPrincipalName ($User.Login + "@abakan.medved-holding.com") `
                        -SamAccountName $User.Login `
                        -Path "OU=Users,OU=ABAKAN,DC=ABAKAN,DC=MEDVED-HOLDING,Dc=COM" `
                        -AccountPassword (ConvertTo-SecureString -AsPlainText -Force -String $user.password) `
                        -Company $User.Company `
                        -Description $User.Title `
                        -OfficePhone $User.phone `
                        -Enabled $true `
                        -EmployeeID $User.EmployeeID `
                        -Server "DC5ABAKAN.ABAKAN.MEDVED-HOLDING.COM"

            Fill-AVPADGroup -User $User
            New-AVPHomeDrive -User $User
            New-AVPWorkDrive -User $User
            New-AVPADUserCard -User $User
            Send-AVPEmail -User $User
            Move-AVPUserFile  -User $User

        }
    } else {
        Write-AVPLog -User $User -Module $MyInvocation.MyCommand -Level "ERR" -Message ("Проверка на создание нового пользователя не пройдена")
        if (Check-AVPADUser -User $User) {
            Write-AVPLog -User $User -Module $MyInvocation.MyCommand -Level "ERR" -Message ("Проверка на создание нового пользователя не пройдена. Пользователь уже существует.")
        }
        if (Check-AVPUserAccess -User $User -System ActiveDirectory) {
            Write-AVPLog -User $User -Module $MyInvocation.MyCommand -Level "ERR" -Message ("Проверка на создание нового пользователя не пройдена. Должность не подразумевает наличия учетной записи ActiveDirectory.")
        }
    }
}

function New-AVPADUserCard {
    param (
        [Parameter(Mandatory=$true,Position=1,HelpMessage='User')]$User
    )

    $word = New-Object -ComObject Word.Application
    $doc = $word.Documents.add($tmplFile)

    $FIO = ($User.Family + " " + $User.Name[0] + ". " + $User.Surname[0] + ".")

    for ($i = 1; $i -le $doc.Fields.Count; $i++) {
        switch (($doc.Fields($i).Code.Text).trim()) {
            "FIO" { $doc.Fields($i).result.text =  $FIO}
            "sAMAccountName" { $doc.Fields($i).result.text = $User.Login }
            "password" { $doc.Fields($i).result.text = $User.Password }
            "mail" { $doc.Fields($i).result.text = $User.Login + "@medved-abakan.ru" }
            "company" { $doc.Fields($i).result.text = $User.company }
            "department" { $doc.Fields($i).result.text = $User.department }
            "title" { $doc.Fields($i).result.text = $User.Title }
            "employeeID" { $doc.Fields($i).result.text = $User.employeeID }
        }
    }  
  
    $doc.SaveAs([ref]($AdminPath + $FIO + ".pdf"), [ref][Microsoft.Office.Interop.Word.WdSaveFormat]::wdFormatPDF)
    $doc.SaveAs([ref]($HomePath + "Карточка сотрудника.pdf"), [ref][Microsoft.Office.Interop.Word.WdSaveFormat]::wdFormatPDF)
    $doc.Close([ref]$false)
    $word.Quit([ref]$false)

    Write-AVPLog -User $UserLogin -Module $MyInvocation.MyCommand -Level "INFO" -Message "Карточка сотрудника заведена"
}

function Send-AVPEmail {
    param (
        [Parameter(Mandatory=$true,Position=1,HelpMessage='User')]$User
    )

    $FIO = ($User.Family + " " + $User.Name[0] + ". " + $User.Surname[0] + ".")

    $body = "
    Добрый день, <p>

    Новый сотрудник <b>" + $FIO + "</b> успешно зарегистрирован в системе. <p>
    
    Предварительный адрес электронной почты: <b>" + $user.login+ "@medved-abakan.ru</b> (будет доступен в ближайшее время).

    "

    #                      -Cc "Natalya.Murashova@medved-abakan.ru" `

    Send-MailMessage -To "Sergey.Filimonov@medved-abakan.ru" `
                     -From "Sergey.Filimonov@medved-abakan.ru" `
                     -Body $body  `
                     -Subject ("Новый пользователь: " + $FIO) `
                     -Priority High `
                     -SmtpServer "mail.medved-zapad.ru" `
                     -Encoding UTF8 -BodyAsHtml              

    Write-AVPLog -User $UserLogin -Module $MyInvocation.MyCommand -Level "INFO" -Message "Карточка сотрудника заведена"
}

function Move-AVPUserFile {
    param (
        [Parameter(Mandatory=$true,Position=1,HelpMessage='User')]$User
    )

    Move-Item -Path $user.FilePath -Destination $outPath -Force

}

function New-AVPSKUDUser {
    param (
        [Parameter(Mandatory=$true,Position=1,HelpMessage='User')]$User
    )

    $SQL_Connection = New-Object System.Data.SqlClient.SqlConnection
    $SQL_Connection.ConnectionString="Data Source=S18-DB01.abakan.medved-holding.com;Initial Catalog=Inventory;Integrated Security=True"
    $SQL_Command = $SQL_Connection.CreateCommand()

    $SQL_Command.CommandText = ""
    $SQL_Connection.Open()

    $SQL_Connection.Close()

}

$User = Import-AVPNewUser -Path "D:\work\powershell\Avanpost\in\NewUser.csv"
Move-AVPUserFile -User $User