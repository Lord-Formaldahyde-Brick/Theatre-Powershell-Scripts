function Get-Weather  {
    [CmdletBinding(PositionalBinding=$True)]
    [alias("gw")]
    param (
        [Parameter(Mandatory = $false)]           
        [int]$hours
    )

    [string]$today = Get-Date
    $today = $today.substring(0,10)
    $today = "Weather_$($today.replace("/", "-"))"
    
    function makeCharts  {
       param (
        # Parameter help description
        [Parameter(Mandatory = $True)]
        $maxItems
       )
        #Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Windows.Forms.DataVisualization

           

        #Create chart
        $chart1 = New-Object System.Windows.Forms.DataVisualization.Charting.Chart
        $chart1.Width = 1600
        $chart1.Height = 900

        # create chart area
        $chart1Area = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
        $chart1.ChartAreas.Add($chart1Area)
    
        $chart1Title = New-Object System.Windows.Forms.DataVisualization.Charting.Title
        $chart1Title.Text = "Temperature - $($hours) Hours"

        $titleFont = New-Object System.Drawing.Font @('Microsoft Sans Serif', '18',[System.Drawing.FontStyle]::Bold)
        $chart1Title.Font = $titleFont
        $chart1.Titles.Add($chart1Title)
        $chart1Area.AxisX.Title = "Time"
        $chart1Area.AxisY.Title = "Temperature"
        $chart1Area.BackColor ="SkyBlue"


        $chartTemperature = @()
        for ($k=0; $k -lt $maxItems; $k++){
            [string]$tm = $weather.hourly.time[$k]#.split("T")[1]
            $chartOb = @{
                "time" =  $tm
                "temp2m" = [double]"$($weather.hourly.temperature_2m[$k])"
                "temp180m" = [double]"$($weather.hourly.temperature_180m[$k])"
                "temp850hPa" =[double]"$($weather.hourly.temperature_850hPa[$k])"
                "dp2m" = [double]"$($weather.hourly.dewpoint_2m[$k])"
                "dp850hPa" = [double]"$($weather.hourly.dewpoint_850hPa[$k])"
                "cp" = [double]"$($weather.hourly.cape[$k])"

            }
    
            $chartTemperature += $chartOb | Select-Object time,temp2m,temp180m,temp850hPa,dp2m,dp850hPa,cp
        }
        
        $series1 = $chart1.Series.Add("Temperature2m")
        $series1.ChartType = "Spline"
        $series1.Color = "Red"
        $series1.IsValueShownAsLabel = $True
        $series1.BorderWidth = 3

        $series2 = $chart1.Series.Add("Temperature180m")
        $series2.ChartType = "Spline"
        $series2.Color = "Yellow"
        $series2.IsValueShownAsLabel = $True
        $series2.BorderWidth = 3

        $series3 = $chart1.Series.Add("Temperature850hPa")
        $series3.ChartType = "Spline"
        $series3.Color = "Green"
        $series3.IsValueShownAsLabel = $True
        $series3.BorderWidth = 3

        $series4 = $chart1.Series.Add("Dewpoint2m")
        $series4.ChartType = "Spline"
        $series4.Color = "Black"
        $series4.IsValueShownAsLabel = $True
        $series4.BorderWidth = 3

        $series5 = $chart1.Series.Add("Dewpoint850hPa")
        $series5.ChartType = "Spline"
        $series5.Color = "White"
        $series5.IsValueShownAsLabel = $True
        $series5.BorderWidth = 3

        $leg1 = $chart1.Legends.Add("TemperatureKeys")
        $leg1.BackColor ="skyblue"
        $leg1.BorderColor = "black"
        
        
        

        if (-not (Test-Path -path C:\Users\admin\Desktop\WeatherCharts\$today)) {
        New-Item -Path C:\Users\admin\Desktop\WeatherCharts\$today -ItemType Directory
        }

        $series1.Points.DataBindXY($chartTemperature.Time,$chartTemperature.temp2m)
        $series2.Points.DataBindXY($chartTemperature.Time,$chartTemperature.temp180m)
        $series3.Points.DataBindXY($chartTemperature.Time,$chartTemperature.temp850hPa)
        $series4.Points.DataBindXY($chartTemperature.Time,$chartTemperature.dp2m)
        $series5.Points.DataBindXY($chartTemperature.Time,$chartTemperature.dp850hPa)
        $temp2mImageFile = "C:\Users\admin\Desktop\WeatherCharts\$($today)\Temp_$($today)_$($hours)hours.png"
        $chart1.SaveImage($temp2mImageFile,'PNG')
        
    }
    
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
    $wj = curl "https://api.open-meteo.com/v1/forecast?latitude=51.69&longitude=-3.92&elevation=50&hourly=temperature_2m,dewpoint_2m,precipitation,weathercode,surface_pressure,pressure_msl,cloudcover,cloudcover_low,cloudcover_mid,cloudcover_high,windspeed_10m,windspeed_180m,winddirection_10m,winddirection_180m,temperature_180m,cape,temperature_850hPa,dewpoint_850hPa&models=best_match"
    $weather = $wj | ConvertFrom-Json
    if ($hours) {
        if ($hours -ge 1 -and $hours -le 168) {
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
        $windspeedConvToMile10m = ($weather.hourly.windspeed_10m[$k]) * 0.621371
        $windspeedConvToMile10m = [math]::round($windspeedConvToMile10m,2)
        $windspeedConvToMile180m = ($weather.hourly.windspeed_180m[$k]) * 0.621371
        $windspeedConvToMile180m = [math]::round($windspeedConvToMile180m,2)
        $windspeedConvToKnot10m = ($weather.hourly.windspeed_10m[$k]) * 0.539957
        $windspeedConvToKnot10m = [math]::round($windspeedConvToKnot10m,2)
        $windspeedConvToKnot180m = ($weather.hourly.windspeed_180m[$k]) * 0.539957
        $windspeedConvToKnot180m = [math]::round($windspeedConvToKnot180m,2)

        $obj = New-Object psobject -Property @{
            "Day" = $dt.DayOfWeek
            "Date" = $dt.ToLongDateString()
            "Time" = $weather.hourly.time[$k].split("T")[1]
            "Temperature-2m" = "$($weather.hourly.temperature_2m[$k])" + [char]0x00b0 + "C"
            "Temperature-180m" = "$($weather.hourly.temperature_180m[$k])" + [char]0x00b0 + "C"
            "Temperature-850hPa" ="$($weather.hourly.temperature_850hPa[$k])" + [char]0x00b0 + "C"
            "Dewpoint-2m" ="$($weather.hourly.dewpoint_2m[$k])" + [char]0x00b0 + "C"
            "Dewpoint-850hPa" ="$($weather.hourly.dewpoint_850hPa[$k])" + [char]0x00b0 + "C"
            "CAPE" = "$($weather.hourly.cape[$k])" + " J/Kg"
            "Wind-Speed-10m" = "$($weather.hourly.windspeed_10m[$k])" + " Km/h" + " " + $windspeedConvToMile10m + " Mph" + " " + $windspeedConvToKnot10m + " kts"
            "Wind-Dir-10m" = "$($weather.hourly.winddirection_10m[$k])" + [char]0x00b0
            "Wind-Speed-180m" = "$($weather.hourly.windspeed_180m[$k])" + " Km/h" + " " + $windspeedConvToMile180m + " Mph" + " " + $windspeedConvToKnot180m + " kts"
            "Wind-Dir-180m" = "$($weather.hourly.winddirection_180m[$k])" + [char]0x00b0
            "Pressure-MSL" ="$($weather.hourly.pressure_msl[$k])" + " hPa"
            "Surface-Pressure" ="$($weather.hourly.surface_pressure[$k])" + " hPa"
            "Precipitation" = "$($weather.hourly.precipitation[$k])" + " mm"
            "Cloud-Cover" = "$($weather.hourly.cloudcover[$k])" + "%"
            "Cloud-Cover-Below-3Km" = "$($weather.hourly.cloudcover_low[$k])" + "%"
            "Cloud-Cover-3Km-to-8Km" = "$($weather.hourly.cloudcover_mid[$k])" + "%"
            "Cloud-Cover-Above-8Km" = "$($weather.hourly.cloudcover_high[$k])" + "%"
            "Synopsis" = $Syn       
        }
        
        $wob += $obj | Select-Object Date,Time,Temperature-2m,Dewpoint-2m,Temperature-180m,Temperature-850hPa,Dewpoint-850hPa,CAPE,Wind-Speed-10m,Wind-Dir-10m,Wind-Speed-180m,Wind-Dir-180m,Pressure-MSL,Surface-Pressure,Precipitation,Cloud-Cover-Below-3Km,Cloud-Cover-3Km-to-8Km,Cloud-Cover-Above-8Km,Synopsis
        
    }

        $wob
        makeCharts -maxItems $maxItems
        
}

gw 24
