#
# Cookbook Name:: letsencrypt
# Recipe:: default
#
# Copyright 2016, Swiss OpenStreetMap Assosication
#           2017  Michael Spreng
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

package "letsencrypt"

if node[:osrm][:preprocess]
    domains = "-d  #{node[:myhostname]}.#{node[:rooturl]}"
else
    domains = "-d  #{node[:myhostname]}.#{node[:rooturl]} -d #{node[:osrm][:frontenddomain]}"
end

execute "get_certificate" do
    user   "root"
    group  "root"
    not_if { File.directory?("/etc/letsencrypt") }
    command "letsencrypt --non-interactive --agree-tos "\
            "-m cert-rounting.openstreetmap.de@m.spreng.ch "\
            "#{domains} --webroot --webroot-path #{node[:accounts][:system][:osrm][:home]}"\
            "/osrm-frontend/ certonly"
end

template "/etc/cron.d/certbot-renew" do
    source "certbot-cron.erb"
    user   "root"
    group  "root"
    mode   "0644"
end
