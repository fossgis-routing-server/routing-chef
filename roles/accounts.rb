name "accounts"
description "defines admin accounts"

default_attributes(
    :accounts => {
        :admins => [ "spreng", "robert", "lonvia" ]
    }
)
run_list(
    "recipe[accounts]"
)


