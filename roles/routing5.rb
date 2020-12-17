name "routing5"
description "Master role applied to routing5"

myhostname = "routing5"

default_attributes(
    :myhostname => myhostname,
    :rooturl => "openstreetmap.de",
    :apache => {
        :ssl => {
            :certificate => "letsencrypt/live/routing5.openstreetmap.de"
        }
    },
    :osmdataurl => "http://planet.osm.org/pbf/planet-latest.osm.pbf",
    :osrm => {
        :preprocess => true,
        :runfrontend => false
    }
)

run_list(
    "role[accounts]",
    "recipe[system]",
    "role[letsencrypt]",
    "role[osrm]",
)
