## Installation

### From Source

Install `ldc` (or `dmd` if you prefer) and `dub` on your distro of choice then compile the project with `dub build` or `dub build --build=release`. Then move the compiled `meteobar` binary somewhere in your path.

### From Release

Head over to [releases](https://github.com/carc1n0gen/meteobar/releases), download the latest version, extract the .tar.gz, and put the resulting `meteobar` binary somewhere in your path.

## Usage

```
Usage: meteobar [options]
           --lat Latitude of the location
          --long Longitude of the location
         --daily Daily variables (comma-separated) (optional)
        --hourly Hourly variables (comma-separated) (optional)
       --current Current variables (comma-separated) (optional)
     --temp-unit Temperature unit (celsius or fahrenheit) (default: celsius)
     --wind-unit Wind speed unit (one of kmh, ms, mph, kn) (default: kmh)
          --ampm Use 12-hour time format with AM/PM (default: false)
   --shown-hours Number of hours to show in the tooltip per day (default: 12)
   --date-format Date format string for daily forecasts (default: %Y-%m-%d)
-h        --help This help information.
```

The `--daily`, `--hourly`, and `--current` have default values if not provided:

**daily**: `temperature_2m_max,temperature_2m_min,sunrise,sunset,weather_code`

**hourly**: `temperature_2m,apparent_temperature,relative_humidity_2m,weather_code`

**current**: `temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,weather_code`

## Waybar Config

(example location set to Toronto)

```
"custom/meteobar": {
    "format": "{}",
    "tooltip": true,
    "restart-interval": 3600,
    "exec": "meteobar --lat=43.71 --long=-79.54",
    "return-type": "json"
}
```

You can get your latitude/longitude pretty easily with `curl ipinfo.io`, or even better if you have `jq` installed you can run `curl -s ipinfo.io | jq -r '.loc'`

For the data in the tooltip to align correctly, it is best to use a monospace font for waybar, or at least the tooltips.

## TODO

- translations support
- ~~custom date formats~~
- location auto-detection
- ~~param to defined how many hours per day to show hourly data for~~
