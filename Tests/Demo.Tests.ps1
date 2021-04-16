#requires -version 7
#Because: Kusto-Style Pipelines
Describe 'CSV Vault Demo' {
    BeforeAll {
        #First Import our Module
        $moduleRoot = Resolve-Path $PSScriptRoot/../Source
        $moduleManifest = Resolve-Path $moduleRoot/SecretManagement.CSV.psd1
        $mocks = Resolve-Path $PSScriptRoot/Mocks
        Import-Module $ModuleManifest -force

        #Lets "Pause" each time we hit a Secret Management Command
        # $SMCommands = (Get-Command -module 'microsoft.powershell.secretmanagement').Name 
        # | Where-Object {$_ -notmatch 'register'}
        
        # Set-PSBreakpoint -Command $SMCommands -Action {
        #     Write-Host -Fore DarkYellow -Back DarkCyan "PAUSE: $PSItem";break
        # }

        #Then register our test vaults. Registration only saves the vault info into the vault metadata file
        #You can't do any kind of validation on this at registration time, so you have to make your own register command
        #To do so
        
        [String]$SingleEntryCSVPath = "TestDrive:$(New-Guid).csv"
        [String]$MultipleEntryCSVPath = "TestDrive:$(New-Guid).csv"

        Register-SecretVault -Name 'PESTER-SingleEntry' -ModuleName $moduleManifest -VaultParameters @{
            Path=$SingleEntryCSVPath
        }
        Register-SecretVault -Name 'PESTER-MultipleEntries' -ModuleName $moduleManifest -VaultParameters @{
            Path=$MultipleEntryCSVPath
        }
        Register-SecretVault -Name 'PESTER-BadVault' -ModuleName $moduleManifest -VaultParameters @{
            Path="TestDrive:\NotARealVault"
        }231
    }
    AfterAll {
        try {
            Unregister-SecretVault -Name 'PESTER-SingleEntry'
        } catch {}
        try {
            Unregister-SecretVault -Name 'PESTER-MultipleEntries'
        } catch {}
        try {
            Unregister-SecretVault -Name 'PESTER-BadVault'
        } catch {}
    }
    BeforeEach {
        #Copy a fresh vault each time to avoid tests interfering with each other
        Copy-Item (Resolve-Path $Mocks/SingleEntry.csv) $SingleEntryCSVPath -Force
        Copy-Item (Resolve-Path $Mocks/MultipleEntries.csv) $MultipleEntryCSVPath -Force
    }

    It 'Can Test a Vault' {
        Test-SecretVault -Name 'Pester-MultipleEntries' |
            Should -Be $true
    }
    It 'Fails on a vault with a bad path' {
        #We can't use Should -Throw here because its impossible to turn it into a terminating error
        Test-SecretVault -Name 'Pester-BadVault' 2>$null |
            Should -Be $false
        $error[0] | Should -BeLike '*Vault not found*'
    }
    It 'Gets all secret Infos' {
        Get-SecretInfo -Vault 'Pester-MultipleEntries' |
            Should -HaveCount 3
    }

    It 'Can read the metadata of a particular secret' {
        $secretInfo = Get-SecretInfo -Name 'PesterSecret3' -Vault 'Pester-MultipleEntries'
        $secretInfo.Metadata.Comment | Should -Be 'this one is my favorite'
        $secretInfo.Metadata.Modified | Should -BeOfType [DateTime]
        $secretInfo.Metadata.Modified | Should -Be ([DateTime]'3/12/1890 4:40:55 PM')
    }

    It 'Gets a secret' {
        $testSecret = Get-Secret -Name 'PesterSecret' -Vault 'PESTER-MultipleEntries'
        $testSecret | Should -BeOfType [SecureString]
        $testSecret | ConvertFrom-SecureString -AsPlainText | Should -Be 'S3cret123!'
    }

    It 'Gets a plaintext secret' {
        $testSecret = Get-Secret -Name 'PesterSecret' -Vault 'PESTER-MultipleEntries' -AsPlainText
        $testSecret | Should -BeOfType [String]
        $testSecret | Should -Be 'S3cret123!'
    }

    It 'Can create secrets and fetch them' {
        Set-Secret -Name 'MyTestSecret' -Vault 'PESTER-SingleEntry' -Secret 'notverysecret'
        $newSecret = Get-SecretInfo -Name 'MyTestSecret' -Vault 'PESTER-SingleEntry'
        $newSecret.Name | Should -Be 'MyTestSecret'
        $newSecret.Type | Should -Be 'String'
        
    }
    It 'Should update an existing secret' {
        Get-Secret -Name 'PesterSecret' -Vault 'PESTER-SingleEntry' -AsPlainText |
            Should -Be 'S3cret123!'
        Set-Secret -Name 'PesterSecret' -Vault 'PESTER-SingleEntry' -Secret 'notverysecret'
        Get-Secret -Name 'PesterSecret' -Vault 'PESTER-SingleEntry' -AsPlainText |
            Should -Be 'notverysecret'
    }

    It 'Can Update Secret Metadata' {
        $Comment = 'I think this secret is pretty OK I suppose'
        Set-SecretInfo -Name 'PesterSecret2' -Vault 'Pester-MultipleEntries' -Metadata @{
            Comment = $Comment
        }
        $updatedSecret = Get-SecretInfo -Name 'PesterSecret2' -Vault 'Pester-MultipleEntries'
        $updatedSecret.Metadata.Comment | Should -Be $Comment
        #Make sure the modified date updated
        $updatedSecret.MetaData.Modified | Should -BeGreaterThan (Get-Date).AddMinutes(-1)
    }

    It 'Can Set a new secret with Metadata' {
        $Comment = 'I think this secret is pretty OK I suppose'
        Set-Secret -Name 'MyNewSecret' -Vault 'Pester-MultipleEntries' -Secret 'notverysecret' -Metadata @{
            Comment = $Comment
        }
        $newSecret = Get-SecretInfo -Name 'MyNewSecret' -Vault 'Pester-MultipleEntries'
        $newSecret | Get-Secret -AsPlainText | Should -Be 'NotVerySecret'
        $newSecret.Metadata.Comment | Should -Be $Comment
        #Make sure the modified date updated
        $newSecret.MetaData.Modified | Should -BeGreaterThan (Get-Date).AddMinutes(-1)
    }

    It 'Removes a secret' {
        $testSecret = Remove-Secret -Name 'PesterSecret' -Vault 'PESTER-MultipleEntries'
        Get-SecretInfo -Vault 'PESTER-MultipleEntries' |
            Should -HaveCount 2
    }
}