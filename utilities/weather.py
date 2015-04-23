#!/usr/bin/env python3

from gzip import GzipFile
from io import BytesIO
from urllib.parse import urlencode
from urllib.request import urlopen, Request
from bs4 import BeautifulSoup as soup

locString = "TUIT0337"
url = "http://in.weather.com/weather/hourByHour/%s?pagenum=2&nextbeginIndex=0" % locString
ua = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2159.4 Safari/537.36'

if __name__ == "__main__":
    request = Request(url)
    request.add_header('Accept-encoding', 'gzip,deflate')
    request.add_header('User-Agent', ua)
    bytesIO = BytesIO(urlopen(request).read())
    data = GzipFile(fileobj=bytesIO, mode="rb").read()
    bs = soup(data)
    resultTable = bs.findAll('div', attrs={"class" : "wx-timepart"})

    print("\n%s%8s%10s %19s\n" % ("Time", "\u2103", "Rain%", "Conditions"))

    updateTime = bs.find('p', attrs={'class' : 'wx-timestamp'}).text.strip()

    for result in resultTable:
        hour = result.find('h3').text.split("\n")[0]
        hour = "%s:%s" % (hour[:2], hour[2:])
        condition = result.find('p', attrs={'class' : 'wx-phrase'}).text
        temperature, humidity, rain, wind = [x.text.strip() for x  in result.findAll('dd')]
        print("%s%9s%8s %20s" % (hour, temperature, rain, condition))

    print("\n%s" % updateTime.replace("\n"," "))
