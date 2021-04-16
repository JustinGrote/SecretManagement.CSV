using namespace Microsoft.Powershell.SecretManagement
#The using statement above means we can simply just use [SecretInformation] instead of the really long name.
function Get-SecretInfo {
    [CmdletBinding()]
    param (
        #Filter that is defined however you want to handle it. Recommend wildcards.
        #If this is blank, you should assume the user wants to get all secretinfos in the vault
        #This is passed in from Get-SecretInfo -Name. Note it is named different!
        [Alias('Name')]
        [string]$Filter,

        #The VaultName of the secret, passed through from SecretManagement module
        [Parameter(Mandatory)]
        [Alias('Vault')]
        [string]$VaultName,
        
        #Passed in from SecretManagement registered VaultParameters. 
        [Parameter(Mandatory)]
        [Alias('VaultParameters')]
        [hashtable]$AdditionalParameters = (Get-SecretVault -Name $VaultName).VaultParameters
    )

    Test-VaultParameters

    Write-Host -Fore Cyan 'Getting Secret Info!'

    #Read in our CSV
    $csvData = Import-CSV $AdditionalParameters.Path

    #If we have a filter, go ahead and filter by that name. We will use Like so that wildcards can be used
    $secretInfoMatch = $csvData | Where-Object Name -Like $Filter

    #If we have no results, nothing more to do!
    if (-not $SecretInfoMatch) {return}

    #If we do have results, lets take our info and convert them into SecretInformation objects
    #This is a great opportunity for a Powershell class or a Convert-CSVToSecretInformation function

    foreach ($secretInfoItem in $secretInfoMatch) {
        #First we need a name
        [String]$secretName = $secretInfoItem.Name
        #Then we need to report what kind of data it is. Since our vault only supports strings that makes this part easy.
        [SecretType]$secretType = 'String'
        
        #If we have metadata, we want to make a hashtable of that information. In this case we do, otherwise it can just be $null
        $Metadata = @{
            Modified = [DateTime]$secretInfoItem.Modified #We can return in any type we want, for the most part
            Comment  = $secretInfoItem.Comment
        }
        
        #Now we will make our secret info object and output it.
        #View the available list of SecretInformation constructors with [SecretInformation]::new
        [SecretInformation]::new(
            $secretName,      # Name of secret
            $secretType,      # Secret data type [Microsoft.PowerShell.SecretManagement.SecretType]
            $VaultName,       # The name of our vault, provided as a parameter by Secret Management
            $metadata         # The metadata of our vault as expressed as a hashtable.
        )
    }

}
