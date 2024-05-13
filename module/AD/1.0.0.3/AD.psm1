function Tools-Translale {
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

    $outChars = ""

    foreach ($c in $inString.ToCharArray()) {
        if ($Translit_To_LAT[$c] -cne $Null )
        { $outChars += $Translit_To_LAT[$c] }
        else
        { $outChars += $c }
    }
    Write-Output $outChars
}

function New-StrongPassword {
    param (
        [Parameter(Mandatory = $true, Position = 1, HelpMessage = 'Длина пароля')][int]$LengthPassword
    )
    Add-Type -AssemblyName System.Web
    
    $res = $true
    $StrictedChars = "O0lI{}[]|"
    [string]$StrongPasswd = [System.Web.Security.Membership]::GeneratePassword($LengthPassword, 1)

    for ($i = 0; $i -lt $StrictedChars.Length; $i++) {
        if ($StrongPasswd.Contains($StrictedChars[$i])) {
            $res = $false
            break
        }
    }

    if ($res) {
        return $StrongPasswd
    }
    else {
        New-StrongPassword -LengthPassword $LengthPassword
    }
}

Function Get-AD-User {
    param (
        [parameter (Mandatory = $false, DontShow)][string]$hidden
    )

    DynamicParam {
        $ParameterUserName = 'UserName'
        $ParameterProperty = 'Property'

        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
    
        $AttributeCollectionUserName = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ParameterAttributeUserName = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttributeUserName.Mandatory = $true
        $ParameterAttributeUserName.Position = 1
        $ParameterAttributeUserName.HelpMessage = "Имя пользователя"
        $AttributeCollectionUserName.Add($ParameterAttributeUserName)

        $AttributeCollectionProperty = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ParameterAttributeProperty = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttributeProperty.Mandatory = $true
        $ParameterAttributeProperty.Position = 2
        $ParameterAttributeProperty.HelpMessage = "Имя свойства"
        $AttributeCollectionProperty.Add($ParameterAttributeProperty)

        $ADList = Get-ADUser -Filter "Enabled -eq '$true'" -Properties *
        $arrSetUserName = $ADList | Sort-Object DisplayName | Select-Object -ExpandProperty DisplayName
        $arrSetProperty = $ADList | Get-Member -MemberType Property | Select-Object -ExpandProperty Name

        $ValidateSetAttributeUserName = New-Object System.Management.Automation.ValidateSetAttribute($arrSetUserName)
        $ValidateSetAttributeProperty = New-Object System.Management.Automation.ValidateSetAttribute($arrSetProperty)

        $AttributeCollectionUserName.Add($ValidateSetAttributeUserName)
        $AttributeCollectionProperty.Add($ValidateSetAttributeProperty)

        $RuntimeParameterUserName = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterUserName, [string], $AttributeCollectionUserName)
        $RuntimeParameterProperty = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterProperty, [string], $AttributeCollectionProperty)
    
        $RuntimeParameterDictionary.Add($ParameterUserName, $RuntimeParameterUserName)
        $RuntimeParameterDictionary.Add($ParameterProperty, $RuntimeParameterProperty)
    
        return $RuntimeParameterDictionary
    }
    
    begin {
        $UserName = $PsBoundParameters[$ParameterUserName]
        $Property = $PsBoundParameters[$ParameterProperty]
    }

    process {
        (Get-ADUser -Filter "DisplayName -eq '$UserName'" -Properties $Property).$Property
    }

}
function Add-AD-Group {

    #Requires -Module ActiveDirectory

    param (
        # Служебный скрытый параметр, используется для того чтобы в списке не появлялось ничего лишнего
        [parameter (Mandatory = $false, Position = 1)][ValidateSet('Name', 'Mail', 'Default')][string]$Type = "Defalut",
        [parameter (Mandatory = $false, DontShow)][string] $hidden
    )

    DynamicParam {
        $ParameterName = 'Name'
        $ParameterGroup = 'Object'

        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            
        $AttributeCollectionName = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $AttributeCollectionGroup = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            
        $ParameterAttributeName = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttributeName.Mandatory = $true
        $ParameterAttributeName.Position = 1
        $ParameterAttributeName.HelpMessage = "Введите имя пользователя"
            
        $ParameterAttributeGroup = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttributeGroup.Mandatory = $true
        $ParameterAttributeGroup.Position = 2
        $ParameterAttributeGroup.HelpMessage = "Введите имя группы доступа"

        $AttributeCollectionName.Add($ParameterAttributeName)

        $AttributeCollectionGroup.Add($ParameterAttributeGroup)

        $arrNames = Get-ADUser -Filter "Enabled -eq 'true'" -Properties Enabled | Sort-Object Name | Select-Object -ExpandProperty Name
            
        switch ($Type) {
            "Name" { $arrGroups = Get-ADGroup -Filter "CN -like '*'" | Sort-Object Name | Select-Object -ExpandProperty Name }
            "Mail" { $arrGroups = Get-ADGroup -Filter "mail -like '*'" -Properties mail | Sort-Object mail | Select-Object -ExpandProperty mail }
            default { $arrGroups = Get-ADGroup -Filter "mail -like '*'" -Properties mail | Sort-Object mail | Select-Object -ExpandProperty mail }
        }

        $ValidateSetAttributeName = New-Object System.Management.Automation.ValidateSetAttribute($arrNames)
        $ValidateSetAttributeGroup = New-Object System.Management.Automation.ValidateSetAttribute($arrGroups)

        $AttributeCollectionName.Add($ValidateSetAttributeName)
        $AttributeCollectionGroup.Add($ValidateSetAttributeGroup)

        $RuntimeParameterNames = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollectionName)
        $RuntimeParameterGroups = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterGroup, [string], $AttributeCollectionGroup)

        $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameterNames)
        $RuntimeParameterDictionary.Add($ParameterGroup, $RuntimeParameterGroups)

        return $RuntimeParameterDictionary
    }

    begin {
        $Name = $PsBoundParameters[$ParameterName]
        $Object = $PsBoundParameters[$ParameterGroup]
    }

    process {
        $login = (Get-ADUser -Filter "CN -eq '$Name'" ).samaccountname

        switch ($Type) {
            'Name' { Get-ADGroup -Filter "CN -eq '$Object'" | Add-ADGroupMember -Members $login }
            'Mail' { Get-ADGroup -Filter "mail -eq '$Object'" -Properties mail | Add-ADGroupMember -Members $login }
        }
    }
}

