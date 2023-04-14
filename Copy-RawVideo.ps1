Function Copy-RawVideo () {
    # ui for selecting files
    
        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Drawing
        
        
        $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog
        $FileBrowser.Multiselect =$true
        $FileBrowser.ShowDialog()
        $FilesArray = $FileBrowser.FileNames
    
     # ui for selecting who the files belong to   
        
        $listBoxForm = New-Object System.Windows.Forms.Form
        $listBoxForm.Text = 'Select a Lecturer'
        $listBoxForm.Size = New-Object System.Drawing.Size(300,400)
        $listBoxForm.StartPosition = 'CenterScreen'
        
        $okButton = New-Object System.Windows.Forms.Button
        $okButton.Location = New-Object System.Drawing.Point(75,300)
        $okButton.Size = New-Object System.Drawing.Size(75,23)
        $okButton.Text = 'OK'
        $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $listBoxForm.AcceptButton = $okButton
        $listBoxForm.Controls.Add($okButton)
        
        $cancelButton = New-Object System.Windows.Forms.Button
        $cancelButton.Location = New-Object System.Drawing.Point(150,300)
        $cancelButton.Size = New-Object System.Drawing.Size(75,23)
        $cancelButton.Text = 'Cancel'
        $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
        $listBoxForm.CancelButton = $cancelButton
        $listBoxForm.Controls.Add($cancelButton)
        
        $label = New-Object System.Windows.Forms.Label
        $label.Location = New-Object System.Drawing.Point(10,20)
        $label.Size = New-Object System.Drawing.Size(280,20)
        $label.Text = 'Please select a Lecturer:'
        $listBoxForm.Controls.Add($label)
        
        $listBox = New-Object System.Windows.Forms.ListBox
        $listBox.Location = New-Object System.Drawing.Point(10,40)
        $listBox.Size = New-Object System.Drawing.Size(260,20)
        $listBox.Height = 240
        
        # Names can be easily added or removed here
        
        [void] $listBox.Items.Add('Any John')
        [void] $listBox.Items.Add('Bethan Griffiths')
        [void] $listBox.Items.Add('Carolyn Davies')
        [void] $listBox.Items.Add('Chris Carpenter')
        [void] $listBox.Items.Add('Craig Coombs')
        [void] $listBox.Items.Add('Daniella Powell')
        [void] $listBox.Items.Add('Elise Addiscott')
        [void] $listBox.Items.Add('Huw Morgan')
        [void] $listBox.Items.Add('John Jones')
        [void] $listBox.Items.Add('Judith Huntly')
        [void] $listBox.Items.Add('Phil Broome')
        [void] $listBox.Items.Add('Saydi Jones')
        [void] $listBox.Items.Add('Stevie-Ann Fraser')
        [void] $listBox.Items.Add('Zoe Arrieta')
        
        $listBoxForm.Controls.Add($listBox)
        
        $listBoxForm.Topmost = $true
        
        $result = $listBoxForm.ShowDialog()
        
        if ($result -eq [System.Windows.Forms.DialogResult]::OK)
        {
            $headFolder = $($listBox.SelectedItem).Replace(" ","")   
        }
        else {
            Write-Host "Bye"
            return
        }
        #Calculate total file transfer

        $totalTransfer = 0
        foreach($file in $FilesArray){
            $j = $(exiftool -j -q $file) | ConvertFrom-Json
            $fileSize = $j.FileSize.split(" ")
            
            if ($fileSize[1] -eq "GB") {
                $fileSize[0] * 1024
            }
            
            $fileSize = $fileSize[0]
            $totalTransfer = $totalTransfer + $fileSize
        }

        # Get the datestamp and file size progress info from EXIF

        $runTot = 0
        foreach($file in $FilesArray){
            $jn = $(exiftool -j -q $file) | ConvertFrom-Json
            $singleFileSize = $jn.FileSize.split(" ")
            $singleFileSize = $singleFileSize[0]
            if ($singleFileSize[1] -eq "GB") {
                $singleFileSize * 1024
            }
            $runTot = $runTot + $singleFileSize

          # [DateTime]$shortDate = $($jn.createdate).Substring(0,10).Replace(":","-")
          # [string]$shortDate = $shortDate.ToLongDateString()
          # $subFolderName = "$headFolder"+"-"+"$shortDate"

            $shortDate = $($jn.createdate).Substring(0,10).Replace(":","-")
            $subFolderName = "$headFolder"+"$shortDate"


        # get basename of current file, used in 'file exist' test later
        
            $maxIndex = $($file.Split("\").Length) - 1
            $fileToTest = $file.Split("\")[$maxIndex]           
            Write-Progress -Activity "Getting Video" -id 1 -Status "Copying $($fileToTest)"
            

            
            # Copying and Sorting
    
            [string]$storagePath = "D:\RawVideo" # Change this path to where the videos are stored
    
            if ( Test-Path $storagePath\$headFolder\$subFolderName\$fileToTest -PathType Leaf) {
                Write-Host "The file exists, moving on"
            }
            else {
                if (Test-Path $storagePath\$headFolder) {
                    if (Test-Path $storagePath\$headFolder\$subFolderName) {
                        Copy-Item $file $storagePath\$headFolder\$subFolderName
                    }
                    else {
                        Set-Location $storagePath\$headFolder
                        New-Item -name $subFolderName -ItemType Directory
                        Copy-Item $file $storagePath\$headFolder\$subFolderName
                    }
                }
                else {
                    Set-Location $storagePath
                    New-Item -name $headFolder -ItemType Directory
                    Set-Location $storagePath\$headFolder
                    New-Item -name $subFolderName -ItemType Directory
                    Copy-Item $file $storagePath\$headFolder\$subFolderName
                }
           } 
           Write-Progress -Activity "Video Transfered" -Status "$([math]::round(($runTot/$totalTransfer) * 100,2))% of transfer completed" -Id 2  -PercentComplete $(($runTot/$totalTransfer) * 100)
        }
        Set-Location $storagePath
    }