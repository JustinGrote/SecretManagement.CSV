function Set-SecretInfo {
    [CmdletBinding()]
    param (
        #Passed in from Set-Secret -Name
        [Parameter(Mandatory)]
        [string]$Name,

        #Passed in from Set-SecretInfo -Metadata
        [Parameter(Mandatory)]
        [hashtable]$Metadata,

        #The VaultName of the secret, passed through from SecretManagement module
        [Parameter(Mandatory)]
        [Alias('Vault')]
        [string]$VaultName,

        #Passed in from SecretManagement registered VaultParameters. 
        [Parameter(Mandatory)]
        [Alias('VaultParameters')]
        [hashtable]$AdditionalParameters
    )

    Test-VaultParameters $AdditionalParameters

    #We want to bail on errors to avoid issues, but still follow what the SecretManagement api wants
    #Which is to return false and not an exception
    $ErrorActionPreference = 'Stop'
    trap {
        Write-Error $PSItem
        return $false
    }

    #Check that the metadata is in our supported list
    $metadata.keys.foreach{
        if ($PSItem -notin 'Comment','SomeOtherMetadataYetToBeImplemented') {
            throw [NotSupportedException]"Metadata property $PSItem is not supported to be set with this vault"
        }
    }

    #Lets see if our secret exists. We can re-use our Get-SecretInfo function for this purpose.
    #Because we are "in the module" at this point this will call our internal Get-SecretInfo function,
    #Not the Microsoft.Powershell.SecretManagement wrapper

    #A third time! This really would make sense as some sort of separate private function wouldn't it?
    $SecretParams = @{
        Name = $Name
        VaultName = $VaultName
        AdditionalParameters = $AdditionalParameters
    }
    $secretInfoResult = Get-SecretInfo @SecretParams

    if (-not $SecretInfoResult) {
        throw "${VaultName}: $Name was not found as a secret"
    }

    #If our data exists we will update the metadata
    $csvData = Import-CSV -Path $AdditionalParameters.Path

    $secretEntry = $csvData | Where-Object Name -eq $Name

    #Loop through our metadata and set it. 
    $metadata.keys.foreach{
        $secretEntry.$PSItem = $metadata[$PSItem]
    }
    #We don't let the modified date metadata be modified, its automatic as things are updated
    $secretEntry.Modified = Get-Date

    #Write out our updated vault info
    Write-Host -Fore Cyan 'Updating Secret Metadata!'
    $csvData | Export-CSV -NoTypeInformation -Path $AdditionalParameters.Path
    return $true
}