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

        #Optional Metadata to set, if provided
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

    #For now we are only supporting the string type, but now is a good time to test and error if you don't support a particular type.
    #We don't cast to string because lots of types e.g. securestring will not store correctly because casting to string is so ubiquitous.
    if ($Secret -isnot [String]) {
        Write-Error "${VaultName}: Only Strings are supported as secrets with this extension vault, sorry!"
        return $false
    }

    #Lets see if our secret exists. We can re-use our Get-SecretInfo function for this purpose.
    #Because we are "in the module" at this point this will call our internal Get-SecretInfo function,
    #Not the Microsoft.Powershell.SecretManagement wrapper
    $SecretParams = @{
        Name = $Name
        VaultName = $VaultName
        AdditionalParameters = $AdditionalParameters
    }
    $secretInfoResult = Get-SecretInfo @SecretParams

    #If our data exists we will update it, otherwise we will create new
    if ($secretInfoResult) {
        $csvData = Import-CSV -Path $AdditionalParameters.Path

        $secretEntry = $csvData | Where-Object Name -eq $Name

        #Update to the latest date
        $secretEntry.Secret = $Secret
        $secretEntry.Modified = Get-Date

        #Write out our updated vault info
        $csvData | Export-CSV -NoTypeInformation -Path $AdditionalParameters.Path
    } else {
        #We can assume the data didn't exist at this point so we will create it
        

        #This would be a good time to use a class to make sure all the info is included and do sanity checks
        #For now we'll just be very careful to include all the properties we need.
        #We will also use the fancy convertto-csv to get the entry so we can just append it to the end of the file rather
        #than reading the whole thing in, and we will skip the header line
        $newEntry = [PSCustomObject][Ordered]@{
            Name = $Name
            Secret = $Secret
            Modified = Get-Date
            Comment = $null
        }
        Write-Host -Fore Cyan 'Setting our Secret!'

        #An arraylist will make it faster to add data rather than +=
        $csvData = [Collections.ArrayList]::new(@(Import-CSV -Path $AdditionalParameters.Path))
        [void]$csvData.Add($newEntry)
        $csvData | Export-CSV -NoTypeInformation -Path $AdditionalParameters.Path
    }

    #If metadata was provided we will update that too. 
    #Hey, we already have another function that does that for us!
    #We also already have a splat we can reuse!
    Set-SecretInfo @secretParams -Metadata $Metadata

    #If we make it this far, then we can assume it succeded! You can also do some additional validation if you want
    return $true
}