$ErrorActionPreference = 'Stop'
BeforeAll {
    #Make sure secretmanagement isn't loaded so we don't get clobbered commands
    Get-Module 'Microsoft.Powershell.SecretManagement' -ErrorAction 'SilentlyContinue' | Remove-Module
    #Import our underlying Vault Extension
    $Mocks = Resolve-Path $PSScriptRoot/Mocks
}