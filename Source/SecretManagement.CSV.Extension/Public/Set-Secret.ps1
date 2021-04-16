function Set-Secret {
    [CmdletBinding()]
    param (
        #Passed in from Set-Secret -Name
        [Parameter(Mandatory)]
        [string]$Name,

        #Passed in from Set-Secret -Secret or -SecureStringSecret
        #Supported types as of 1.0 GA are:
            # byte[]
            # string
            # SecureString
            # PSCredential
            # Hashtable
        #So you should error if any other type is provided
        [Parameter(Mandatory)]
        [object]$Secret,

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
    Write-Host -Fore Cyan 'Setting our Secret! (Todo)'

    return $false
}