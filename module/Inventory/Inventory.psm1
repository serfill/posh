function Inv-GetComputerInfo {
    param ([parameter (Mandatory=$true,Position=1,HelpMessage="Имя компьютера")][string]$ComputerName)

    if (Test-Connection -ComputerName $ComputerName -Quiet -Count 1)
    {
        $OS = Get-WmiObject -ComputerName $ComputerName -Query "Select * from Win32_OperatingSystem"
        $NET = Get-WmiObject -ComputerName $ComputerName -Query "Select * from Win32_NetworkAdapterConfiguration where IPEnabled = true and DNSDomain like '%medved-holding.com'"
        $BaseBoard = Get-WmiObject -ComputerName $ComputerName -Query "SELECT * from Win32_Baseboard"
        $PhysicalMemory = Get-WmiObject -ComputerName $ComputerName -Query "Select * from Win32_PhysicalMemory"
        $DiskDrive = Get-WmiObject -ComputerName $ComputerName -Query "Select * from Win32_DiskDrive where size > 0"
        $HotFix = Get-WmiObject -ComputerName $ComputerName -Query "Select * from win32_QuickFixEngineering"
    
        $props = @{
            ComputerName = $ComputerName
            OSCaption = $OS.Caption
            OSBuildNumber = $OS.BuildNumber
            OSVersion = $OS.Version
            OSSystemDrive = $OS.SystemDrive
            OSWindowsDirectory = $OS.WindowsDirectory
            NetIPAddress = $NET.IPAddress
            NetDescription = $net.Description
            NetDHCPEnabled = $net.DHCPEnabled
            NetDNSDomain = $net.DNSDomain
            NetMACAddress = $net.MACAddress
            BaseBoardManufacturer = $BaseBoard.Manufacturer
            BaseBoardSN = $BaseBoard.SerialNumber
            BaseBoardProduct = $BaseBoard.Product
            PhysicalMemoryTotalCapacity = ($PhysicalMemory.Capacity | Measure-Object -Sum).Sum
            PhysicalMemoryTotalCount = ($PhysicalMemory.capacity | Measure-Object).Count
            DiskDrive = $DiskDrive | Select-Object -Property Partitions, Model, Size
            Hotfix = $HotFix | Select-Object -Property HotFixID, Description, InstalledOn

        }

        $obj = New-Object -TypeName PSObject -Property $props

        $obj
    } else {
        Write-Host Нет подключения к рабочей станции $ComputerName -BackgroundColor DarkRed
    }

}
function Inv-GetFreeSpace {
        param ([parameter (Mandatory=$true,Position=1,HelpMessage="Имя компьютера")][string]$ComputerName)

        Get-WmiObject -Class Win32_logicalDisk -ComputerName $ComputerName | Where-Object {$_.Size -gt 0} | ft -Property DeviceID, `
@{Label="Free (GB)"; Expression={[math]::Round($_.FreeSpace/1Gb, 2)}}, `
@{Label="Total (GB)"; Expression={[math]::Round($_.Size/1Gb)}}, `
@{Label="Percent"; Expression={[math]::Round($_.FreeSpace / $_.Size * 100, 2)}}

}