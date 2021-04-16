function Remove-Secret {
    [CmdletBinding()]
    param (
        #Passed in from Remove-Secret -Name
        [Parameter(Mandatory)]
        [string]$Name,

        #The VaultName of the secret, passed through from SecretManagement module
        [Parameter(Mandatory)]
        [Alias('Vault')]
        [string]$VaultName,

        #Passed in from SecretManagement registered VaultParameters. 
        [Parameter(Mandatory)]
        [Alias('VaultParameters')]
        [hashtable]$AdditionalParameters = (Get-SecretVault -Name $VaultName).VaultParameters
    )
    Write-Host -Fore Red "Uh Oh, removing secret $Name from $VaultName with Additional Parameters: $AdditionalParameters"

    # return [TestStore]::RemoveItem($Name)
    return $false
}