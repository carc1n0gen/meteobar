module meteobar;

import std.stdio;
import std.string;
import std.datetime;
import std.conv : to;
import std.format : format;
import std.range : enumerate;
import std.algorithm : filter;
import std.array : appender, array;
import std.regex : regex, matchFirst;
import std.json : JSONValue, parseJSON;

import core.stdc.locale : setlocale, LC_TIME;

import cli : parseArgs;
import ipinfo : getIpInfo;
import openstreetmap : openStreetMapSearch;
import openmeteo : ParamValue, weatherApi, deMatrixData, getWeatherCodeInfo;
import utils : parseDateTime, formatDateTime, ResponseException, ConnectionException;

const auto LAT_LONG_PATTERN = regex(`^-?\d+(\.\d+)?,-?\d+(\.\d+)?$`);

int main(string[] args)
{
    setlocale(LC_TIME, ""); // Use system locale for date formatting
    auto options = parseArgs(args);

    string longitude;
    string latitude;
    string locationName = "";

    writeln(`{"text":"󰘿","tooltip":"Loading...","class":"loading"}`);
    stdout.flush();

    JSONValue data;
    try
    {
        if (options.location == "auto")
        {
            auto ipInfo = getIpInfo();
            auto locParts = ipInfo.loc.split(",");
            longitude = locParts[0];
            latitude = locParts[1];
            locationName = ipInfo.city ~ ", " ~ ipInfo.region ~ ", " ~ ipInfo.country;
        }
        else if (matchFirst(options.location, LAT_LONG_PATTERN))
        {
            auto locationParts = options.location.split(",");
            if (locationParts.length != 2)
            {
                writeln(`{"text":"", "tooltip":"Invalid location format. Use 'latitude,longitude', 'CITY NAME', or 'auto'.", "class":"error"}`);
                return 0;
            }
            longitude = locationParts[0].strip();
            latitude = locationParts[1].strip();
            locationName = options.location;
        }
        else
        {
            auto location = openStreetMapSearch(options.location);
            longitude = location.latitude;
            latitude = location.longitude;
            locationName = location.name;
        }

        ParamValue[string] params = [
            "latitude": ParamValue(longitude),
            "longitude": ParamValue(latitude),
            "daily": ParamValue(options.daily),
            "hourly": ParamValue(options.hourly),
            "current": ParamValue(options.current),
            "temperature_unit": ParamValue(options.temperatureUnit),
            "wind_speed_unit": ParamValue(options.windSpeedUnit),
            "forecast_days": ParamValue("3"),
            "timezone": ParamValue("auto")
        ];

        data = weatherApi("https://api.open-meteo.com/v1/forecast", params);
        data = deMatrixData(data);
    }
    catch (ResponseException responseEx)
    {
        writeln(`{"text":"", "tooltip":"Invalid API response", "class":"error"}`);
        return 0;
    }
    catch (ConnectionException connectionEx)
    {
        writeln(`{"text":"", "tooltip":"Error reaching API", "class":"error"}`);
        return 0;
    }

    int weatherCode = data["current"].object["weather_code"].integer.to!int; /// JSONValue.integer actually returns a long, but we know it's safe to convert to int since the weather codes are small integers
    auto weatherCodeInfo = getWeatherCodeInfo(weatherCode);

    JSONValue output = JSONValue.init;
    output["text"] = format("%s %s°", weatherCodeInfo.icon, data["current"]["temperature_2m"]
            .floating);

    auto tooltip = appender!string(format(
            "<b>%s</b> %s° (%s°)\n",
            weatherCodeInfo.description,
            data["current"]["temperature_2m"].floating.to!string,
            data["current"]["apparent_temperature"].floating.to!string,
    ));

    tooltip.put(format(
            "Wind Speed: %s %s\n",
            data["current"]["wind_speed_10m"].floating.to!string,
            data["current_units"]["wind_speed_10m"].str
    ));

    tooltip.put(format(
            "Humidity: %s%s\n",
            data["current"]["relative_humidity_2m"].integer.to!string,
            data["current_units"]["relative_humidity_2m"].str
    ));

    tooltip.put(format("Location: %s\n", locationName));

    DateTime dataTime = data["current"]["time"].str.parseDateTime("%Y-%m-%dT%H:%M");
    tooltip.put(format(
            "Observed at: %s\n",
            formatDateTime(dataTime, options.ampm ? "%I:%M %p" : "%H:%M")
    ));

    auto days = data["daily"].array;
    foreach (dayIndex, day; days)
    {
        tooltip.put("\n<b>");

        if (dayIndex == 0)
        {
            tooltip.put("Today, ");
        }
        else if (dayIndex == 1)
        {
            tooltip.put("Tomorrow, ");
        }

        DateTime dayDate = day["time"].str.parseDateTime("%Y-%m-%d");
        DateTime sunrise = day["sunrise"].str.parseDateTime("%Y-%m-%dT%H:%M");
        DateTime sunset = day["sunset"].str.parseDateTime("%Y-%m-%dT%H:%M");
        tooltip.put(format("%s</b>\n", dayDate.formatDateTime(options.dateFormat)));

        tooltip.put(format(
                "%s° %s°  %s  %s\n",
                day["temperature_2m_max"].floating.to!string,
                day["temperature_2m_min"].floating.to!string,
                sunrise.formatDateTime(options.ampm ? "%I:%M %p" : "%H:%M"),
                sunset.formatDateTime(options.ampm ? "%I:%M %p" : "%H:%M")
        ));

        int step = 24 / options.hoursToShow; // Show every nth hour. Total hours in a day (24) divided by the number of hours we want to show
        JSONValue[] hourlyForDay = data["hourly"].array.filter!((hour) {
            DateTime hourDate = hour["time"].str.parseDateTime("%Y-%m-%dT%H:%M");
            return hourDate.hour % step == 0 && hourDate.date == dayDate.date;
        }).array;

        foreach (hourIndex, hour; hourlyForDay)
        {
            DateTime hourTime = hour["time"].str.parseDateTime("%Y-%m-%dT%H:%M");
            auto dayWeatherCodeInfo = getWeatherCodeInfo(hour["weather_code"].integer.to!int);
            tooltip.put(format(
                    "%s %s %4s° %s",
                    hourTime.formatDateTime(options.ampm ? "%I %p" : "%H"),
                    dayWeatherCodeInfo.icon,
                    hour["temperature_2m"].floating.to!string,
                    dayWeatherCodeInfo.description
            ));

            if (hourIndex != hourlyForDay.length - 1 || dayIndex != days.length - 1)
            {
                tooltip.put("\n");
            }
        }
    }

    output["tooltip"] = tooltip.data;
    output["class"] = weatherCodeInfo.description.toLower().replace(" ", "_");
    writeln(output);
    return 0;
}
