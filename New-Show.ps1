function New-Show  {
    [CmdletBinding(PositionalBinding = $True)]
    [alias("ns")]
    param (
    [Parameter(Mandatory = $True)]  
    [string]$showName
    )
    $d = Get-Date
    $justDate = $d.tostring("dd-MM-yyyy")
    [string]$fullName = "$showName"+"-"+"$justDate"
    If (Test-Path $fullName){
    Write-Host "Folder exists, use a unique name"
    }
    Else {
        New-Item -Name $fullName -ItemType Directory
        Set-Location $fullName
        New-Item -Name Audio -ItemType Directory
        New-Item -Name Images -ItemType Directory
        New-Item -Name Video -ItemType Directory
        Set-Location ..
    }
}