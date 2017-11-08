name "letsencrypt"
description "role for certificate via letsencrypt"

run_list(
    "recipe[letsencrypt]"
)

