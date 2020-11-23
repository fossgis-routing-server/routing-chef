OSRM routing server using OpenStreetMap data
======================

This server provides route instructions for a few select modes
of transportation.  It uses free and open data from the
collaborative [OpenStreetMap](https://openstreetmap.org) project
with the routing engine [OSRM](http://project-osrm.org/). The servers
are sponsored by [FOSSGIS](https://www.fossgis.de/).

## Contact

Map related questions are best asked at one of the places
mentioned on [openstreetmap.org/help](https://www.openstreetmap.org/help)

For questions about the routing engine software, OSRM, there is the
mailinglist [osrm-talk](https://lists.openstreetmap.org/listinfo/osrm-talk)

You can contact the system administrators at
[fossgis-routing-server@openstreetmap.de](mailto:fossgis-routing-server@openstreetmap.de)

## Privacy
Your request for a route is sent to our server (because the route is
calculated on the server and only displayed in your browser) and is saved
in the server log file. Please see
[Datenschutzerklärung](https://www.fossgis.de/datenschutzerklärung)
for more information on privacy.

## Usage policy
The full usage policy can be found
[on the fossgis website](https://www.fossgis.de/arbeitsgruppen/osm-server/nutzungsbedingungen/)
in German. Here a short excerpt:

* Display the required attribution and display a link to
["fix the map"](https://www.openstreetmap.org/fixthemap).
* Use a valid user agent and, if applicable, a correct referrer.
* One request per second max.
* No scraping, no heavy usage.

## General setup
There are three servers, one is continuously preparing the routing graph
and fetching the most recent OpenStreetMap data, while the two others are
serving routes from the precalculated graphs.

The three servers have 6 cores and 256GB ram each.

## Used software

Most software running on the servers is available as open source.
Debian 10 is used as operating system.

### [OSRM backend](https://github.com/fossgis-routing-server/osrm-backend)

Currently running v5.23.0

* hints are disabled, because they can crash the server

### [OSRM frontend](https://github.com/fossgis-routing-server/osrm-frontend)

* The frontend was hacked to include a profile switch (car, bike and foot)
* Includes the configuration of background layers and routing engine URLs

### [routing profiles](https://github.com/fossgis-routing-server/cbf-routing-profiles)

The routing profiles used for these servers. They differ
from the profiles included with the OSRM-backend sources,
especially the bike and foot profiles.

* car: worldwide
* bike: worldwide
* foot: worldwide

### [Overview of routing data updates](http://map.project-osrm.org/timestamps/)

The routing data are updated daily. There may be delays in the internal processing and creation of the routing diagram.

### [Server configuration](https://github.com/fossgis-routing-server/routing-chef/)

The server configuration is available as [chef](https://www.chef.sh/) scripts in a github repository, too. 
There you can also find auxiliary files like this [page](https://github.com/fossgis-routing-server/routing-chef/blob/master/cookbooks/osrm/files/default/about.md).
