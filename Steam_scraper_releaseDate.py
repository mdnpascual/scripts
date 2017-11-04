import scrapy
import csv
from scrapy.http import HtmlResponse
from scrapy.http import FormRequest
from urllib2 import urlopen
from scrapy.http.request import Request

start_url = [""]
i = 0
f1=open('./release_Date.csv', 'w+')

with open('C:\Users\MDuh\Desktop\scrape\idvals.csv', 'rb') as csvfile:
	linkreader = csv.reader(csvfile, dialect=csv.excel)
	for row in linkreader:
		start_url.append("http://store.steampowered.com/app/"+str(row)[2:-2])
		i += 1

def real(response):
    date = response.css('#game_highlights > div.rightcol > div > div.glance_ctn_responsive_left > div > div.release_date > div.date::text').extract_first()
    f1.write(response.url + ", " + date + "\n")   

class release_Date(scrapy.Spider):

    name = "release_Date"
    #allowed_domains = ["http://store.steampowered.com"]
    start_urls = start_url
    start_urls.pop(0)
        
    def parse(self, response):
        # Circumvent age selection form.
        if 'agecheck' in response.url:
            form = response.css('#agegate_box form')

            action = form.xpath('@action').extract_first()
            name = form.xpath('input/@name').extract_first()
            value = form.xpath('input/@value').extract_first()

            formdata = {
                name: value,
                'ageDay': '1',
                'ageMonth': '1',
                'ageYear': '1955'
            }

            yield FormRequest(
                url=action,
                method='POST',
                formdata=formdata,
                callback=self.parse
            )
        else:
            yield real(response)   
