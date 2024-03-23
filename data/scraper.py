import requests
import zipfile
import io
import time
from datetime import datetime, timedelta

from file_index import FileIndex

def is_file_already_downloaded(file_id):
    if FILE_INDEX.has_id(file_id):
        print(f"{file_id} exists. Details: {FILE_INDEX.get_by_id(file_id)}")
        return True
    else:
        print(f"{file_id} does not exist in the folder.")
        return False

def format_date(date):
    return date.strftime('%Y%m%d%H%M%S')

# gets a datetime object and generates a url to crawl the events at that datetime
def get_url(date):
    return f'http://data.gdeltproject.org/gdeltv2/{format_date(date)}.mentions.CSV.zip'

def save_file(response_data):
    with zipfile.ZipFile(io.BytesIO(response_data.content)) as zip_ref:
        # Extract the contents of the zip file (you can specify a different directory)
        zip_ref.extractall('./mentions-out')


# create the start date object, e.g. the 1st September 2023 at 00:00:00
START_DATE = datetime(2023, 9, 1, 0, 0, 0, 0)

# create increment object, e.g. 1 hour
INCREMENT =  timedelta(hours=1)

# create the end date object, e.g. the 1st November 2023 at 00:00:00
END_DATE =   datetime(2023, 10, 1, 0, 0, 0)

FILE_INDEX = FileIndex()
FILE_INDEX.load_from('./index.pkl')

date = START_DATE

while True:

    if date > END_DATE:
        print('Job finished, all files in time range downloaded.')
        break

    file_id = format_date(date)

    if is_file_already_downloaded(file_id):
        # file already downloaded and saved on disk
        pass
    else:
        # file not downloaded, start download
        url = get_url(date)
        
        response = requests.get(url)

        if response.status_code == 200:
            print(f'{file_id} downloaded!')
            save_file(response)
        
        else:
            print(f'Failed to download the zip file. Status Code: {response.status_code}, URL: {url}')
    
    time.sleep(0.25)
    date += INCREMENT
