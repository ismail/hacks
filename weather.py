#!/usr/bin/env python3

import json
import urllib.request

location="TR/Istanbul"
apikey="ADDYOURAPIKEY"
url = "https://api.wunderground.com/api/%s/hourly/q/%s.json" % (apikey, location)
hourlyForecast = {}

def getHourly():
    response = urllib.request.urlopen(url)
    data = json.loads(response.read().decode("utf-8"))

    for entry in data["hourly_forecast"]:
        hour_string = "%s:%s" % (entry["FCTTIME"]["hour_padded"], entry["FCTTIME"]["min"])
        temperature = entry["temp"]["metric"]
        condition = entry["condition"]

        d = {}
        d["temperature"] = temperature
        d["condition"] = condition

        hourlyForecast[hour_string] = d

if __name__ == "__main__":
    getHourly()
    for key in sorted(hourlyForecast):
        d = hourlyForecast[key]
        print("%8s%8s %10s" % (key, d["temperature"], d["condition"]))

