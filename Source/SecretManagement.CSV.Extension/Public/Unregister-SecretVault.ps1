function Unregister-SecretVault {
    [CmdletBinding()]
    param (
        #Passed in from Unregister-SecretVault -Name
        [Parameter(Mandatory)]
        [Alias('Name')]
        [string]$VaultName,

        #Passed in from Unregister-SecretVault -Name
        [hashtable]$AdditionalParameters
    )
    Write-Host -Fore DarkCyan "Aww you unregistered our vault. We will clean it up for you. Sad panda!"

    # Perform optional work to extension vault before it is unregistered
}