name "routing4"
description "Master role applied to routing4"

myhostname = "routing4"

default_attributes(
    :myhostname => myhostname,
    :rooturl => "openstreetmap.de",
    :accounts => {
        :admins => [ "spreng" ]
    },
    :apache => {
        :ssl => {
            :certificate => "letsencrypt/live/routing4.openstreetmap.de"
        }
    },
    :osrm => {
        :preprocess => false,
        :runfrontend => false
    }
)

run_list(
    "recipe[accounts]",
    "role[letsencrypt]",
    "role[osrm]",
)
