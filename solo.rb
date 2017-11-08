root = Dir.pwd
file_cache_path root
cookbook_path root + '/cookbooks'
data_bag_path root + '/data_bags'
role_path root + '/roles'

# Verify all HTTPS connections (recommended)
ssl_verify_mode :verify_peer

