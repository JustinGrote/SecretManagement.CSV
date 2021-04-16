#Scaffolded from https://github.com/powershell/secretmanagement README

$PrivateFunctions = Get-Item $PSScriptRoot/Private/*.ps1 -Exclude '*.Tests.ps1' | Foreach-Object {
    . $PSItem
    $PSItem.BaseName
}

$PublicFunctions = Get-Item $PSScriptRoot/Public/*.ps1 -Exclude '*.Tests.ps1' | Foreach-Object {
    . $PSItem
    $PSItem.BaseName
}
Export-ModuleMember -Function $PublicFunctions