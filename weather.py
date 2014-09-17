#!/usr/bin/env python3

import json
import sys
import urllib.request

location="TR/Istanbul"
apikey=""
url = "https://api.wunderground.com/api/%s/hourly/q/%s.json" % (apikey, location)
hourlyForecast = {}

def getHourly():
    response = urllib.request.urlopen(url)
    data = json.loads(response.read().decode("utf-8"))

    for entry in data["hourly_forecast"]:
        hour_string = "%s:%s" % (entry["FCTTIME"]["hour_padded"], entry["FCTTIME"]["min"])

        d = {}
        d["temperature"] = entry["temp"]["metric"]
        d["condition"] = entry["condition"]
        d["rain"] = entry["pop"]

        hourlyForecast[hour_string] = d

if __name__ == "__main__":
    if not apikey:
        print("Get an api key from https://wunderground.com/weather/api/d/pricing.html")
        sys.exit(1)

    getHourly()

    print("%7s%7s%10s %10s\n" % ("Time", u"\u2103", "Rain", "Conditions"))
    for key in sorted(hourlyForecast):
        d = hourlyForecast[key]
        print("%8s%8s%8s%% %10s" % (key, d["temperature"], d["rain"], d["condition"]))

