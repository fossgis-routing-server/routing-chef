name "routing5"
description "Master role applied to routing5"

myhostname = "routing5"

default_attributes(
    :myhostname => myhostname,
    :rooturl => "openstreetmap.de",
    :accounts => {
        :admins => [ "spreng" ]
    },
    :apt => {
        :release => "xenial",
        :sources => [ ]
    },
    :apache => {
        :ssl => {
            :certificate => "letsencrypt/live/routing5.openstreetmap.de"
        }
    },
    :osmdataurl => "http://planet.osm.org/pbf/planet-latest.osm.pbf",
    :osrm => {
        :preprocess => true,
    }
)

run_list(
    "recipe[accounts]",
    "role[letsencrypt]",
    "role[osrm]",
)