function New-AD-User {

    #    Requires -Module Tools

    <#
.SYNOPSIS
    Регистрация нового пользователя в Active Directory
.DESCRIPTION
    Регистрация нового пользователя в Active Directory с автоматическим заполнением всех необходимых полей
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    General notes
#>

    PARAM (
        [Parameter(Mandatory = $true, ParameterSetName = "Command", HelpMessage = "Имя пользователя")][string]$UserName,
        [Parameter(Mandatory = $true, ParameterSetName = "Command", HelpMessage = "Фамилия пользователя")][String]$UserFamily,
        [Parameter(Mandatory = $true, ParameterSetName = "Command", HelpMessage = "Отчество пользователя")][String]$UserSurname,
        [Parameter(Mandatory = $true, ParameterSetName = "Command", HelpMessage = "Табельный номер")][String]$EmployeeID,
        [Parameter(Mandatory = $false, ParameterSetName = "Command", HelpMessage = "Внутренний телефон")][String]$phone = $null,
        [Parameter(Mandatory = $true, ParameterSetName = "File", HelpMessage = "Путь до csv-файла")][string]$Path
    )

    DynamicParam {
        $ParameterTitle = 'Title'
        $ParameterDepartment = 'Department'
        $ParameterCompany = 'Company'
        $ParameterServer = 'Server'

        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            
        $AttributeCollectionTitle = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $AttributeCollectionDepartment = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $AttributeCollectionCompany = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $AttributeCollectionServer = New-Object System.Collections.ObjectModel.Collection[System.Attribute]

        $ParameterAttributeTitle = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttributeTitle.Mandatory = $true
        $ParameterAttributeTitle.Position = 3
        $ParameterAttributeTitle.HelpMessage = "Должность"
        $ParameterAttributeTitle.ParameterSetName = "Command"
            
        $ParameterAttributeDepartment = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttributeDepartment.Mandatory = $true
        $ParameterAttributeDepartment.Position = 4
        $ParameterAttributeDepartment.HelpMessage = "Наименование подразделения"
        $ParameterAttributeDepartment.ParameterSetName = "Command"

        $ParameterAttributeCompany = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttributeCompany.Mandatory = $true
        $ParameterAttributeCompany.Position = 5
        $ParameterAttributeCompany.HelpMessage = "Наименование организации"
        $ParameterAttributeCompany.ParameterSetName = "Command"

        $ParameterAttributeServer = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttributeServer.Mandatory = $false
        $ParameterAttributeServer.Position = 6
        $ParameterAttributeServer.HelpMessage = "Имя сервера"
        $ParameterAttributeServer.ParameterSetName = "Command"

        $AttributeCollectionTitle.Add($ParameterAttributeTitle)
        $AttributeCollectionDepartment.Add($ParameterAttributeDepartment)
        $AttributeCollectionCompany.Add($ParameterAttributeCompany)
        $AttributeCollectionServer.Add($ParameterAttributeServer)

        $allUsers = Get-ADUser -Filter "CN -like '*'" -Properties Title, Department, Company
        $arrTitle = $allUsers | Sort-Object Title | Select-Object -ExpandProperty Title -Unique
        $arrDepartment = $allUsers | Sort-Object Department | Select-Object -ExpandProperty Department -Unique
        $arrCompany = $allUsers | Sort-Object Company | Select-Object -ExpandProperty Company -Unique
        $arrServer = [DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().GlobalCatalogs | Sort-Object name | Select-Object -ExpandProperty name -Unique

        $ValidateSetAttributeTitle = New-Object System.Management.Automation.ValidateSetAttribute($arrTitle)
        $ValidateSetAttributeDepartment = New-Object System.Management.Automation.ValidateSetAttribute($arrDepartment)
        $ValidateSetAttributeCompany = New-Object System.Management.Automation.ValidateSetAttribute($arrCompany)
        $ValidateSetAttributeServer = New-Object System.Management.Automation.ValidateSetAttribute($arrServer)

        $AttributeCollectionTitle.Add($ValidateSetAttributeTitle)
        $AttributeCollectionDepartment.Add($ValidateSetAttributeDepartment)
        $AttributeCollectionCompany.Add($ValidateSetAttributeCompany)
        $AttributeCollectionServer.Add($ValidateSetAttributeServer)

        $RuntimeParameterTitle = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterTitle, [string], $AttributeCollectionTitle)
        $RuntimeParameterDepartment = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterDepartment, [string], $AttributeCollectionDepartment)
        $RuntimeParameterCompany = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterCompany, [string], $AttributeCollectionCompany)
        $RuntimeParameterServer = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterServer, [string], $AttributeCollectionServer)

        $RuntimeParameterDictionary.Add($ParameterTitle, $RuntimeParameterTitle)
        $RuntimeParameterDictionary.Add($ParameterDepartment, $RuntimeParameterDepartment)
        $RuntimeParameterDictionary.Add($ParameterCompany, $RuntimeParameterCompany)
        $RuntimeParameterDictionary.Add($ParameterServer, $RuntimeParameterServer)

        return $RuntimeParameterDictionary
    }

    begin {
        # Bind the parameter to a friendly variable
        $title = $PsBoundParameters[$ParameterTitle]
        $Department = $PsBoundParameters[$ParameterDepartment]
        $Company = $PsBoundParameters[$ParameterCompany]
        $Server = $PsBoundParameters[$ParameterServer]
    }

    process {
        # Формируем переменную логин

        if ($PSCmdlet.ParameterSetName -eq 'File') {
            $ArrValues = (Get-Content -Path $Path).Split(";")

            $UserName = $ArrValues[0]
            $UserFamily = $ArrValues[1]
            $UserSurname = $ArrValues[2]
            $EmployeeID = $ArrValues[3]
            $phone = $ArrValues[4]
            $title = $ArrValues[5]
            $Department = $ArrValues[6]
            $Company = $ArrValues[7]
        }

        $login = (tools-Translale -inString $UserName) + "." + (tools-Translale -inString $UserFamily)
        # предлагаем автогенерированный логин
        Write-Host ("Automatic generate login: " + $login) -BackgroundColor DarkRed
        $newLogin = Read-Host -Prompt "Enter new name or press Enter for accept automatic value"
        if ($newLogin.Length -gt 0) {
            $login = $newLogin
        }
        
        $FN = $UserFamily + " " + $UserName

        $defaultPassword = New-StrongPassword -LengthPassword 10

        New-ADUser -Name $FN `
            -DisplayName ($UserFamily + " " + $UserName + " " + $UserSurname) `
            -GivenName $UserName `
            -Surname $UserFamily `
            -Department $Department `
            -Title $title `
            -UserPrincipalName ($login + "@abakan.medved-holding.com") `
            -SamAccountName $login `
            -Path $NUDN `
            -AccountPassword (ConvertTo-SecureString -String $defaultPassword -AsPlainText -Force) `
            -Company $Company `
            -Description $title `
            -OfficePhone $phone `
            -Enabled $true `
            -EmployeeID $EmployeeID `
            -Server $Server

        Write-Host $login $defaultPassword -BackgroundColor DarkYellow

        Write-AD-FillGroupMember($login)
        New-HomeDrive -UserLogin ($login)
        New-UserCard -UserLogin $login -Password $defaultPassword
    }
}

function Set-AD-ComputerName {
    param (
        [parameter(Mandatory = $true, Position = 2, HelpMessage = "Новое имя компьютера")][string]$newName,
        [parameter(Mandatory = $false, HelpMessage = "Перезагрузка")][Switch]$Force,
        [parameter(Mandatory = $false, HelpMessage = "Принудительное действие")][Switch]$Restart
    )

    DynamicParam {
        $Parameter = 'Name'
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $false
        $AttributeCollection.Add($ParameterAttribute)
        $arrSet = Get-ADComputer -Filter "CN -like '*'" -Properties name | Sort-Object name | Select-Object -ExpandProperty name -Unique
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
        $AttributeCollection.Add($ValidateSetAttribute)
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($Parameter, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($Parameter, $RuntimeParameter)
        return $RuntimeParameterDictionary
    }

    begin {
        $Name = $PsBoundParameters[$Parameter]
    }

    process {
        Rename-Computer -ComputerName $Name -NewName $newName -DomainCredential abakan\sergey.filimonov -Force:$Force -Restart:$Restart
        
    }
}

function Get-AD-Mail {
    param (
        [parameter(Mandatory = $false, DontShow)][string]$hidden
    )

    DynamicParam {
        $Parameter = 'Name'
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $false
        $AttributeCollection.Add($ParameterAttribute)
        $arrSet = Get-ADUser -Filter "CN -like '*'" -Properties name | Sort-Object name | Select-Object -ExpandProperty name -Unique
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
        $AttributeCollection.Add($ValidateSetAttribute)
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($Parameter, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($Parameter, $RuntimeParameter)
        return $RuntimeParameterDictionary
    }        

    begin {
        $Name = $PsBoundParameters[$Parameter]
    }

    process {
        $user = Get-ADUser -Filter "CN -eq '$Name'" -Properties *

        Write-Host $user.mail -BackgroundColor DarkRed

        Write-Host --Proxy servers--

        ForEach ($Proxy in $user.ProxyAddresses) {
            Write-Host ([string]$Proxy.ToLower().replace("smtp:", "")) -BackgroundColor DarkGreen
        }
    }
}

function Get-AD-Computer {
    param (
        [parameter(Mandatory = $false, DontShow)][string]$hidden
    )

    DynamicParam {
        $Parameter = 'Name'
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $false
        $AttributeCollection.Add($ParameterAttribute)
        $arrSet = Get-ADComputer -Filter "CN -like '*'" -Properties name | Sort-Object name | Select-Object -ExpandProperty name -Unique
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
        $AttributeCollection.Add($ValidateSetAttribute)
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($Parameter, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($Parameter, $RuntimeParameter)
        return $RuntimeParameterDictionary
    }        

    begin {
        $Name = $PsBoundParameters[$Parameter]
    }

    process {
        return $Name
    }
}

function Write-AD-FillGroupMember {
    param (
        # Parameter help description
        [Parameter(Mandatory = $true, Position = 1)]
        [string]
        $UserLogin
    )

    $user = Get-ADUser $UserLogin -Properties Department

    $company = $user.Company
    $Department = $user.Department

    Write-Verbose -Message ("User Department: " + $Department)

    # Выбор организациив ременно отключен за ненадобностью. Изменение внесено в переменню $GoupName ниже по тексту в пределах данной функции

    switch ($Department) {
        "IT-отдел" { $DepartmentPrefix = "IT" }
        "Бухгалтерия" { $DepartmentPrefix = "BUH" }
        "Клиентская служба" { $DepartmentPrefix = "CLIENT" }
        "Отдел продажи запасных частей №1" { $DepartmentPrefix = "OPZCH1" }
        "Отдел продажи запасных частей №1" { $DepartmentPrefix = "OPZCH2" }
        "Отдел кадров" { $DepartmentPrefix = "KADR" }
        "Отдел продаж легковых авто №1" { $DepartmentPrefix = "OPLA1" }
        "Отдел продаж легковых авто №2" { $DepartmentPrefix = "OPLA2" }
        "Отдел продаж подержанных автомобилей" { $DepartmentPrefix = "OPPA" }
        "Склад" { $DepartmentPrefix = "SKLAD" }
        "Служба сервиса" { $DepartmentPrefix = "SS" }
        "Снабжение" { $DepartmentPrefix = "SNAB" }
        "Управление" { $DepartmentPrefix = "MNG" }
        "Цех дополнительного оборудования" { $DepartmentPrefix = "CDO" }
        "Цех технического обслуживания и ремонта" { $DepartmentPrefix = "CTOIR" }
        "Маляроно-кузовной цех" { $DepartmentPrefix = "MKC" }
	
    }

    $GroupName = "18-SG-ORG-" + $DepartmentPrefix

    Write-Verbose -Message ("Group Name: " + $GroupName)

    Add-ADGroupMember -Identity $GroupName -Members $user.samaccountname
    # Обязательное добавление в группы
    Add-ADGroupMember -Identity 18-SG-AS-OTRSUsers -Members $user.samaccountname        # 18-sg-as-otrsusers
    Add-ADGroupMember -Identity 18-DG-INF-AllUsers -Members $user.samaccountname        # 18-DG-INF-AllUsers
}    

function New-HomeDrive {
    param (
        [Parameter(Mandatory = $true, Position = 1)]
        [String]
        $UserLogin
    )

    $ParentDirectory = "\\S18-FS02\homes$\"
    $FullPath = $ParentDirectory + $UserLogin

    Write-Verbose -Message ("Full Path: " + $FullPath)

    if (!(Test-Path -Path $FullPath)) {
        New-Item -Path $FullPath -ItemType Directory -Force
        New-Item -Path ($FullPath + "\!scan\") -ItemType Directory -Force
        Add-NTFSAccess -Path $FullPath -Account $UserLogin -AccessRights FullControl -AppliesTo ThisFolderSubfoldersAndFiles
    }

}

function New-WorkDrive {
    param (
        [Parameter(Mandatory = $true, Position = 1)]
        [string]
        $UserLogin
    )

    $ParentDirectory = "\\ABAKAN\dfs\Departments\"
    $objAD = Get-ADUser $UserLogin -Properties *
    $Name = $objAD.Name

    switch ($objAD.Department) {
        "IT-отдел" { $pathDep = "IT-отдел" }
        "Бухгалтерия" { $pathDep = "Бухгалтерия" }
        "Клиентская служба" { $pathDep = "Клиентская служба" }
        "Маляроно-кузовной цех " { $pathDep = "МКЦ" }
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

    Write-Verbose -Message ("Full Path: " + $fullpath)
    if (!(Test-Path -Path ($fullpath))) {
        New-Item -Path $fullpath -ItemType Directory
        Add-NTFSAccess -Path $fullpath -Account $UserLogin -AccessRights Modify -AppliesTo ThisFolderSubfoldersAndFiles
    }
}

function Remove-AD-User {
    param (
        [Parameter(Mandatory = $true, Position = 1)][string]$UserLogin,
        [Parameter(Mandatory = $false)][switch]$DisableMailbox
    )
    $date = [datetime]::Now
    
    if ($DisableMailbox) {
        $session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "http://post.zapad.medved-holding.com/powershell/" -Authentication Kerberos
        Import-PSSession $session -DisableNameChecking
        Set-AdServerSettings -ViewEntireForest $true
        
        Get-Mailbox -Database ABAKAN -Filter "Alias -eq '$user.samaccountname'" | Disable-Mailbox -Confirm:$False
    }
    
    $user = Get-ADUser $UserLogin
    Move-ADObject $user -TargetPath "OU=Users,OU=Disabled,OU=ABAKAN,DC=abakan,DC=medved-holding,DC=com" -Verbose:$PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent
    Set-ADUser $user.samaccountname -Enabled $false -Description ("Заблокирован " + $date.ToShortDateString() + " " + $date.ToShortTimeString() + ". " + $user.description) -Verbose:$PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent
}

function Set-AD-thumbnailPhoto {
    param (
        # Имя пользователя
        [Parameter(Mandatory = $true, Position = 1)]
        [string]
        $sAMAccountName,

        # Путь до фотографии
        [Parameter(Mandatory = $true, Position = 2)]
        [String]
        $Path
    )

    [byte]$photo = Tools-ResizePhoto -imageSource $Path -canvasSize 96 -quality 100

    $user = Get-ADUser -Filter "$sAMAccountName -eq '$sAMAccountName'" -Properties thumbnailPhoto
    Set-ADUser -Identity $user -Replace @{thumbnailPhoto = $photo }
}

function Get-AD-WhoLocked {
    param(
        [Parameter(Mandatory = $true, Position = 1)]
        [String]
        $sAMAccountName
    )

    Clear-Host

    $hash = @{
        LogName = 'Security'
        id      = @("4740", "4625", "4741")
        Data    = $sAMAccountName
    }   

    $Events = Get-WinEvent -FilterHashtable $hash -ComputerName "DC5ABAKAN"

    foreach ($Event in $Events) {
        Write-Host $Event.TimeCreated $Event.Id $Event.OpcodeDisplayName -BackgroundColor DarkRed
        $Event.Message
    }

    Write-Host Найдено ($Events | Measure-Object).Count записей -BackgroundColor DarkGreen
}

function New-UserCard {
    param (
        [Parameter(Mandatory = $true, Position = 1, HelpMessage = 'Логин пользователя')][string]$UserLogin,
        [Parameter(Mandatory = $true, Position = 2, HelpMessage = 'Пароль')][string]$Password
    )

    $AdminPath = "\\abakan\dfs\Departments\IT-отдел\!Общая\CARDs\"
    $HomePath = "\\ABAKAN\dfs\Homes\" + $UserLogin + "\"

    $tmplFile = "\\abakan\dfs\Departments\IT-отдел\!Общая\CARDs\_Template.dotx"
    #    $tmplFile = ".\_Template.dotx"	

    $word = New-Object -ComObject Word.Application
    $doc = $word.Documents.add($tmplFile)
    
    $objUser = Get-ADUser $UserLogin -Properties *

    for ($i = 1; $i -le $doc.Fields.Count; $i++) {
        switch (($doc.Fields($i).Code.Text).trim()) {
            "FIO" { $doc.Fields($i).result.text = $objUser.Name }
            "sAMAccountName" { $doc.Fields($i).result.text = $UserLogin }
            "password" { $doc.Fields($i).result.text = $Password }
            "mail" { $doc.Fields($i).result.text = $UserLogin + "@medved-abakan.ru" }
            "company" { $doc.Fields($i).result.text = $objUser.company }
            "department" { $doc.Fields($i).result.text = $objUser.department }
            "title" { $doc.Fields($i).result.text = $objUser.Title }
            "employeeID" { $doc.Fields($i).result.text = $objUser.employeeID }
        }
    }

    $doc.SaveAs([ref]($AdminPath + $UserLogin + ".pdf"), [ref][Microsoft.Office.Interop.Word.WdSaveFormat]::wdFormatPDF)
    $doc.SaveAs([ref]($HomePath + $UserLogin + ".pdf"), [ref][Microsoft.Office.Interop.Word.WdSaveFormat]::wdFormatPDF)
    $doc.Close([ref]$false)
    $word.Quit([ref]$false)
}