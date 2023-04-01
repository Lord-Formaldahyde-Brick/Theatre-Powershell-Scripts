# Function for copying/sorting video or image files to Creator/Dated folders using Exif date stamp

Function Get-RawVideo () {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    
    
    $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog
    $FileBrowser.Multiselect =$true
    $FileBrowser.ShowDialog()
    $FilesArray = $FileBrowser.FileNames
    
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
    $label.Text = 'Please select a computer:'
    $listBoxForm.Controls.Add($label)
    
    $listBox = New-Object System.Windows.Forms.ListBox
    $listBox.Location = New-Object System.Drawing.Point(10,40)
    $listBox.Size = New-Object System.Drawing.Size(260,20)
    $listBox.Height = 240
    
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
        [string]$name = $listBox.SelectedItem
        [string]$headFolder = $name.Replace(" ","")
        
    }
    else {
        Write-Host "Bye"
        Exit
    }
    
    foreach($file in $FilesArray){
        $jn = exiftool -j -q $file 
        $jn = $jn | ConvertFrom-Json
        [string]$dt = $jn.createdate
        [string]$shortDate = $dt.Substring(0,10).Replace(":","-")
        $subFolderName = "$headFolder"+"$shortDate"
        if (Test-Path C:\Users\admin\Desktop\RawVideo\$headFolder) {
            if (Test-Path C:\Users\admin\Desktop\RawVideo\$headFolder\$subFolderName){
            Copy-Item $file C:\Users\admin\Desktop\RawVideo\$headFolder\$subFolderName
            }
            Else {
                Set-Location C:\Users\admin\Desktop\RawVideo\$headFolder
                New-Item -name $subFolderName -ItemType Directory
                Copy-Item $file $subFolderName
            }
        }
        else {
            Set-Location C:\Users\admin\Desktop\RawVideo
            New-Item -name $headFolder -ItemType Directory
            Set-Location C:\Users\admin\Desktop\RawVideo\$headFolder
            New-Item -name $subFolderName -ItemType Directory
            Copy-Item $file $subFolderName
        }
    }
    Set-Location ..
}