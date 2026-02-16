module openmeteo;

import std.stdio;

import std.conv;
import std.variant;
import std.array : join;
import std.json : JSONValue;
import std.algorithm.searching : canFind;

import curl = std.net.curl;

private immutable string[] PARAM_ARRAY_KEYS = ["daily", "hourly", "current"];

private immutable string[] MATRIX_ARRAY_KEYS = ["daily", "hourly"];

/**
 * Represents weather description and icon for a given weather code.
 */
struct WeatherCodeInfo
{
    string description;
    string icon;
}

/**
 * An associative array mapping weather codes to their corresponding descriptions and icons.
 */
private immutable WeatherCodeInfo[int] WEATHER_CODE_INFO = [
     0: WeatherCodeInfo("Clear sky",                     "☀️"),
     1: WeatherCodeInfo("Mainly clear",                  "🌤️"),
     2: WeatherCodeInfo("Partly cloudy",                 "⛅"),
     3: WeatherCodeInfo("Overcast",                      "☁️"),
    45: WeatherCodeInfo("Fog",                           "🌫️"),
    48: WeatherCodeInfo("Depositing Rime Fog",           "🌫️"),
    51: WeatherCodeInfo("Light drizzle",                 "🌦️"),
    53: WeatherCodeInfo("Moderate drizzle",              "🌦️"),
    55: WeatherCodeInfo("Dense drizzle",                 "🌦️"),
    56: WeatherCodeInfo("Light freezing drizzle",        "🌧️"),
    57: WeatherCodeInfo("Dense freezing drizzle",        "🌧️"),
    61: WeatherCodeInfo("Light rain",                    "🌦️"),
    63: WeatherCodeInfo("Moderate rain",                 "🌧️"),
    65: WeatherCodeInfo("Heavy rain",                    "🌧️"),
    66: WeatherCodeInfo("Light freezing rain",           "🌧️"),
    67: WeatherCodeInfo("Heavy freezing rain",           "🌧️"),
    71: WeatherCodeInfo("Slight snow fall",              "🌨️"),
    73: WeatherCodeInfo("Moderate snow fall",            "🌨️"),
    75: WeatherCodeInfo("Heavy snow fall",               "❄️"),
    77: WeatherCodeInfo("Snow grains",                   "🌨️"),
    80: WeatherCodeInfo("Slight rain showers",           "🌦️"),
    81: WeatherCodeInfo("Moderate rain showers",         "🌧️"),
    82: WeatherCodeInfo("Violent rain showers",          "⛈️"),
    85: WeatherCodeInfo("Slight snow showers",           "🌨️"),
    86: WeatherCodeInfo("Heavy snow showers",            "❄️"),
    95: WeatherCodeInfo("Thunderstorm",                  "⛈️"),
    96: WeatherCodeInfo("Thunderstorm with slight hail", "⛈️"),
    99: WeatherCodeInfo("Thunderstorm with heavy hail",  "⛈️")
];

/**
 * Retrieves the weather description and icon for a given weather code.
 * Params:
 *   code: (`int`) The weather code for which to retrieve information.
 * Returns:
 *   A `WeatherCodeInfo` struct containing the description and icon for the given weather code.
 */
WeatherCodeInfo getWeatherCodeInfo(int code)
{
    if (code in WEATHER_CODE_INFO)
    {
        return WEATHER_CODE_INFO[code];
    }
    else
    {
        return WeatherCodeInfo("Unknown", "❓");
    }
}

/**
 * Makes a GET request to the specified open-meteo API URL with the given parameters and returns the response as a string.
 * Params:
 *   url: (`string`) The base URL of the open-meteo API endpoint.
 *   parameters: (`Variant[string]`) An associative array of query parameters to include in the API request. The values can be either strings or arrays of strings.
 * Returns:
 *   A `string` containing the response from the open-meteo API.
 */
string weatherApi(string url, Variant[string] parameters)
{
    string paramString = "";
    foreach (kv; parameters.byKeyValue)
    {
        paramString ~= kv.key ~ "=";

        if (canFind(PARAM_ARRAY_KEYS, kv.key))
        {
            paramString ~= kv.value.get!(string[]).join(",");
        }
        else
        {
            paramString ~= kv.value.to!string;
        }

        paramString ~= "&";
    }

    return cast(string)curl.get(url ~ "?" ~ paramString);
}

private JSONValue[] recordsFromMatrix(JSONValue matrix)
{
    size_t n = matrix["time"].array.length; // all the arrays in the matrix like structure are the same length
    JSONValue[] records;

    for (size_t i = 0; i < n; i++)
    {
        JSONValue record = JSONValue.init;
        foreach (key, arr; matrix.object)
        {
            record[key] = arr.array[i];
        }
        records ~= record;
    }

    return records;
}

/**
 * Converts the matrix-like structure returned from open-meteo to arrays of objects.
 *
 * The open-meteo API returns data like the following:
 * ---
 * {
 *   "daily": {
 *     "time": ["2024-06-01", "2024-06-02", "2024-06-03"],
 *     "temperature_2m_max": [25.0, 26.5, 24.0],
 *     "temperature_2m_min": [15.0, 16.0, 14.5]
 *   }
 * }
 * ---
 * This function transforms it into the following format:
 * ---
 * {
 *   "daily": [
 *     {
 *       "time": "2024-06-01",
 *       "temperature_2m_max": 25.0,
 *       "temperature_2m_min": 15.0
 *     },
 *     {
 *       "time": "2024-06-02",
 *       "temperature_2m_max": 26.5,
 *       "temperature_2m_min": 16.0
 *     },
 *     {
 *       "time": "2024-06-03",
 *       "temperature_2m_max": 24.0,
 *       "temperature_2m_min": 14.5
 *     }
 *   ]
 * }
 * ---
 * Params:
 *   data: (`JSONValue`) Parsed JSON data
 * Returns:
 *   A new `JSONValue` with the same data in an array of objects.
 */
JSONValue deMatrixData(JSONValue data)
{
    JSONValue result = JSONValue.init;

    foreach (key, value; data.object)
    {
        if (canFind(MATRIX_ARRAY_KEYS, key))
        {
            result[key] = recordsFromMatrix(value);
        }
        else
        {
            result[key] = value;
        }
    }

    return result;
}
