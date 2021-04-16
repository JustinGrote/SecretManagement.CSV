function Remove-Secret {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        #Passed in from Remove-Secret -Name
        [Parameter(Mandatory)]
        [string]$Name,

        #The VaultName of the secret, passed through from SecretManagement module
        [Parameter(Mandatory)]
        [Alias('Vault')]
        [string]$VaultName,

        #Passed in from SecretManagement registered VaultParameters
        [Parameter(Mandatory)]
        [Alias('VaultParameters')]
        [hashtable]$AdditionalParameters = (Get-SecretVault -Name $VaultName).VaultParameters
    )

    #We want to bail on errors to avoid issues, but still follow what the SecretManagement api wants
    #Which is to return false and not an exception
    $ErrorActionPreference = 'Stop'
    trap {
        Write-Error $PSItem
        return $false
    }

    #Lets see if our secret exists. We can re-use our Get-SecretInfo function for this purpose.
    #Because we are "in the module" at this point this will call our internal Get-SecretInfo function,
    #Not the Microsoft.Powershell.SecretManagement wrapper

    #Hey, wait a minute, didn't we already write this once before in Set-Secret? Might be a good thing to refactor into a private function!
    $SecretParams = @{
        Name = $Name
        VaultName = $VaultName
        AdditionalParameters = $AdditionalParameters
    }
    $secretInfoResult = Get-SecretInfo @SecretParams

    if (-not $secretInfoResult) {
        Write-Error "${VaultName}: Secret $Name doesn't exist to remove."
    }

    #Lets read the data, omit the line, and then export it back
    Write-Host -Fore Cyan "Oh my! Removing secret $Name from $VaultName"

    $csvData = Import-CSV $AdditionalParameters.Path
    $csvData | 
        Where-Object Name -ne $Name | 
        Export-CSV -Path $AdditionalParameters.Path
    #If for some reason we get here, we should assume we failed.
    return $false
}