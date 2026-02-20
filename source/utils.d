module utils;

import std.stdio;
import std.conv : to;
import std.math : round;
import std.format : format;
import std.math : isFinite;
import std.array : Appender;
import std.string : toStringz;
import std.json : JSONType, JSONValue;
import std.datetime : DateTime, DateTimeException;

import core.stdc.time : tm, strftime;

extern(C) char* strptime(const char* s, const char* format, tm* timeptr); // The POSIX C extension strptime function


/**
 * Parses a date string into a `DateTime` object using the specified format.
 * Params:
 *   dateStr: (`string`) The date string to parse.
 *   formatStr: (`string`) The format string that describes the expected format of `dateStr`.
 * Returns:
 *   A `DateTime` object representing the parsed date and time.
 * Throws:
 *   `DateTimeException` if the date string cannot be parsed according to the provided format.
 */
DateTime parseDateTime(string dateStr, string formatStr)
{
    tm timeStruct = {};
    timeStruct.tm_year = 70; // 1900 gets added to this, so this represents 1970
    timeStruct.tm_mon = 0;   // January
    timeStruct.tm_mday = 1;  // 1st of the month
	auto result = strptime(dateStr.toStringz, formatStr.toStringz, &timeStruct); // Make sure to use .toStringz not .ptr to get null terminated strings
	if (result is null)
	{
		throw new DateTimeException("Failed to parse time string.");
	}
	return DateTime(timeStruct.tm_year + 1900, timeStruct.tm_mon + 1, timeStruct.tm_mday,
		timeStruct.tm_hour, timeStruct.tm_min, timeStruct.tm_sec);
}

/** 
 * Formats a `DateTime` object into a string using the specified format.
 * Params:
 *   dt: (`DateTime`) The `DateTime` object to format.
 *   formatStr: (`string`) The format string that describes the desired output format.
 * Returns:
 *   A `string` representing the formatted date and time.
 */
string formatDateTime(DateTime dt, string formatStr)
{
    tm timeStruct = {};
	timeStruct.tm_year = dt.year - 1900;
	timeStruct.tm_mon = dt.month - 1;
	timeStruct.tm_mday = dt.day;
	timeStruct.tm_hour = dt.hour;
	timeStruct.tm_min = dt.minute;
	timeStruct.tm_sec = dt.second;

	char[100] buffer = 0; // Buffer to hold the formatted string
	auto len = strftime(buffer.ptr, buffer.length, formatStr.toStringz, &timeStruct);
	return buffer[0..len].idup; // Return only the used portion as a D string
}
