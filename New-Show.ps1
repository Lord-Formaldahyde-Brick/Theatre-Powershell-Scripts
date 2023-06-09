function New-Show  {
    [CmdletBinding(PositionalBinding = $True)]
    [alias("ns")]
    param (
    [Parameter(Mandatory = $True)]  
    [string]$showName
    )
    $d = Get-Date -Format "dd-MM-yyyy"
    [string]$fullName = "$showName"+"_"+"$d"
    If (Test-Path $fullName){
        Write-Host "Folder exists, creating a unique name"
        $i = 1
        [string]$extendName = "$ShowName"+"$i"+"_"+"$d"
        while (Test-Path $extendName) {
            $i++
            [string]$extendName = "$ShowName"+"$i"+"_"+"$d"
        }
        New-Item -Name $extendName -ItemType Directory
        Set-Location $extendName
        New-Item -Name Audio -ItemType Directory
        New-Item -Name Images -ItemType Directory
        New-Item -Name Video -ItemType Directory
        Set-Location ..
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