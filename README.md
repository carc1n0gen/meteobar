# Meteobar

CLI tool for generating weather data for waybar using [open-meteo API](https://open-meteo.com/). Heavily inspired by [wttrbar](https://github.com/bjesus/wttrbar).

**Indicator**

<img width="93" height="57" alt="image" src="https://github.com/user-attachments/assets/8914f3ef-a638-4ce9-947f-2651287ce688" />

<br />
<br />

**Tooltip**

<img width="397" height="912" alt="image" src="https://github.com/user-attachments/assets/6b9e5414-2745-4c91-a302-91ef030a5780" />

## Installation

### From Source

Install `ldc` (or `dmd` if you prefer) and `dub` on your distro of choice then compile the project with `dub build` or `dub build --build=release`. Then move the compiled `meteobar` binary somewhere in your path.

### From Release

Head over to [releases](https://github.com/carc1n0gen/meteobar/releases), download the latest version, extract the .tar.gz, and put the resulting `meteobar` binary somewhere in your path.

## Requirements

Really the only thing you need on your system is a [nerd patched font](https://www.nerdfonts.com/).

## Usage

```
Usage: meteobar [options]
      --location Location in form of 'lat,long', 'CITY NAME', or 'auto' for auto-detection (default: auto)
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

```json
// config.jsonc
"custom/meteobar": {
    "format": "{}",
    "tooltip": true,
    "restart-interval": 3600,
    "exec": "meteobar", // With no args passed, location is determined by ip geolocation
    "return-type": "json"
}
```

```css
/* style.css */
* {
    font-family: "Noto Sans Mono", "NotoSans Nerd Font";
    font-size: 16px;
}
```

For the best experience I recommend using a monospace font for at least the tooltips if not the whole waybar. Also set a second font that's been patched with nerd fonts in order for weather icons to render correctly. If you find that the weather icons look really small or squished, try a non-monospace nerd patched font as the second font in your font stack.

## TODO

- translations support
- ~~custom date formats~~
- ~~location auto-detection~~
- ~~param to defined how many hours per day to show hourly data for~~
