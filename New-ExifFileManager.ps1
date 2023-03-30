
# Extract Creation Date - needs foreach
$jn = exiftool -j -q * 
$jn = $jn | ConvertFrom-Json
#$jn > data.json
$dt = $jn.createdate | sed 's/ .*//' | sed 's/:/-/g'
$dt


