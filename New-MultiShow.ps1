function New-MultiShow {
    [CmdletBinding(PositionalBinding=$True)]
    [alias("ms")]
    param (
        [Parameter(Mandatory = $True)]           
        [string]$showName
    )
    $d = Get-Date
    $justDate = $d.tostring("dd-MM-yyyy")
    [string]$fullName = "$showName"+"_"+"$justDate"
    If (Test-Path $fullName){
    Write-Host "Folder exists, creating a unique name"
    $k = 1
        [string]$extendName = "$ShowName"+"$k"+"_"+"$justDate"
        while (Test-Path $extendName) {
            $k++
            [string]$extendName = "$ShowName"+"$k"+"_"+"$justDate"
        }
        New-Item -Name $extendName -ItemType Directory
        Set-Location $extendName
        [int]$noOfPlays = Read-Host "How many Plays?"
        for ($i -eq 0; $i -lt $noOfPlays; $i++) {
            $j = $i+1
            $nameOfPlay = Read-Host "Name of Play"$j"?"
            New-Item -Name $nameOfPlay -ItemType Directory
            Set-Location $nameOfPlay
            New-Item -Name Audio -ItemType Directory
            New-Item -Name Images -ItemType Directory
            New-Item -Name Video -ItemType Directory
            Set-Location ..
            }
    }
    Else {
        New-Item -Name $fullName -ItemType Directory
        Set-Location $fullName
        [int]$noOfPlays = Read-Host "How many Plays?"
        for ($i -eq 0; $i -lt $noOfPlays; $i++) {
            $j = $i+1
            $nameOfPlay = Read-Host "Name of Play"$j"?"
            New-Item -Name $nameOfPlay -ItemType Directory
            Set-Location $nameOfPlay
            New-Item -Name Audio -ItemType Directory
            New-Item -Name Images -ItemType Directory
            New-Item -Name Video -ItemType Directory
            Set-Location ..
        }            
    }
    Set-Location ..
}