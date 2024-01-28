import requests
import openpyxl
import os

wb=openpyxl.load_workbook('TableauTable3.xlsx')
sheet=wb.worksheets[0]
cities=[]
api_key = '58ec7fe0e54745c6bedfab3173aedb29'
for i in range(2, 406):
    cities.append(sheet['A'+str(i)].value)

print(cities)
j=2

for city in cities:    
    url = f'https://api.opencagedata.com/geocode/v1/json?q={city}&key={api_key}&countrycode=1'
    response = requests.get(url)
    data = response.json()
    if (len(data['results'])==0):
        j+=1
        continue
    country = data['results'][0]['components']['country']
    print(f'{city}: {country}')
    sheet['E'+str(j)]=country
    j+=1

wb.save('TableauTable3.xlsx')


