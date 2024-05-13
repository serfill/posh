function Tools-Translale
{
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

function Tools-ConnectTo {
        param (
        [parameter(Mandatory=$false,DontShow)][string]$hidden
    )

     DynamicParam {
            $Parameter = 'ComputerName'
            $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
            $ParameterAttribute.Mandatory = $false
            $AttributeCollection.Add($ParameterAttribute)
            $arrSet = Get-ADComputer -Filter "CN -like '*'" -Properties name | Sort-Object name | select-object -ExpandProperty name -Unique
            $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
            $AttributeCollection.Add($ValidateSetAttribute)
            $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($Parameter, [string], $AttributeCollection)
            $RuntimeParameterDictionary.Add($Parameter, $RuntimeParameter)
            return $RuntimeParameterDictionary
    }        

    begin {
        $ComputerName = $PsBoundParameters[$Parameter]
    }

    process {
        Start-Process msra -ArgumentList ("/offerra " + $ComputerName)
    }
}

function Tools-GetVM {
    param (
        [parameter(Mandatory=$false)][switch]$off,
        [parameter(Mandatory=$false)][switch]$on
    )


    $session = New-PSSession -ComputerName HV1abakan, HV2abakan

    if($on) {
        $res = Invoke-Command -Session $session -ScriptBlock {get-vm} | Where-Object {$_.state -eq "Running"} | select ComputerName, Name, State, Status, Uptime
    } elseif ($off) {
        $res = Invoke-Command -Session $session -ScriptBlock {get-vm} | Where-Object {$_.state -eq "Off"} | select ComputerName, Name, State, Status, Uptime
    } elseif (($on+$off -eq 0) -or ($on + $off -eq 2)) {
        $res = Invoke-Command -Session $session -ScriptBlock {get-vm} | select ComputerName, Name, State, Status, Uptime
    }

    $res | ft
    
    Remove-PSSession -Session $session
}

function Tools-CheckSpeed {
    param (
        [parameter(Mandatory=$true,Position=1)][string]$ComputerName
    )

    $wmiobj = Get-WmiObject -ComputerName $ComputerName -Query "Select * From Win32_OperatingSystem where ProductType='1'"
    
    if ($wmiobj) {
        $razr = $wmiobj.OSArchitecture.Substring(0,2)

        if ($razr -eq 32) {
            $source = "D:\soft\iperf\x86\*"
        }
        if ($razr -eq 64) {
            $source = "D:\soft\iperf\x64\*"
        }

        $filename = $ComputerName + "_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".txt"
        $target = "\\" + $ComputerName + "\" + $wmiobj.SystemDirectory.Replace(":", "$")
        $resFile = "\\" + $ComputerName + "\" + $wmiobj.SystemDrive.Replace(":", "$") + "\" + $filename

        Copy-Item -Path $source -Destination $target

        $s = New-PSSession -ComputerName $ComputerName
        Invoke-Command -Session $s -ScriptBlock {iperf.exe -c 192.168.10.16 -P 8 -t 10 -w 32768 >> c:\iperf.txt}
        Remove-PSSession -Session $s

        Move-Item -Path ("\\" + $ComputerName + "\" + $wmiobj.SystemDrive.Replace(":", "$") + "\iperf.txt") -Destination "D:\123" -Force  
        Rename-Item -Path "D:\123\iperf.txt" -NewName $filename -Force
    }
}

function Tools-RestartComputer {
        param (
        [parameter(Mandatory=$false,DontShow)][string]$hidden,
        [parameter(Mandatory=$true)][string]$date
    )

     DynamicParam {
            $Parameter = 'Name'
            $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
            $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
            $ParameterAttribute.Mandatory = $false
            $AttributeCollection.Add($ParameterAttribute)
            $arrSet = Get-ADComputer -Filter "CN -like '*'" -Properties name | Sort-Object name | select-object -ExpandProperty name -Unique
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

        # return $date
        $d = Get-Date($date)
        $sec =  [math]::Round((New-TimeSpan -Start ([datetime]::Now) -End $d).TotalSeconds, 0)

        Start-Process -FilePath "shutdown" -ArgumentList ("-f -r -m \\" + $Name + " -t " + $sec)
    }    
}

Function Tools-ExchangeConnect {
    $session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "http://post.zapad.medved-holding.com/powershell/" -Authentication Kerberos
    Import-PSSession $session -DisableNameChecking
    Set-AdServerSettings -ViewEntireForest $true
}

Function Tools-ResizePhoto(){
    Param ( [Parameter(Mandatory=$True)] [ValidateNotNull()] $imageSource,
    [Parameter(Mandatory=$true)][ValidateNotNull()] $canvasSize,
    [Parameter(Mandatory=$true)][ValidateNotNull()] $quality )
  

    
    # проверки
    if (!(Test-Path $imageSource)){throw( "Файл не найден")}
    if ($canvasSize -lt 10 -or $canvasSize -gt 1000){throw( " Параметр размер должен быть от 10 до 1000")}
    if ($quality -lt 0 -or $quality -gt 100){throw( " Параметр качества должен быть от 0 до 100")}
    
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
    
    $imageBytes = [byte[]](Get-Content $imageSource -Encoding byte)
    $ms = New-Object IO.MemoryStream($imageBytes, 0, $imageBytes.Length)
    $ms.Write($imageBytes, 0, $imageBytes.Length);
    
    $bmp = [System.Drawing.Image]::FromStream($ms, $true)
    
    # разрешение картинки после конвертации
    $canvasWidth = $canvasSize
    $canvasHeight = $canvasSize
    
    # Задание качества картинки
    $myEncoder = [System.Drawing.Imaging.Encoder]::Quality
    $encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
    $encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter($myEncoder, $quality)
    #Получаем тип картинки
    $myImageCodecInfo = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders()|where {$_.MimeType -eq 'image/jpeg'}
    
    # Высчитывание кратности
    $ratioX = $canvasWidth / $bmp.Width;
    $ratioY = $canvasHeight / $bmp.Height;
    $ratio = $ratioY
    if($ratioX -le $ratioY){
        $ratio = $ratioX
    }
    
    # Создание пустой картинки
    $newWidth = [int] ($bmp.Width*$ratio)
    $newHeight = [int] ($bmp.Height*$ratio)
    $bmpResized = New-Object System.Drawing.Bitmap($newWidth, $newHeight)
    $graph = [System.Drawing.Graphics]::FromImage($bmpResized)
    
    $graph.Clear([System.Drawing.Color]::White)
    $graph.DrawImage($bmp,0,0 , $newWidth, $newHeight)
    
    # Создание пустого потока
    $ms = New-Object IO.MemoryStream
    $bmpResized.Save($ms,$myImageCodecInfo, $($encoderParams))
    
    # уборка
    $bmpResized.Dispose()
    $bmp.Dispose()
    
    return [byte]$ms.ToArray()
    }

Function Restart-TSD
{
    $RemoteScript = {
        Stop-Service -Name '1C driver server PROF'
        Get-Process -Name dllhost | Stop-Process -Force
        Start-Service -Name '1C driver server PROF'
    }
    Invoke-Command -ComputerName 1cabakan -ScriptBlock $RemoteScript
}