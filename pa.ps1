

 <#
 .SYNOPSIS
    Process Audio v1.0 Colin Evans 2023 - Routine for converting disparate audio/video formats to wav 
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
    This is created as %UserProfile%\Documents\WindowsÂ­PowerShell\profile.ps1
 .LINK
    
 .EXAMPLE
    Process-Audio [-SetTargetGain <float>] [-Album <bool>]  [<CommonParameters>]
    Usage example with alternative value: Set-Level -SetTargetGain -24.5 -Album 1

 #>
 
    

 function Process-Audio {
   
    # User Args
    
        [CmdletBinding(PositionalBinding = $false)]
        param (
            [Parameter(Mandatory = $false)]
            [float]$SetTargetGain,
    
            [Parameter(Mandatory =$false)]
            [bool]$Album
    )
    
        # functions
    
        function Convert2Wav () { 
            foreach($file in Get-ChildItem -Name -Exclude processed-output){    
                $name = Write-Output($file) | sed 's/\.[^.]*$//'  # remove file type suffix to leave just the name
                $newFile = Write-Output("processed-output/"+ $name +".wav") 
                ffmpeg -i $file -y $newFile # -y option allows unquestioned overwrite if output files exist
            }
        }
        
        function TrackByTrack ($LU0) {
            Write-Host "`nMeasuring Track Level`n"
            foreach($file in Get-ChildItem -Name -Exclude output){       
                $captureR128 = r128gain --progress=off  --reference=$LU0 $file
                [float]$gain =  [string]($captureR128 | Select-String ALBUM | sed 's/^.*LUFS .//' | sed 's/ LU.//')
                Write-Host "`n"$file"`n"
                if ($gain -ne 0) {
                    Write-Host "Not equal to 0 LU - Adjusting Gain`n"
                    sox "$file" output/"$file" rate 44100 gain $gain
                }
                else {
                    Write-Host "Gain is already 0 LU`n"
                    Move-Item "$file" output/"$file"
                }        
            }  
        }    
    
        function AlbumByAlbum ($LU0) {
            Write-Host "`nMeasuring Levels`n"
            $captureR128 = r128gain --progress=off  --reference=$LU0 *.wav
            [float]$gain =  [string]($captureR128 | Select-String ALBUM | sed 's/^.*LUFS .//' | sed 's/ LU.//')
            Write-Host "`nSetting Gain"
            foreach ( $file in Get-ChildItem -Name -Exclude output ) {
                sox "$file" output/"$file" rate 44100 gain $gain
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
            Write-Host "Folder exists"
        }
        else {
            New-Item -Path ".\" -Name "processed-output" -ItemType "directory"
        }
    
        # convert to wav files function call
    
        Convert2Wav 
    
        # temp sub-dir for gain and sample rate processing
    
        Set-Location processed-output
        New-Item -Path ".\" -Name "output" -ItemType "directory"  
     
        # function calls for gain and sample rate
    
        if ($Album) {
            Write-Host "`nAlbum Mode`n"
            AlbumByAlbum($SetTargetGain)
        }
        else {
            Write-Host "`nTrack Mode`n"
            TrackByTrack($SetTargetGain)
        }
     
        # tidy up
    
        Remove-Item *.wav
        Move-Item output/* ./
        Remove-Item -r output 
        Set-Location ..
        Write-Host "`nAll Done`nHave a nice day" 
    
    }