
# Building at the mo, will look odd for a bit, this is just a placeholder for bits of code
# *****************************************************************************


# Start by presenting UI File Selection Box in Multi-Select mode.

# Once Ok is pressed present a dropdown with Lecturer name to provide the 
# head folder path for that person.

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