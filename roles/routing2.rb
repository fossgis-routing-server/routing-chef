name "routing1"
description "Master role applied to routing2"

myhostname = "routing2"

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
            :certificate => "letsencrypt/live/routing2.openstreetmap.de"
        }
    },
    :osrm => {
        :preprocess => false,
        :runfrontend => true,
        :frontenddomain => "routing.openstreetmap.de"
    }
)

run_list(
    "recipe[accounts]",
    "role[osrm_12]",
    "role[letsencrypt]",
)
