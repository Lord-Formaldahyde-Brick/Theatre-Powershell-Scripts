<# Requires folder to be created for all weather documents, from here the html presentaion pages and dateed folders
will be automatically created. This base weather folder will also need to contain the header.html file 
which is on github.

This script requires (and works well on) Powershell 7.3, as it doesn't yet fully function on Powershell 5.1, 
and I'm struggling to find the reason. (Everything displays but the data series in the charts) 
May need a moment of clarity. 
Update: It appears that I've built this the wrong way, PS5 seems to want the data as a Hash-table
where the we have an object (like hourly) with a key property (like temperature_2m) and value array.  
I have given it Array[].hash-table of keys and values, as in array[0].{temp2m:single value for that hour, temp180m:val etc.}
I'm not happy with the build up of hard coding either (due to wanting to try out stuff and get feedback), 
so I will be ripping this apart and re-coding all the charting function.
Just need to hatch a cunning plan. I shouldn't be too gutted, the documentation of charting in .net is quite vague
on first read. You have to crack a few eggs! 

#>

function Get-Weather  {
    [CmdletBinding(PositionalBinding=$True)]
    [alias("gw")]
    param (
        [Parameter(Mandatory = $false)]           
        [int]$hours
    )

    $topWeatherFolder = "D:\WeatherCharts"
    [string]$today = Get-Date
    $today = $today.substring(0,10)
    $today = "Weather_$($today.replace("/", "-"))"
    
    function makeCharts  {
       param (
        
        [Parameter(Mandatory = $True)]
        $maxItems
       )

        Add-Type -AssemblyName System.Windows.Forms.DataVisualization

        #Create chart
        $chart1 = New-Object System.Windows.Forms.DataVisualization.Charting.Chart
        $chart1.Width = 1600
        $chart1.Height = 900
        $chart2 = New-Object System.Windows.Forms.DataVisualization.Charting.Chart
        $chart2.Width = 1600
        $chart2.Height = 900
        $chart3 = New-Object System.Windows.Forms.DataVisualization.Charting.Chart
        $chart3.Width = 1600
        $chart3.Height = 900


        # create chart area
        $chart1Area = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
        $chart1.ChartAreas.Add($chart1Area)
        $chart2Area = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
        $chart2.ChartAreas.Add($chart2Area)
        $chart3Area = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
        $chart3.ChartAreas.Add($chart3Area)
    
        $chart1Title = New-Object System.Windows.Forms.DataVisualization.Charting.Title
        $chart1Title.Text = "Temperature - $($hours) Hours"
        $chart2Title = New-Object System.Windows.Forms.DataVisualization.Charting.Title
        $chart2Title.Text = "CAPE - $($hours) Hours"
        $chart3Title = New-Object System.Windows.Forms.DataVisualization.Charting.Title
        $chart3Title.Text = "Wind Speed - $($hours) Hours"

        $titleFont = New-Object System.Drawing.Font @('Microsoft Sans Serif', '18',[System.Drawing.FontStyle]::Bold)
        
        $chart1.Titles.Add($chart1Title)
        $chart1Title.Font = $titleFont
        $chart1Area.AxisX.Title = "Time"
        $chart1Area.AxisX.Interval = 3
        $chart1Area.AxisY.Title = "Temperature Celsius"
        $chart1Area.BackColor ="SkyBlue"
        
        $chart2.Titles.Add($chart2Title)
        $chart2Title.Font = $titleFont
        $chart2Area.AxisX.Title = "Time"
        $chart2Area.AxisX.Interval = 3
        $chart2Area.AxisY.Title = "CAPE J/Kg"
        $chart2Area.BackColor ="SkyBlue"

        $chart3.Titles.Add($chart3Title)
        $chart3Title.Font = $titleFont
        $chart3Area.AxisX.Title = "Time"
        $chart3Area.AxisX.Interval = 3
        $chart3Area.AxisY.Title = "Wind Speed Km/h"
        $chart3Area.BackColor ="SkyBlue"


        $weatheChartingObjects = @()
        for ($k=0; $k -lt $maxItems; $k++){
           $tm = $weather.hourly.time[$k]#.split("T")[1]
            [string]$d =  $weather.hourly.time[$k].split("T")[0]
            $chartingItems = @{
                "date" = $d
                "time" =  $tm
                "temp2m" = [double]"$($weather.hourly.temperature_2m[$k])"
                "temp180m" = [double]"$($weather.hourly.temperature_180m[$k])"
                "temp850hPa" =[double]"$($weather.hourly.temperature_850hPa[$k])"
                "dp2m" = [double]"$($weather.hourly.dewpoint_2m[$k])"
                "dp850hPa" = [double]"$($weather.hourly.dewpoint_850hPa[$k])"
                "cp" = [double]"$($weather.hourly.cape[$k])"
                "windsp_10m" = [double]"$($weather.hourly.windspeed_10m[$k])"
                "windsp_850" = [double]"$($weather.hourly.windspeed_850hPa[$k])"
                "windgust10" =[double]"$($weather.hourly.windgusts_10m[$k])"
            }
    
            $weatheChartingObjects += $chartingItems | Select-Object date,time,temp2m,temp180m,temp850hPa,dp2m,dp850hPa,cp,windsp_10m,windsp_850,windgust10
        }
       
        $series1 = $chart1.Series.Add("Temp2m")
        $series1.ChartType = "Spline"
        $series1.Color = "Red"
        $series1.IsValueShownAsLabel = $True
        $series1.BorderWidth = 3

        $series2 = $chart1.Series.Add("Temp180m")
        $series2.ChartType = "Spline"
        $series2.Color = "Yellow"
        $series2.IsValueShownAsLabel = $True
        $series2.BorderWidth = 3

        $series3 = $chart1.Series.Add("Temp850hPa")
        $series3.ChartType = "Spline"
        $series3.Color = "Green"
        $series3.IsValueShownAsLabel = $True
        $series3.BorderWidth = 3

        $series4 = $chart1.Series.Add("DP2m")
        $series4.ChartType = "Spline"
        $series4.Color = "Black"
        $series4.IsValueShownAsLabel = $True
        $series4.BorderWidth = 3

        $series5 = $chart1.Series.Add("DP850hPa")
        $series5.ChartType = "Spline"
        $series5.Color = "White"
        $series5.IsValueShownAsLabel = $True
        $series5.BorderWidth = 3

        $series6 = $chart2.Series.Add("CAPE-J/Kg ")
        $series6.ChartType = "Spline"
        $series6.Color = "Orange"
        $series6.IsValueShownAsLabel = $True
        $series6.BorderWidth = 3

        $series7 = $chart3.Series.Add("Windsp_10m")
        $series7.ChartType = "Spline"
        $series7.Color = "Pink"
        $series7.IsValueShownAsLabel = $True
        $series7.BorderWidth = 3

        $series8 = $chart3.Series.Add("Windsp_850")
        $series8.ChartType = "Spline"
        $series8.Color = "White"
        $series8.IsValueShownAsLabel = $True
        $series8.BorderWidth = 3

        $series9 = $chart3.Series.Add("WindGust10")
        $series9.ChartType = "Spline"
        $series9.Color = "Red"
        $series9.IsValueShownAsLabel = $True
        $series9.BorderWidth = 3

        $leg1 = New-Object System.Windows.Forms.DataVisualization.Charting.Legend
        $leg2 = New-Object System.Windows.Forms.DataVisualization.Charting.Legend
        $leg3 = New-Object System.Windows.Forms.DataVisualization.Charting.Legend

        $leg1 = $chart1.Legends.Add("TemperatureKeys")
        $leg1.BackColor ="skyblue"
        $leg1.BorderColor = "black" 
        $leg1.Alignment = "Center"    
        
        $leg2 = $chart2.Legends.Add("CAPEKey")
        $leg2.BackColor ="skyblue"
        $leg2.BorderColor = "black" 
        $leg2.Alignment = "Center"

        $leg3 = $chart3.Legends.Add("WindSpKeys")
        $leg3.BackColor ="skyblue"
        $leg3.BorderColor = "black" 
        $leg3.Alignment = "Center"

        if (-not (Test-Path -path $topWeatherFolder\$today)) {
            New-Item -Path $topWeatherFolder\$today -ItemType Directory
        }

        $series1.Points.DataBindXY($weatheChartingObjects.time,$weatheChartingObjects.temp2m)
        $series2.Points.DataBindXY($weatheChartingObjects.Time,$weatheChartingObjects.temp180m)
        $series3.Points.DataBindXY($weatheChartingObjects.Time,$weatheChartingObjects.temp850hPa)
        $series4.Points.DataBindXY($weatheChartingObjects.Time,$weatheChartingObjects.dp2m)
        $series5.Points.DataBindXY($weatheChartingObjects.Time,$weatheChartingObjects.dp850hPa)
        $series6.Points.DataBindXY($weatheChartingObjects.Time,$weatheChartingObjects.cp)
        $series7.Points.DataBindXY($weatheChartingObjects.Time,$weatheChartingObjects.windsp_10m)
        $series8.Points.DataBindXY($weatheChartingObjects.Time,$weatheChartingObjects.windsp_850)
        $series9.Points.DataBindXY($weatheChartingObjects.Time,$weatheChartingObjects.windgust10)


        $temperatureChartImage = "$($topWeatherFolder)\$($today)\Temp_$($today)_$($hours)hours.png"
        $chart1.SaveImage($temperatureChartImage,'PNG')
        $capeImageFile = "$($topWeatherFolder)\$($today)\CAPE_$($today)_$($hours)hours.png"
        $chart2.SaveImage($capeImageFile,'PNG')
        $windspImageFile = "$($topWeatherFolder)\$($today)\WindSpeed_$($today)_$($hours)hours.png"
        $chart3.SaveImage($windspImageFile,'PNG')
        
    }
    
    enum codes{
        <# Specify a list of distinct values #>
        Clear = 0
        Mainly_clear
        Partly_cloudy
        Overcast
        Fog = 45
        Depositing_rime_fog = 48
        Light_drizzle = 51
        Moderate_drizzle = 53
        Dense_drizzle = 55
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
    $wj = curl "https://api.open-meteo.com/v1/forecast?latitude=51.69&longitude=-3.92&elevation=50&hourly=temperature_2m,dewpoint_2m,precipitation,weathercode,surface_pressure,pressure_msl,cloudcover,cloudcover_low,cloudcover_mid,cloudcover_high,windspeed_10m,windspeed_850hPa,winddirection_10m,winddirection_850hPa,temperature_180m,cape,temperature_850hPa,dewpoint_850hPa,temperature_700hPa,dewpoint_700hPa,temperature_500hPa,windgusts_10m&models=best_match"
    $weather = $wj | ConvertFrom-Json
    $hourlyData = $weather.hourly
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
        [double]$T850 = $hourlyData.temperature_850hPa[$k]
        [double]$T500 = $hourlyData.temperature_500hPa[$k]
        [double]$Td850 = $hourlyData.dewpoint_850hPa[$k]
        [double]$T700 = $hourlyData.temperature_700hPa[$k]
        [double]$Td700 = $hourlyData.dewpoint_700hPa[$k]
        $kIndex = ($T850 - $T500) + $Td850 - ($T700 - $Td700)
        $TT = ($T850 - $T500) + ($Td850 - $T500)
     

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
            "K-Index" = [math]::round($kIndex , 2)
            "TT-Index" = [math]::round($TT , 2)
            "Wind-Speed-10m" = "$($weather.hourly.windspeed_10m[$k])" + " Km/h" + " " + [math]::round(($weather.hourly.windspeed_10m[$k] * 0.621371),2) + " Mph" + " " + [math]::round(($weather.hourly.windspeed_10m[$k] * 0.539957),2) + " kts"
            "Wind-Gusts-10m" = "$($weather.hourly.windgusts_10m[$k])" + " Km/h" + " " + [math]::round(($weather.hourly.windgusts_10m[$k] * 0.621371),2) + " Mph" + " " + [math]::round(($weather.hourly.windgusts_10m[$k] * 0.539957),2) + " kts"
            "Wind-Dir-10m" = "$($weather.hourly.winddirection_10m[$k])" + [char]0x00b0
            "Wind-Speed-850hPa" = "$($weather.hourly.windspeed_850hPa[$k])" + " Km/h" + " " + [math]::round(($weather.hourly.windspeed_850hPa[$k] * 0.621371),2) + " Mph" + " " + [math]::round(($weather.hourly.windspeed_850hPa[$k] * 0.539957),2) + " kts"
            "Wind-Dir-850hPa" = "$($weather.hourly.winddirection_850hPa[$k])" + [char]0x00b0
            "Pressure-MSL" ="$($weather.hourly.pressure_msl[$k])" + " hPa"
            "Surface-Pressure" ="$($weather.hourly.surface_pressure[$k])" + " hPa"
            "Precipitation" = "$($weather.hourly.precipitation[$k])" + " mm"
            "Cloud-Cover" = "$($weather.hourly.cloudcover[$k])" + "%"
            "Cloud-Cover-Below-3Km" = "$($weather.hourly.cloudcover_low[$k])" + "%"
            "Cloud-Cover-3Km-to-8Km" = "$($weather.hourly.cloudcover_mid[$k])" + "%"
            "Cloud-Cover-Above-8Km" = "$($weather.hourly.cloudcover_high[$k])" + "%"
            "Synopsis" = $Syn       
        }
        
        $wob += $obj | Select-Object Date,Time,Temperature-2m,Dewpoint-2m,Temperature-180m,Temperature-850hPa,Dewpoint-850hPa,CAPE,K-Index,TT-Index,Wind-Speed-10m,Wind-Gusts-10m,Wind-Speed-850hPa,Wind-Dir-10m,Wind-Dir-850hPa,Pressure-MSL,Surface-Pressure,Precipitation,Cloud-Cover-Below-3Km,Cloud-Cover-3Km-to-8Km,Cloud-Cover-Above-8Km,Synopsis
        
    }

    
    makeCharts -maxItems $maxItems

    # Start building html presentation page
    $header = Get-Content  $topWeatherFolder\header.html # simple html5 header with css - change path to taste
        
    $temperatureImageFile = "file:///$($topWeatherFolder)\$($today)\Temp_$($today)_$($hours)hours.png"
    $capeImageFile = "file:///$($topWeatherFolder)\$($today)\CAPE_$($today)_$($hours)hours.png"
    $windspImageFile = "file:///$($topWeatherFolder)\$($today)\WindSpeed_$($today)_$($hours)hours.png"
    $images = "<body>`n<img src=`""+$temperatureImageFile+"`" width=`"1600`" height=`"900`">`n<img src=`""+$capeImageFile+"`" width=`"1600`" height=`"900`">`n<img src=`""+$windspImageFile+"`" width=`"1600`" height=`"900`">`n"
    $table = $wob | ConvertTo-Html 
    $table = $table[5..($table.Length -1)]

    $htmlFile = $header+$images+$table+$end
        
    $htmlFile | Out-File -FilePath $topWeatherFolder\$today\weather-table-Charts_$today_$hours.html
    Invoke-Item $topWeatherFolder\$today\weather-table-Charts_$today_$hours.html
}
 gw 48