module openstreetmap;

import std.json : parseJSON, JSONValue;
import std.uri : encodeComponent;

import curl = std.net.curl;

import utils : apiBackoffRetry;

struct OpenStreetMapLocation
{
    string name;
    string latitude;
    string longitude;
}

OpenStreetMapLocation openStreetMapSearch(string query)
{
    string response;
    JSONValue json;
    apiBackoffRetry(() {
        response = cast(string) curl.get(
            "https://nominatim.openstreetmap.org/search?q=" ~ encodeComponent(
            query) ~ "&format=json&limit=1");
        json = parseJSON(response);
    });

    OpenStreetMapLocation location;
    location.name = json[0]["name"].str;
    location.latitude = json[0]["lat"].str;
    location.longitude = json[0]["lon"].str;
    return location;
}
