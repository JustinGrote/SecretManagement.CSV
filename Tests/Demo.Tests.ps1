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
    }
    AfterAll {
        try {
            Unregister-SecretVault -Name 'PESTER-SingleEntry'
        } catch {}
        try {
            Unregister-SecretVault -Name 'PESTER-MultipleEntries'
        } catch {}
    }
    BeforeEach {
        #Copy a fresh vault each time to avoid tests interfering with each other
        Copy-Item (Resolve-Path $Mocks/SingleEntry.csv) $SingleEntryCSVPath -Force
        Copy-Item (Resolve-Path $Mocks/MultipleEntries.csv) $MultipleEntryCSVPath -Force
    }
    It 'Gets all secret Info' {
        Get-SecretInfo -Name 'PesterSecret' -Vault 'Pester-MultipleEntries'
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
    }


}