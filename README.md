## Installation

Install `dmd` and `dub` on your distro of choice then compile the project with `dub build` or `dub build --build=release`

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
-h      --help This help information.
```

## Waybar Config

```
"custom/wttrbar": {
    "format": "{}",
    "tooltip": true,
    "restart-interval": 3600,
    "exec": "meteobar --lat=43.71 --long=-79.54",
    "return-type": "json"
}
```

You can get your latitude/longitude pretty easily with `curl ipinfo.io`, or even better if you have `jq` installed you can run `curl -s ipinfo.io | jq -r '.loc'`

## TODO

- translations support
- custom date formats
- location auto-detection
