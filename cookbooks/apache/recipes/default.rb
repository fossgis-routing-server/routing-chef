#
# Cookbook Name:: 
# Recipe:: default
#
# Copyright 2013, Swiss OpenStreetMap Assosication
#           2018  Michael Spreng
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

package "apache2"

service "apache2" do
  action [ :enable, :start ]
  supports :status => true, :restart => true, :reload => true
end

# for ipmask
package "apache2-dev"
package "debhelper"
package "devscripts"
basedir="/srv/apache"

execute "install_mod_ipmask" do
  action :nothing        
  cwd "#{basedir}"
  command "dpkg -i libapache2-mod-log-ipmask_1.0.0_amd64.deb"
  user "root"
end

execute "build_mod_ipmask" do
  action :nothing        
  cwd "#{basedir}/mod-log-ipmask"
  command "debuild -us -uc -b"
  user "osrm"
  notifies :run, "execute[install_mod_ipmask]", :immediately
end

directory basedir do
    user  "osrm"
    group "osrm"
end

git "#{basedir}/mod-log-ipmask" do
  repository "git://github.com/aquenos/apache2-mod-log-ipmask"
  revision "c129d92b26af9d7b9eaefe4fc3a053ba01e4f580"
  user "osrm"
  group "osrm"
  notifies :run, "execute[build_mod_ipmask]", :immediately
end

