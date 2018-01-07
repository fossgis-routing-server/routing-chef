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
[fossgis-routing-server@spreng.ch](mailto:fossgis-routing-server@spreng.ch)

## General setup
There are two servers, one is continuously preparing the routing graph
and fetching the most recent OpenStreetMap data, while  the other is
serving routes from the precalculated graphs.

## Used software

Most software running on the servers is available as open source.
Ubuntu 16.04 is used as operating system.

### [OSRM backend](https://github.com/fossgis-routing-server/osrm-backend)

Currently running v5.14.1

* hints are disabled, because they can crash the server

### [OSRM frontend](https://github.com/fossgis-routing-server/osrm-frontend)

* The frontend was hacked to include a profile switch (car, bike and foot)
* Includes the configuration of background layers and routing engine URLs

### [rounting profiles](https://github.com/fossgis-routing-server/cbf-routing-profiles)

The routing profiles used for these servers. They differ
from the profiles included with the OSRM-backend sources,
especially the bike and foot profiles.

