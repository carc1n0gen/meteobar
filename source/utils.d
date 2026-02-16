module utils;

import std.conv : to;
import std.math : round;
import std.format : format;
import std.math : isFinite;
import std.array : Appender;
import std.datetime : DateTime;
import std.json : JSONType, JSONValue;


// private void appendJsonRounded(ref Appender!string sink, JSONValue value, int decimals)
// {
//     final switch (value.type)
//     {
//     case JSONType.object:
//         {
//             sink.put('{');
//             bool first = true;
//             foreach (k, v; value.object)
//             {
//                 if (!first)
//                     sink.put(',');
//                 first = false;
//                 sink.put('"');
//                 sink.put(k);
//                 sink.put('"');
//                 sink.put(':');
//                 appendJsonRounded(sink, v, decimals);
//             }
//             sink.put('}');
//             break;
//         }
//     case JSONType.array:
//         {
//             sink.put('[');
//             bool first = true;
//             foreach (v; value.array)
//             {
//                 if (!first)
//                     sink.put(',');
//                 first = false;
//                 appendJsonRounded(sink, v, decimals);
//             }
//             sink.put(']');
//             break;
//         }
//     case JSONType.string:
//         sink.put('"');
//         sink.put(value.str);
//         sink.put('"');
//         break;
//     case JSONType.integer:
//         sink.put(value.integer.to!string);
//         break;
//     case JSONType.uinteger:
//         sink.put(value.uinteger.to!string);
//         break;
//     case JSONType.float_:
//         {
//             double f = value.floating;
//             if (!isFinite(f))
//             {
//                 sink.put("null");
//                 break;
//             }

//             double factor = 10.0 ^^ decimals;
//             double rounded = round(f * factor) / factor;
//             if (rounded == 0)
//                 rounded = 0; // avoid "-0.0"
//             sink.put(format("%.*f", decimals, rounded));
//             break;
//         }
//     case JSONType.true_:
//         sink.put("true");
//         break;
//     case JSONType.false_:
//         sink.put("false");
//         break;
//     case JSONType.null_:
//         sink.put("null");
//         break;
//     }
// }

// /**
//  * Converts a JSONValue to a JSON string, rounding all floating-point numbers to the specified number of decimal places.
//  * Params:
//  *   value: (`JSONValue`) The JSON value to convert.
//  *   decimals: (`int`) The number of decimal places to round floating-point numbers to.
//  * Returns:
//  *   A `string` containing the JSON representation of the input value with rounded floating-point numbers.
//  */
// string toJsonRoundedFloats(JSONValue value, int decimals = 1)
// {
//     Appender!string sink;
//     appendJsonRounded(sink, value, decimals);
//     return sink.data;
// }

/**
 * Converts a `DateTime` object to a time string in the format "HH:MM" or "HH:MM AM/PM".
 * Params:
 *   dt: (`DateTime`) The `DateTime` object to convert.
 *   ampm: (`bool`, optional) If `true`, the time will be formatted in 12-hour format with AM/PM. If `false`, it will be formatted in 24-hour format. Default is `false`.
 * Returns:
 *   A `string` representing the time in the specified format.
 */
string dateTimeToTimeString(DateTime dt, bool ampm = false)
{
    if (ampm)
    {
        int hour = dt.hour % 12;

        if (hour == 0)
        {
            hour = 12;
        }

        string ampmStr = dt.hour < 12 ? "AM" : "PM";
        return format("%02d:%02d %s", hour, dt.minute, ampmStr);
    }
    else
    {
        return format("%02d:%02d", dt.hour, dt.minute);
    }
}

/**
 * Extracts the hour from a `DateTime` object as a string in 12 or 24-hour format.
 * Params:
 *   dt: (`DateTime`) The `DateTime` object to extract the hour from.
 *   ampm: (`bool`, optional) If `true`, the hour will be formatted in 12-hour format with AM/PM. If `false`, it will be formatted in 24-hour format. Default is `false`.
 * Returns: The extracted hour as a string.
 */
string dateToHourString(DateTime dt, bool ampm = false)
{
    if (ampm)
    {
        int hour = dt.hour % 12;
        if (hour == 0)
        {
            hour = 12;
        }
        string ampmStr = dt.hour < 12 ? "AM" : "PM";
        return format("%02d %s", hour, ampmStr);
    }
    else
    {
        return format("%02d", dt.hour);
    }
}
