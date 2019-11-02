name "routing1"
description "Master role applied to routing1"

myhostname = "routing1"

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
            :certificate => "letsencrypt/live/routing1.openstreetmap.de"
        }
    },
    :osmdataurl => "http://planet.osm.org/pbf/planet-latest.osm.pbf",
    :osrm => {
        :preprocess => true,
    }
)

run_list(
    "recipe[accounts]",
    "role[osrm_12]",
    "role[letsencrypt]",
    "role[export]",
)
