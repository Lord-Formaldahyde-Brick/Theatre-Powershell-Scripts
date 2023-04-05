function Get-Weather  {
    [CmdletBinding(PositionalBinding=$True)]
    [alias("gw")]
    param (
        [Parameter(Mandatory = $false)]           
        [int]$days
    )
    $wj = curl "https://api.open-meteo.com/v1/ecmwf?latitude=51.69&longitude=-3.88&hourly=temperature_2m,surface_air_pressure,weathercode,precipitation,cloudcover,windspeed_10m,winddirection_10m"
    $weather = $wj | ConvertFrom-Json
    if ($days) {
        if ($days -ge 1 -and $days -le 10) {
            $maxItems = $days * 8
        }
        else {
            $maxItems= $weather.hourly.time.length
        }
    }
    else {
        $maxItems= $weather.hourly.time.length
    }
    $wob = @()
    for ($k=0; $k -lt $maxItems; $k++){
        $dt = [DateTime]$weather.hourly.time[$k].split("T")[0];
        $obj = New-Object psobject -Property @{
            "Day" = $dt.DayOfWeek
            "Date" = $dt.ToLongDateString()
            "Time" = $weather.hourly.time[$k].split("T")[1];
            "Temperature-C" = $weather.hourly.temperature_2m[$k];
            "Wind-Knots" = $weather.hourly.windspeed_10m[$k];
            "Wind-Dir" = $weather.hourly.winddirection_10m[$k];
            "Pressure-hPa" =$weather.hourly.surface_air_pressure[$k];
            "Precipitation-mm" = $weather.hourly.precipitation[$k];
            "Cloud-Cover" = $weather.hourly.cloudcover[$k];
            "Code" = $weather.hourly.weathercode[$k]        
        }
        $wob += $obj | Select-Object Day,Date,Time,Temperature-C,Wind-Knots,Wind-Dir,Pressure-hPa,Precipitation-mm,Cloud-Cover,Code
    }

        $wob | Format-Table -AutoSize
}