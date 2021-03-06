name "routing3"
description "Master role applied to routing3"

myhostname = "routing3"

default_attributes(
    :myhostname => myhostname,
    :rooturl => "openstreetmap.de",
    :apache => {
        :ssl => {
            :certificate => "letsencrypt/live/routing3.openstreetmap.de"
        }
    },
    :osrm => {
        :preprocess => false,
        :runfrontend => true,
        :frontenddomain => "routing.openstreetmap.de"
    }
)

run_list(
    "role[accounts]",
    "recipe[system]",
    "role[letsencrypt]",
    "role[osrm]",
)
