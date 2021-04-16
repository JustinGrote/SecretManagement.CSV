Describe 'FreezingBug' {
    BeforeAll {
        $modulePath = 'C:\Users\JGrote\Projects\SecretManagement.CSV\Source\SecretManagement.CSV.psd1'
        Import-Module $ModulePath -force
        Register-SecretVault -Name 'MyTestVault' -ModuleName $modulePath -VaultParameters @{
            Path='ok'
        }
    }
    AfterAll {
        Unregister-SecretVault -Name 'MyTestVault'
    }

    It 'Runs' {}
}