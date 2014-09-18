#!/usr/bin/env python3

from gzip import GzipFile
from io import BytesIO
from urllib.parse import urlencode
from urllib.request import urlopen, Request
from bs4 import BeautifulSoup as soup

url="http://in.weather.com/weather/hourByHour/Istanbul+34+Turkey+TUXX0014:1:TU?pagenum=2&nextbeginIndex=0"

if __name__ == "__main__":
    request = Request(url)
    request.add_header('Accept-encoding', 'gzip,deflate')
    bytesIO = BytesIO(urlopen(request).read())
    result = GzipFile(fileobj=bytesIO, mode="rb").read()
    resultTable=soup(result).findAll('div', attrs={"class" : "wx-timepart"})

    print("\n%s%7s%10s %20s\n" % ("Time", u"\u2103", "Rain%", "Conditions"))

    for result in resultTable:
        hour = result.find('h3').text.split("\n")[0]
        hour = "%s:%s" % (hour[:2], hour[2:])
        condition = result.find('p', attrs={'class' : 'wx-phrase'}).text
        temperature, humidity, rain, wind = [x.text.strip() for x  in result.findAll('dd')]
        print("%s%9s%8s %20s" % (hour, temperature, rain, condition))
