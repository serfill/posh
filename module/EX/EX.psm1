function EX-DownloadPST()
{
    param (
        [parameter (Mandatory=$false)][switch]$IsArchive
    )

    DynamicParam {
        $Parameter = 'Name'
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $false
        $AttributeCollection.Add($ParameterAttribute)
        $arrSet = Get-Mailbox -Database "ABAKAN" | Sort-Object Name | Select-Object -ExpandProperty Name -Unique
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
        
    }
}

function Add-EX-User {

    #Requires -Module Tools
    param (
        # Имя пользователя
        [Parameter(Mandatory=$true)]
        [string]
        $UserName
    )

    Tools-ExchangeConnect()

    
    
}




}