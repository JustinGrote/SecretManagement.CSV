. $PSScriptRoot/../Tests/Shared.ps1
$FunctionName = ([String]($MyInvocation.MyCommand)).split('.')[0]
Describe $FunctionName -Tag 'Unit' {
    BeforeAll {
        #Load the function into the testing scope
        . ($MyInvocation.MyCommand.ScriptBlock.File -replace '\.Tests\.ps1$','.ps1')

        #Load Required Dependent Functions. You could also mock them.
        . $PSScriptRoot/../Private/Test-VaultParameters.ps1
    }
    BeforeEach {
        #Initialize a new variable
        $VaultPath = New-Item -Path "TestDrive:$(New-Guid).csv"
        Copy-Item $Mocks/SingleEntry.csv $VaultPath -Force
        $VaultParams = @{
            Vault = 'PesterVault'
            AdditionalParameters = @{
                Path = $VaultPath
            }
        }
    }
    It 'Reads the Secret Successfully' {
        $secretResult = Get-Secret @VaultParams -Name 'PesterSecret'
        $secretResult | Should -BeOfType [string]
        $secretResult | Should -Be 'S3cret123!'
    }
}