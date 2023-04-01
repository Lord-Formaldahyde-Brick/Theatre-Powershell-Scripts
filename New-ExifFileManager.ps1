
# Building at the mo, will look odd for a bit, this is just a placeholder for bits of code

# Extract Creation Date - Get-ChildItem will be replaced by a UI file selection
foreach($file in Get-ChildItem -Name){
    $jn = exiftool -j -q $file 
    $jn = $jn | ConvertFrom-Json
    [string]$dt = $jn.createdate
    $dt.Substring(0,10).Replace(":","-")
}

