import scrapy
import csv
from scrapy.http import HtmlResponse
from scrapy.http import FormRequest
from urllib2 import urlopen
from scrapy.http.request import Request

start_url = [""]
i = 0
f1=open('./Movie_Scrape.csv', 'w+')

with open('C:\Users\MDuh\Desktop\scrape\idvals.csv', 'rb') as csvfile:
	linkreader = csv.reader(csvfile, dialect=csv.excel)
	for row in linkreader:
		start_url.append(str(row)[2:-2])
		i += 1
		
f1.write("Released, Released Worldwide, Year Released, Year Released Worldwide, Title, \
Theatrical Distributor, Genre, Source, Production Method, Creative Type, Production Budget, \
Opening Weekend Theaters, Maximum Theaters, Theatrical Engagements, \
Opening Weekend Revenue, Domestic Box Office, Infl. Adj. Dom.Box Office, \
International Box Office, Worldwide Box Office \n")

class movie_scrape(scrapy.Spider):

    name = "movie_scrape"
    start_urls = start_url
    start_urls.pop(0)
    
    def parse(self, response):
	
		rows = response.xpath('//*[@id="page_filling_chart"]/center/table//tr')
		
		for row in rows:
			f1.write(str(row.xpath(".//td[2]/text()").extract_first(default='None')).replace(",", " ") + ",")
			f1.write(str(row.xpath(".//td[3]/text()").extract_first(default='None')).replace(",", " ") + ",")
			f1.write(str(row.xpath(".//td[4]/text()").extract_first(default='None')).replace(",", " ") + ",")
			f1.write(str(row.xpath(".//td[5]/text()").extract_first(default='None')).replace(",", " ") + ",")
			f1.write(str(unicode(row.xpath(".//td[6]/b/a/text()").extract_first(default='None')).encode('utf8')).replace(",", "||") + ",")
			f1.write(str(unicode(row.xpath(".//td[7]/b/a/text()").extract_first(default='None')).encode('utf8')).replace(",", "||") + ",")
			f1.write(str(row.xpath(".//td[8]/a/text()").extract_first(default='None')).replace(",", " ") + ",")
			f1.write(str(unicode(row.xpath(".//td[9]/b/a/text()").extract_first(default='None')).encode('utf8')).replace(",", "||") + ",")
			f1.write(str(row.xpath(".//td[10]/a/text()").extract_first(default='None')).replace(",", "") + ",")
			f1.write(str(row.xpath(".//td[11]/a/text()").extract_first(default='None')).replace(",", "") + ",")
			f1.write(str(row.xpath(".//td[12]/text()").extract_first(default='None')).replace(",", "") + ",")
			f1.write(str(row.xpath(".//td[13]/text()").extract_first(default='None')).replace(",", "") + ",")
			f1.write(str(row.xpath(".//td[14]/text()").extract_first(default='None')).replace(",", "") + ",")
			f1.write(str(row.xpath(".//td[15]/text()").extract_first(default='None')).replace(",", "") + ",")
			f1.write(str(row.xpath(".//td[16]/text()").extract_first(default='None')).replace(",", "") + ",")
			f1.write(str(row.xpath(".//td[17]/text()").extract_first(default='None')).replace(",", "") + ",")
			f1.write(str(row.xpath(".//td[18]/text()").extract_first(default='None')).replace(",", "") + ",")
			f1.write(str(row.xpath(".//td[19]/text()").extract_first(default='None')).replace(",", "") + ",")
			f1.write(str(row.xpath(".//td[20]/text()").extract_first(default='None')).replace(",", "") + "\n")
