name "osrm"
description "Role for running OpenSourceRoutingMachine"

default_attributes(
    :accounts => {
        :system => {
            :osrm => { :comment => "OSRM routing account",
                       :home => "/srv/osrm",
            }
        }
    },
    :munin => {
        :plugin => {
            :list =>
            [
                ["munin_stats",""],
                ["smart_","sda"],
                ["smart_","sdb"],
                ["apache_accesses",""],
                ["apache_processes",""],
                ["apache_volume",""],
            ]
        }
    }
)

run_list(
    "recipe[osrm]"
)

