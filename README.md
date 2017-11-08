# p5-Whosonfirst-MaxMind-Writer

Perl libraries and tools for generating MaxMindDB compatible databases from Who's On First data. This still needs to be documented properly.

## Setup

```
sudo perl ./Build.PL
sudo ./Build build
sudo ./Build installdeps
sudo ./Build install
```

This package is meant to be used in concert with the following other (not-Perl) packages:

* https://github.com/whosonfirst/py-mapzen-whosonfirst-maxmind
* https://github.com/whosonfirst/go-whosonfirst-mmdb

## Usage

This section is incomplete.

The first two steps are to prepare the raw MaxMind GeoLite2 data and to establish concordances with Who's On First. These two tools will/should probably be merged in to one but today they are not...

```
/usr/local/py-mapzen-whosonfirst-maxmind/scripts/wof-mmdb-build-concordances --apikey mapzen-*** --countries /usr/local/data/whosonfirst-data/meta/wof-country-latest.csv GeoLite2-Country-CSV_20170801/GeoLite2-Country-Locations-en.csv > /usr/local/maxmind-data/201711/GeoLite2-City-CSV_20171003/wof-geonames.csv

./bin/wof-mmdb-prepare -concordances /usr/local/maxmind-data/201711/GeoLite2-City-CSV_20171003/wof-geonames.csv /usr/local/maxmind-data/201711/GeoLite2-City-CSV_20171003/wof-geonames-lookup.json
```

Then you use this package to generate a new `mmdb` database.

```
perl /usr/local/p5-Whosonfirst-MaxMind-Writer/scripts/build-wof-mmdb.pl -s /usr/local/maxmind-data/201711/GeoLite2-City-CSV_20171003/GeoLite2-City-Blocks-IPv4.csv -d cities.mmdb -l maxmind-data/201711/GeoLite2-City-CSV_20171003/wof-geonames-lookup.json
```

Finally you can test the database with tools in the `go-whosonfirst-mmdb` package.

```
/usr/local/go-whosonfirst-mmdb/bin/wof-mmdb -db cities.mmdb 88.190.229.170  | python -mjson.tool
{
    "88.190.229.170": {
        "mz:is_ceased": -1,
        "mz:is_current": -1,
        "mz:is_deprecated": 0,
        "mz:is_superseded": 0,
        "mz:is_superseding": 0,
        "mz:latitude": 48.859116,
        "mz:longitude": 2.331839,
        "mz:max_latitude": 48.9016495,
        "mz:max_longitude": 2.416342,
        "mz:min_latitude": 48.815857,
        "mz:min_longitude": 2.22372773135544,
        "mz:uri": "https://whosonfirst.mapzen.com/data/101/751/119/101751119.geojson",
        "wof:country": "FR",
        "wof:id": 101751119,
        "wof:name": "Paris",
        "wof:parent_id": 102068177,
        "wof:path": "101/751/119/101751119.geojson",
        "wof:placetype": "locality",
        "wof:repo": "whosonfirst-data",
        "wof:superseded_by": [],
        "wof:supersedes": []
    }
}
```

## See also

* https://whosonfirst.mapzen.com/mmdb/
* https://blog.maxmind.com/2015/09/29/building-your-own-mmdb-database-for-fun-and-profit/
* https://github.com/maxmind/MaxMind-DB-Writer-perl
* https://maxmind.github.io/MaxMind-DB/