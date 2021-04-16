function Test-SecretVault {
    [CmdletBinding()]
    param (
        #Passed in from Test-SecretVault -Name
        [Parameter(Mandatory)]
        [Alias('Name')]
        [string]$VaultName,
        
        #Passed in from SecretManagement registered VaultParameters. 
        [Parameter(Mandatory)]
        [Alias('VaultParameters')]
        [hashtable]$AdditionalParameters,

        #NOTE: This is an example of a custom internal parameter you can use when you have your internal commands calling each other
        #You can add more parameters here if you wish, and they will only be seen when calling the commands internally.
        #For example you could add a [Switch]$Quick parameter to do a quick test before every cmdlet that the vault is still there
        [Switch]$Quick
    )

    #Here is where you should test a vault
    Write-Host -Fore Cyan 'Testing the vault!'

    if (-not (Test-Path $($AdditionalParameters.Path))) {
        Write-Error "${VaultName} Vault not found at $($AdditionalParameters.Path)"
        return $false
    }

    Write-Host -Fore Cyan "Yep, the file still exists at $($AdditionalParameters.Path)"
    if (-not $Quick) {
        Write-Host -Fore Cyan 'No -Quick found, lets do a detailed check!'
        $csvData = Import-Csv $AdditionalParameters.Path -ErrorAction Stop
        if ($null -eq $csvData) {
            Write-Warning "${VaultName} file was found but it has no data. This is normal if you created a new vault"
        }
        try {
            $mydata = $csvData | ConvertFrom-CSV -ErrorAction Stop
        } catch {
            Write-Error "${VaultName}: $($AdditionalParameters.Path) is not in a CSV format, it may be corrupted"
            return $false
        }
        if ($myData) {return $true}
        #TODO: Maybe some additional testing to make sure the right fields exist
    }

    return $false
}