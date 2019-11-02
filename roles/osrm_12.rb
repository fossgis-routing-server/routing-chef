name "osrm"
description "Role for OpenSourceRoutingMachine on retiring routing1 and routing2"

polyeu = "[[-1.09898437500, 90], [-12.52476562500, 71.10265660445], [-35.02476562500, 62.06289796703], [-46.80210937500, 17.05712070850], [-30.45445312500, -3.07434401590], [0.83460937500, -90], [180, -90], [180, 90], [-1.09898437500, 90]]"
polyam = "[[-1.09898437500,90],[-12.52476562500,71.10265660445],[-35.02476562500,62.06289796703],[-46.80210937500,17.05712070850],[-30.45445312500,-3.07434401590],[0.83460937500,-90],[-180,-90],[-180,90],[-1.09898437500,90]]"

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
    },
    :profiles => {
        "car" =>  ["careu",  "caram"],
        "bike" => ["bikeeu", "bikeam"],
        "foot" => ["footeu", "footam"]
    },
    :profileareas => {
        "careu" => {
                :host => "routing2",
                :poly => polyeu,
                :port => 3330
        },
        "caram" => {
                :host => "routing1",
                :poly => polyam,
                :port => 3331
        },
        "bikeeu" => {
                :host => "routing2",
                :poly => polyeu,
                :port => 3332
        },
        "bikeam" => {
                :host => "routing1",
                :poly => polyam,
                :port => 3333
        },
        "footeu" => {
                :host => "routing2",
                :poly => polyeu,
                :port => 3334
        },
        "footam" => {
                :host => "routing2",
                :poly => polyam,
                :port => 3335
        }
    }
)

run_list(
    "recipe[osrm]"
)

