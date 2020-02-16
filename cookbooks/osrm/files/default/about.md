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

## General setup
There are three servers, one is continuously preparing the routing graph
and fetching the most recent OpenStreetMap data, while the two others are
serving routes from the precalculated graphs.

The three servers have 6 cores and 256GB ram each.

## Used software

Most software running on the servers is available as open source.
Ubuntu 18.04 is used as operating system.

### [OSRM backend](https://github.com/fossgis-routing-server/osrm-backend)

Currently running v5.18.0

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

### [Server configuration](https://github.com/fossgis-routing-server/routing-chef/)

The server configuration is available as [chef](https://www.chef.sh/) scripts in a github repository, too. 
There you can also find auxiliary files like this [page](https://github.com/fossgis-routing-server/routing-chef/blob/master/cookbooks/osrm/files/default/about.md).
