<#
 .SYNOPSIS
    Process Audio - Colin Evans 2023 - Routine for converting disparate audio/video formats to wav 
    and then applying EBU-R128 loudness normalisation either using the default 'track by track', 
    or the optional 'album by album'
 .DESCRIPTION
    Routine for converting disparate audio/video formats to .wav and then applying EBU-R128 loudness normalisation
    either using the default 'track by track', or the optional 'album by album' which is
    engaged by setting the album parameter to true (1)
    Another optional parameter cn be used to set the target 0LU in dB, the EBU recommend this to be -23dB or -23LUFS 
    Positive values will be converted to negative, so entering values is quite forgiving
    Default value with missing SetTargetGain parameter is -23
    Parameters can be entered in any order but must be used against the parameter name
 .NOTES
    sed, ffmpeg, r128gain and sox are required for this script to work, these can be freely downloaded
    The search paths for the above commands and this script must be set in 
    Control Panel - System and Security - Advanced System Settings - Environment Variables - Path 
    both for current user and system, if other user accounts need access
    The function should be copied and used from the Powershell User Profile file which is created by typing...
    New-Item -Path $profile -ItemType File -Force
    This is created as %UserProfile%\Documents\Windows\�PowerShell\profile.ps1
    This script is my first in Powershell, it has taken a couple of days to get this script done. Bash and C are more familiar
    and you can see that in the code, although it works quite robustly and I think it's quite readable. However, much to learn me thinks!
 .LINK
    
 .EXAMPLE
    Format-Audio [-SetTargetGain <float>] [-Album <bool>] [-SampleRate <string>] [<CommonParameters>]
    Usage example with alternative LU0 value: Format-Audio -SetTargetGain -24.5 -Album 1 -SampleRate 48k

 #>
 
    

 function Format-Audio {
   
    # User Args
    
        [CmdletBinding(PositionalBinding = $false)]
        [alias("pa")]
        param (
            [Parameter(Mandatory = $false)]
            [float]$SetTargetGain,
                
            [Parameter(Mandatory = $false)]
            [switch]$Album,

            [Parameter(Mandatory = $false)]
            [string]$SampleRate
    )
    
        # functions
    
        function Convert2Wav () { 
            foreach($file in Get-ChildItem -Exclude processed-output){ 
                if ($file.attributes -eq "Archive") {
                    $file.attributes = "Normal"
                    $cleanFile = $file.name | sed 's/[^a-zA-Z0-9 _.-]//g'   # remove illegal characters
                    Move-Item $file.name $cleanFile
                    $name = Write-Output($cleanFile) | sed 's/\.[^.]*$//'   # remove file type suffix to leave just the name               
                    $newFile = Write-Output("processed-output/" + $name + ".wav") 
                    ffmpeg -i $cleanFile -y $newFile # -y option allows unquestioned overwrite if output files exist
                }
            }
        }
        
        function TrackByTrack  {
            param (
                [Parameter()][float]$LU0, 
                [Parameter()][string]$SR
                )
            
            foreach($file in Get-ChildItem -Exclude output){  
                if ($file.attributes -eq "Archive") {  
                    $thisFile = $file.name 
                    Write-Output "`nMeasuring Track Level`n"  
                    $captureR128Gain = r128gain --progress=off  --reference=$LU0 $file.name
                    [float]$gain =  [string]($captureR128Gain | Select-String ALBUM | sed 's/^.*LUFS .//' | sed 's/ LU.//')
                    Write-Output "`n"$thisFile"`n"
                    if ($gain -ne 0) {
                        Write-Output "Not equal to 0 LU - Adjusting Gain`n"
                        sox -S -V3 "$thisfile" output/"$thisfile" rate "$SR" gain $gain
                    }
                    else {
                        Write-Output "Gain is already 0 LU`n"
                        sox -S -V3 "$thisfile" output/"$thisfile" rate "$SR"                       
                    }        
                }
            }  
        }    
    
        function AlbumByAlbum  {
            param (
                [Parameter()][float]$LU0, 
                [Parameter()][string]$SR
            )
            
            $levels = $false
            foreach ($file in Get-ChildItem -exclude output) {
                if ($file.attributes -eq "Archive") {
                    $levels = $true
                }                
            }
            if ($levels) {
            Write-Output "`nMeasuring Levels`n"
            $captureR128Gain = r128gain --progress=off  --reference=$LU0 *.wav
            [float]$gain =  [string]($captureR128Gain | Select-String ALBUM | sed 's/^.*LUFS .//' | sed 's/ LU.//')
            }
            foreach ( $file in Get-ChildItem  -Exclude output ) {
                if ($file.attributes -eq "Archive") {
                    $thisFile = $file.name
                    Write-Output "`nSetting Gain"
                    sox -S -V3 "$thisfile" output/"$thisfile" rate "$SR" gain $gain
                }
            }
        }
    
    
        <# *********** Start *************** #>
    
    
        # Validate User Args
    
        if ( $SetTargetGain ){
            if( $SetTargetGain -gt 0.0 ) {
                $SetTargetGain = -1 * $SetTargetGain  # convert to negative if user cocks up with a positive value  
            }    
        }
        else {
            $SetTargetGain = -23.0  # ebu default if no entry or a non-numeric param is entered by accident
        }
    
        # Test if processed audio folder exists
    
        if ( Test-Path ".\processed-output" ) {
            Write-Output "Folder exists"
        }
        else {
            New-Item -Path ".\" -Name "processed-output" -ItemType "directory"
        }
    
        # convert to wav files function call
    
        Convert2Wav 
    
        # temp sub-dir for gain and sample rate processing
    
        Set-Location processed-output
        New-Item -Path ".\" -Name "output" -ItemType "directory"  
           
        Switch ( $SampleRate )
        {
            "96k" 
            {
                $SR = "96k"
            }
            "96000"
            {
                $SR = "96k"
            }
            "88.2k" 
            {
                $SR = "88.2k"
            }
            "88200" 
            {
                $SR = "88.2k"
            }
            "48k" 
            {
                $SR = "48k"
            }
            "48000" 
            {
                $SR = "48k"
            }
            "44.1k" 
            {
                $SR = "44.1k"
            }
            "44100" 
            {
                $SR = "44.1k"
            }
            "32k" 
            {
                $SR = "32k"
            }
            "32000" 
            {
                $SR = "32k"
            }
            "16k" 
            {
                $SR = "16k"
            }
            "16000" 
            {
                $SR = "16k"
            }
            default 
            {
                $SR = "44.1k"
            }
        }

        # Test for Album and choose which functions to call

        if ($Album) {
            Write-Output "`nAlbum Mode`n"
            AlbumByAlbum -LU0 $SetTargetGain -SR $SR
        }
        else {
            Write-Output "`nTrack Mode`n"
            TrackByTrack -LU0 $SetTargetGain -SR $SR
        }
     
        # tidy up
    
        Copy-Item output/* ./
        Remove-Item -r output 
        foreach($file in Get-ChildItem){
        $file.Attributes = "Normal"
        }

        Set-Location ..
        Write-Output "`nAll Done`nHave a nice day" 
    
    }