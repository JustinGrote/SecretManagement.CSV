function Test-VaultParameters ([hashtable]$VaultParameters) {
    #Simple Internal Sanity Check Function to make sure vault parameters are what we expect
    
    #Our only parameter is Path so we should be good

    $VaultParameters.keys.foreach{
        if ($PSItem -notin 'Path','Verbose') {
            Write-Warning "Unrecognized Vault Parameter $PSItem defined. Please re-register this vault"
        }
    }
}