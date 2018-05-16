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
[Datenschutzerklärung](https://www.fossgis.de/datenschutzerklaerung)
for more information on privacy.

## General setup
There are two servers, one is continuously preparing the routing graph
and fetching the most recent OpenStreetMap data, while  the other is
serving routes from the precalculated graphs.

The two servers both have 6 cores and 256GB ram.

## Used software

Most software running on the servers is available as open source.
Ubuntu 16.04 is used as operating system.

### [OSRM backend](https://github.com/fossgis-routing-server/osrm-backend)

Currently running v5.14.1

* hints are disabled, because they can crash the server

### [OSRM frontend](https://github.com/fossgis-routing-server/osrm-frontend)

* The frontend was hacked to include a profile switch (car, bike and foot)
* Includes the configuration of background layers and routing engine URLs

### [routing profiles](https://github.com/fossgis-routing-server/cbf-routing-profiles)

The routing profiles used for these servers. They differ
from the profiles included with the OSRM-backend sources,
especially the bike and foot profiles.

* car: worldwide
* bike: only Europe and Asia
* foot: worldwide

The limitation of the bike profile is due to a lack of sufficient ram.
