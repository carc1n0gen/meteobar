module cli;

import std.stdio;
import std.array : split;
import std.format : format;
import std.getopt : getopt, defaultGetoptPrinter;
import core.stdc.stdlib : exit;


struct CliOptions
{
    string latitude;
    string longitude;
    string[] daily = ["temperature_2m_max", "temperature_2m_min", "sunrise", "sunset", "weather_code"];
    string[] hourly = ["temperature_2m", "apparent_temperature", "relative_humidity_2m", "weather_code"];
    string[] current = ["temperature_2m", "apparent_temperature", "relative_humidity_2m", "wind_speed_10m", "weather_code"];
    string temperatureUnit = "celsius";
    string windSpeedUnit = "kmh";
    bool ampm = false;
    int hoursToShow = 12;
    // string timezone = "";
}

private auto splitParams(ref string[] target) {
    return (string s) { target = s.split(",").dup; };
}

CliOptions parseArgs(string[] args)
{
    CliOptions options;

    auto result = getopt(args,
        "lat", "Latitude of the location", &options.latitude,
        "long", "Longitude of the location", &options.longitude,
        "daily", "Daily variables (comma-separated) (optional)", splitParams(options.daily),
        "hourly", "Hourly variables (comma-separated) (optional)", splitParams(options.hourly),
        "current", "Current variables (comma-separated) (optional)", splitParams(options.current),
        "temp-unit", "Temperature unit (celsius or fahrenheit) (default: celsius)", &options.temperatureUnit,
        "wind-unit", "Wind speed unit (one of kmh, ms, mph, kn) (default: kmh)", &options.windSpeedUnit,
        "ampm", "Use 12-hour time format with AM/PM (default: false)", &options.ampm,
        "hours", "Number of hours to show in the tooltip (default: 12)", &options.hoursToShow,
        // "tz", "Timezone of the location", &options.timezone
    );

    if (result.helpWanted)
    {
        // defaultGetoptPrinter("Usage: " ~ args[0] ~ " [options]", result.options);
        defaultGetoptPrinter(format("Usage: %s [options]", args[0]), result.options);
        exit(0);
    }

    if (!options.latitude || !options.longitude)
    {
        writeln("Error: Latitude and Longitude are required.");
        defaultGetoptPrinter(format("Usage: %s [options]", args[0]), result.options);
        exit(1);
    }

    return options;
}