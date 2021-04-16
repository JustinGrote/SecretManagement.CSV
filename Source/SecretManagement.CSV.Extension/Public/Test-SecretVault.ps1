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
    Write-Host -Fore Magenta 'Testing the vault!'

    if (-not $Quick) {
        Write-Host -Fore Magenta 'No -Quick found, lets do a detailed check!'
    }
    # return [TestStore]::TestVault()
    return $true
}