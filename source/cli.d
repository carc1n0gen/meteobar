module cli;

import std.stdio;
import std.array : split;
import std.string : strip;
import std.format : format;
import std.getopt : getopt, defaultGetoptPrinter, GetoptResult, GetOptException;
import core.stdc.stdlib : exit;

struct CliOptions
{
    string location = "auto";
    string[] daily = [
        "temperature_2m_max", "temperature_2m_min", "sunrise", "sunset",
        "weather_code"
    ];
    string[] hourly = [
        "temperature_2m", "apparent_temperature", "relative_humidity_2m",
        "weather_code"
    ];
    string[] current = [
        "temperature_2m", "apparent_temperature", "relative_humidity_2m",
        "wind_speed_10m", "weather_code"
    ];
    string temperatureUnit = "celsius";
    string windSpeedUnit = "kmh";
    bool ampm = false;
    int hoursToShow = 12;
    string dateFormat = "%Y-%m-%d";
}

private auto splitParams(ref string[] target)
{
    return (string s) { target = s.split(",").dup; };
}

CliOptions parseArgs(string[] args)
{
    CliOptions options;
    GetoptResult result;
    try
    {
        result = getopt(args,
            "location", "Location in form of 'lat,long', 'CITY NAME', or 'auto' for auto-detection (default: auto)", &options.location,
            "daily", "Daily variables (comma-separated) (optional)", splitParams(options.daily),
            "hourly", "Hourly variables (comma-separated) (optional)", splitParams(options.hourly),
            "current", "Current variables (comma-separated) (optional)", splitParams(options.current),
            "temp-unit", "Temperature unit (celsius or fahrenheit) (default: celsius)", &options.temperatureUnit,
            "wind-unit", "Wind speed unit (one of kmh, ms, mph, kn) (default: kmh)", &options.windSpeedUnit,
            "ampm", "Use 12-hour time format with AM/PM (default: false)", &options.ampm,
            "shown-hours", "Number of hours to show in the tooltip per day (default: 12)", &options.hoursToShow,
            "date-format", "Date format string for daily forecasts (default: %Y-%m-%d)", &options.dateFormat,
        );
    }
    catch (GetOptException getoptException)
    {
        writeln(getoptException.msg);
        writeln(format("Run '%s --help' for available options.", args[0]));
        exit(1);
    }

    if (result.helpWanted)
    {
        defaultGetoptPrinter(format("Usage: %s [options]", args[0]), result.options);
        exit(0);
    }

    return options;
}
