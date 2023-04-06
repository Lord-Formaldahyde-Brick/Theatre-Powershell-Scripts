function Get-Weather  {
    [CmdletBinding(PositionalBinding=$True)]
    [alias("gw")]
    param (
        [Parameter(Mandatory = $false)]           
        [int]$hours
    )

    enum codes{
        <# Specify a list of distinct values #>
        Clear = 0
        Mainly_clear
        Partly_cloudy
        Overcast
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
    $wj = curl "https://api.open-meteo.com/v1/forecast?latitude=51.69&longitude=-3.92&hourly=temperature_2m,dewpoint_2m,precipitation,weathercode,surface_pressure,cloudcover,windspeed_10m,windspeed_180m,winddirection_10m,winddirection_180m,temperature_180m,cape&models=best_match"
    $weather = $wj | ConvertFrom-Json
    if ($hours) {
        if ($hours -ge 1 -and $hours -le 240) {
            $maxItems = $hours
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
            "Time" = $weather.hourly.time[$k].split("T")[1]
            "Temperature-2m" = "$($weather.hourly.temperature_2m[$k])" + [char]0x00b0 + "C"
            "Temperature-180m" = "$($weather.hourly.temperature_180m[$k])" + [char]0x00b0 + "C"
            "Dewpoint-2m" ="$($weather.hourly.dewpoint_2m[$k])" + [char]0x00b0 + "C"
            "Cape" = "$($weather.hourly.cape[$k])" + "J/Kg"
            "Wind-Speed-10m" = "$($weather.hourly.windspeed_10m[$k])" + "Km/h"
            "Wind-Dir-10m" = "$($weather.hourly.winddirection_10m[$k])" + [char]0x00b0
            "Wind-Speed-180m" = "$($weather.hourly.windspeed_180m[$k])" + "Km/h"
            "Wind-Dir-180m" = "$($weather.hourly.winddirection_180m[$k])" + [char]0x00b0
            "Surface-Pressure" ="$($weather.hourly.surface_pressure[$k])" + "hPa"
            "Precipitation" = "$($weather.hourly.precipitation[$k])" + "mm"
            "Cloud-Cover" = "$($weather.hourly.cloudcover[$k])" + "%"
            "Synopsis" = $Syn       
        }
        $wob += $obj | Select-Object Date,Time,Temperature-2m,Temperature-180m,Dewpoint-2m,Cape,Wind-Speed-10m,Wind-Dir-10m,Wind-Speed-180m,Wind-Dir-180m,Surface-Pressure,Precipitation,Cloud-Cover,Synopsis
    }

        $wob #| Format-Table
}

Get-Weather -hours 24