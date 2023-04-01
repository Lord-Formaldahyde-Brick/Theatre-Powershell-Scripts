
# Building at the mo, will look odd for a bit, this is just a placeholder for bits of code
# *****************************************************************************


# Start by presenting UI File Selection Box in Multi-Select mode.

# Once Ok is pressed present a dropdown with Lecturer name to provide the 
# head folder path for that person.
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Select a Lecturer'
$form.Size = New-Object System.Drawing.Size(300,400)
$form.StartPosition = 'CenterScreen'

$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(75,300)
$okButton.Size = New-Object System.Drawing.Size(75,23)
$okButton.Text = 'OK'
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)

$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(150,300)
$cancelButton.Size = New-Object System.Drawing.Size(75,23)
$cancelButton.Text = 'Cancel'
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $cancelButton
$form.Controls.Add($cancelButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(280,20)
$label.Text = 'Please select a computer:'
$form.Controls.Add($label)

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

$form.Controls.Add($listBox)

$form.Topmost = $true

$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $name = $listBox.SelectedItem
    $name
}

# Extract Creation Date - Get-ChildItem will be replaced by the UI file selection
foreach($file in Get-ChildItem -Name){
    $jn = exiftool -j -q $file 
    $jn = $jn | ConvertFrom-Json
    [string]$dt = $jn.createdate
    $dt.Substring(0,10).Replace(":","-")
}

# Append exif createdate to Lecturer name and create a subfolder using this concat string 
# to store the current file if subfolder doesn't exist,
#  if it does simply store file there.