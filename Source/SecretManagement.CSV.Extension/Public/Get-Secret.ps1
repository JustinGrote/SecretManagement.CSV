function Get-Secret {
    [CmdletBinding()]
    param (
        #The name of the secret, passed through from Get-Secret -Name
        [Parameter(Mandatory)]
        [string]$Name,

        #The VaultName of the secret, passed through from SecretManagement module
        [Parameter(Mandatory)]
        [Alias('Vault')]
        [string]$VaultName,

        #Passed in from SecretManagement registered VaultParameters.
        [Parameter(Mandatory)]
        [Alias('VaultParameters')]
        [hashtable]$AdditionalParameters
    )

    Write-Host -Fore Cyan "Getting a secret named $Name in $VaultName!"

    #We want to "fail fast" if there's a problem and not return potentially erroneous results
    $ErrorActionPreference = 'Stop'

    #Our Custom Private Method to make sure our parameters are OK
    Test-VaultParameters $AdditionalParameters

    #Load our CSV
    $CSVPath = $AdditionalParameters.Path #This comes from Register-SecretVault -VaultParameters @{Path=path/to/my.csv}
    [Object[]]$csvData = Import-Csv $CSVPath

    #See if our secret exists and fail if it doesn't
    if ($Name -notin $csvData.Name) {
        throw "Secret $Name not found in vault $VaultName, sorry!"
    }

    #If the above didn't fail we can assume the secret is there and we can return it
    [object[]]$secretInfo = $csvData | 
        Where-Object Name -eq $Name

    #You should return one and only one secret!
    if ($secretInfo.count -ne 1) {
        throw "Uh oh! We found duplicate secrets with the name $Name!"
    }

    #Only Supporting String for now as a secret, you could easily do more!
    return [String]$secretInfo.Secret
}