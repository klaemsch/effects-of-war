## How to download and clean event data

All the files used in this step can be found in the "data" directory of the repository.

1.  Download events in time frame 01.09.2022 to 27.01.2024 using python script.

2.  Use "import_events_csv_into_db.R" to import events to SQLite DB.

3.  Edit the table with an SQLite tool so the GLOBALEVENTID Row is the primary key and unique to prevent identical entries get added twice (example in "data_cleaning.sql").

4.  Use "data_cleaning.sql" to extract the domain from the source url.

## How to download and clean country data

Because we are handling a lot of country data and need the coordinates for each country, in this step I created a mapping, that maps the country-names and country-codes to coordinates. The data I used in this step can be found in the "country_data" directory of the repository.

1.  Download [this](https://developers.google.com/public-data/docs/canonical/countries_csv?hl=en) list. It maps the name of each country to the countries coordinates.

2.  Download [this](E:\HiDrive\HiDrive\Dokumente\Studium\Digital Humanities\Module\Introduction Digital Humanities\projektarbeit\documentation\1.	https:\www.kaggle.com\datasets\aniketkolte04\the-ultimate-country-code-repository?resource=download) list. It holds different country codes for each country and is useful for translating between them (FIPS \<-\> ISO).

3.  Using the "create_country_data.R" script I created "country_data.R" which maps the countries to their coordinates.

## How to download and clean domain data

The data I used in this step can be found in the "domains" directory of the repository.

1.  Download [this](https://blog.gdeltproject.org/mapping-the-media-a-geographic-lookup-of-gdelts-sources-2015-2021/) csv file. It lists the top five countries that each news outlet (domain) queried by the GDELT project reported on. (There exist different versions of this list, use the most current)

2.  Using the country data created before, I created a mapping that maps each domain used in GDELT to their country of origin and their coordinates.
