module ipinfo;

import std.json : JSONValue, parseJSON;

import curl = std.net.curl;

import utils : apiBackoffRetry;

struct IpInfo
{
    string ip;
    string hostname;
    string city;
    string region;
    string country;
    string loc;
    string org;
    string postal;
    string timezone;
    string readme;
}

/**
 * Fetches IP information from the ipinfo.io API.
 *
 * @return An IpInfo struct containing the IP information, see https://ipinfo.io/developers for more details.
 */
IpInfo getIpInfo()
{
    string response;
    JSONValue json;
    apiBackoffRetry(() {
        response = cast(string) curl.get("https://ipinfo.io/json");
        json = parseJSON(response);
    });

    IpInfo info;
    info.ip = json["ip"].str;
    info.hostname = json["hostname"].str;
    info.city = json["city"].str;
    info.region = json["region"].str;
    info.country = json["country"].str;
    info.loc = json["loc"].str;
    info.org = json["org"].str;
    info.postal = json["postal"].str;
    info.timezone = json["timezone"].str;
    info.readme = json["readme"].str;
    return info;
}
