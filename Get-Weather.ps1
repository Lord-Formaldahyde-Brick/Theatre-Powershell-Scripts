function Get-Weather  {
    [CmdletBinding(PositionalBinding=$True)]
    [alias("gw")]
    param (
        [Parameter(Mandatory = $false)]           
        [int]$days
    )

    enum codes{
        <# Specify a list of distinct values #>
        Clear = 0
        Mainly_clear = 1
        Partly_cloudy = 2
        Overcast = 3
        Fog = 45
        Depositing_rime_fog
        Light_drizzle = 51
        Moderate_drizzle
        Dense_drizzle
        Light_freezing_drizzle = 56
        Dense_freezing_drizzle
        Slight_rain = 61
        Moderate_rain = 63
        Heavy_rain = 65
        Light_freezing_rain
        Heavy_freezing_rain
        Slight_snow = 71
        Moderate_snow = 73
        Heavy_snow = 75
        Snow_grains = 77
        Slight_rain_showers = 80
        Moderate_rain_showers
        Violent_rain_showers
        Slight_snow_showers = 85
        Heavy_snow_showers
        Slight_or_Moderate_Thunderstorm = 95
        Thunderstorm_with_slight_hail
        Thunderstorm_with_heavy_hail = 99
    }
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
        [int]$wcode = $weather.hourly.weathercode[$k]
        [string]$Syn = [codes].GetEnumName($wcode)
        $Syn = $Syn.Replace("_", " ")
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
            "Synopsis" = $Syn       
        }
        $wob += $obj | Select-Object Day,Date,Time,Temperature-C,Wind-Knots,Wind-Dir,Pressure-hPa,Precipitation-mm,Cloud-Cover,Synopsis
    }

        $wob | Format-Table -AutoSize
}