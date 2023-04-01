
# Building at the mo, will look odd for a bit, this is just a placeholder for bits of code

# Extract Creation Date - needs foreach
$jn = exiftool -j -q * 
$jn = $jn | ConvertFrom-Json
#$jn > data.json
[string]$dt = $jn.createdate #| sed 's/ .*//' | sed 's/:/-/g'
$dt.Substring(0,10).Replace(":","-")


