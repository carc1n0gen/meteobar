module meteobar;

import std.stdio;
import std.string;
import std.variant;
import std.datetime;
import std.conv : to;
import std.format : format;
import std.range : enumerate;
import std.algorithm : filter;
import std.array: appender, array;
import std.json : JSONValue, parseJSON;

import cli : parseArgs;
import utils : dateTimeToTimeString, dateToHourString;
import openmeteo : weatherApi, deMatrixData, getWeatherCodeInfo, OpenMeteoResponseException, OpenMeteoConnectionException;


int main(string[] args)
{
	auto options = parseArgs(args);
	Variant[string] params = [
		"latitude":         Variant(options.latitude),
		"longitude":        Variant(options.longitude),
		"daily":            Variant(options.daily),
		"hourly":           Variant(options.hourly),
		"current":          Variant(options.current),
		"temperature_unit": Variant(options.temperatureUnit),
		"wind_speed_unit":  Variant(options.windSpeedUnit),
		"forecast_days":    Variant(3),
		"timezone":         Variant("auto")
	];

	writeln(`{"text":"⏳","tooltip":"Loading...","class":"loading"}`);
	stdout.flush();

	JSONValue data;
	try
	{
		data = weatherApi("https://api.open-meteo.com/v1/forecast", params);
		data = deMatrixData(data);
	}
	catch (OpenMeteoResponseException responseEx)
	{
		writeln(`{"text":"⛓️‍💥", "tooltip":"Invalid open-meteo response", "class":"error"}`);
		return 0;
	}
	catch (OpenMeteoConnectionException connectionEx)
	{
		writeln(`{"text":"⛓️‍💥", "tooltip":"Error reaching open-meteo API", "class":"error"}`);
		return 0;
	}

	int weatherCode = data["current"].object["weather_code"].integer.to!int; /// JSONValue.integer actually returns a long, but we know it's safe to convert to int since the weather codes are small integers
	auto weatherCodeInfo = getWeatherCodeInfo(weatherCode);

	JSONValue output = JSONValue.init;
	output["text"] = format("%s %s°", weatherCodeInfo.icon, data["current"]["temperature_2m"].floating);

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

	auto dataTime = DateTime.fromISOExtString(data["current"]["time"].str ~ ":00");
	tooltip.put(format(
		"Observed at: %s\n",
		dateTimeToTimeString(dataTime, options.ampm)
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

		DateTime dayDate = DateTime.fromISOExtString(day["time"].str ~ "T00:00:00");
		DateTime sunrise = DateTime.fromISOExtString(day["sunrise"].str ~ ":00");
		DateTime sunset = DateTime.fromISOExtString(day["sunset"].str ~ ":00");
		tooltip.put(format("%s</b>\n", dayDate.toISOExtString.split("T")[0])); // just the date part

		tooltip.put(format(
			"⬆️ %s° ⬇️ %s° 🌅 %s 🌇 %s\n",
			day["temperature_2m_max"].floating.to!string,
			day["temperature_2m_min"].floating.to!string,
			dateTimeToTimeString(sunrise, options.ampm),
			dateTimeToTimeString(sunset, options.ampm)
		));
		
		int step = 24 / options.hoursToShow; // Show every nth hour. Total hours in a day (24) divided by the number of hours we want to show
		auto hourlyForDay = data["hourly"].array.filter!((hour) {
			DateTime hourDate = DateTime.fromISOExtString(hour["time"].str ~ ":00");
			return hourDate.hour % step == 0 && hourDate.date == dayDate.date;
		}).array;

		foreach (hourIndex, hour; hourlyForDay)
		{
			DateTime hourTime = DateTime.fromISOExtString(hour["time"].str ~ ":00");
			auto dayWeatherCodeInfo = getWeatherCodeInfo(hour["weather_code"].integer.to!int);
			tooltip.put(format(
				"%s %s %4s° %s",
				dateToHourString(hourTime, options.ampm),
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
