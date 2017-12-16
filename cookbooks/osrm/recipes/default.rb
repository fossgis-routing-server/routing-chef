#
# Cookbook Name:: osrm
# Recipe:: default
#
# Copyright 2013, Swiss OpenStreetMap Assosication
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

include_recipe "apache"
include_recipe "apache::ssl"

basedir = node[:accounts][:system][:osrm][:home]
osmdata = "#{basedir}/osmdata/osmdata.pbf"
profiles = ["car", "bike", "foot"]
routed_port = 3331

# Building OSRM (only on installation)
package "git"
package "build-essential"
package "cmake" 
package "pkg-config"
package "libprotoc-dev"
package "protobuf-compiler"
package "libprotobuf-dev"
package "libosmpbf-dev"
package "libpng12-dev"
package "libbz2-dev"
package "libstxxl-dev"
package "libstxxl-doc"
package "libstxxl1v5"
package "libxml2-dev"
package "libzip-dev"
package "libboost-thread-dev"
package "libboost-system-dev"
package "libboost-regex-dev"
package "libboost-filesystem-dev"
package "libboost-program-options-dev"
package "libboost-iostreams-dev"
package "libboost-test-dev"
package "liblua5.2-dev"
package "libluabind-dev"
package "libtbb-dev"
package "libexpat-dev"
package "node-browserify-lite"
package "nodejs-legacy"
package "npm"
package "libboost-python-dev"
package "python3-dev"
package "python3-setuptools"

# munin
package "munin-node"
package "munin"
package "smartmontools"
package "libwww-perl"
package "libcgi-fast-perl"
package "libapache2-mod-fcgid"

directory "#{basedir}" do
    user  "osrm"
    group "osrm"
end

directory "#{basedir}/data" do
  owner "osrm"
  group "osrm"
end

directory "#{basedir}/scripts" do
  owner "root"
  group "root"
end

execute "compile_osrm" do
  action :nothing
  cwd "#{basedir}/osrm-backend"
  # use -DCMAKE_BUILD_TYPE=RelWithDebInfo for debugging 
  command "rm -rf build && mkdir -p build && cd build "\
          "&& cmake -DCMAKE_BUILD_TYPE=Release .. && make -j 6"
  user "osrm"
end

git "#{basedir}/osrm-backend" do
  repository "git://github.com/datendelphin/osrm-backend.git"
  revision "e4e5f0ac299c3a302b168344c1d932c7e0e56000"
  user "osrm"
  group "osrm"
  notifies :run, "execute[compile_osrm]", :immediately
end

template "#{basedir}/osrm-backend/build/.stxxl" do
  source "stxxl.erb"
  user   "osrm"
  group  "osrm"
  mode 0644
  variables :basedir => basedir
end

if !node[:osrm][:preprocess]
  execute "compile_osrm_frontend" do
    action :nothing
    cwd "#{basedir}/osrm-frontend"
    environment 'HOME' => "#{basedir}/osrm-frontend"
    command "npm install && npm run build"
    user "osrm"
  end

  git "#{basedir}/osrm-frontend" do
    repository "git://github.com/datendelphin/osrm-frontend.git"
    revision "757ad723695144b98d790ed2ffdc5418022d6f1e"
    user "osrm"
    group "osrm"
    notifies :run, "execute[compile_osrm_frontend]", :immediately
  end
end

git "#{basedir}/cbf-routing-profiles" do
  repository "git://github.com/datendelphin/cbf-routing-profiles.git"
  revision "709d1f9a41cd5d7f82569e8c9bb31daab7e74c89"
  user "osrm"
  group "osrm"
end

# planet
if node[:osrm][:preprocess]
  directory "#{basedir}/osmdata" do
      user  "osrm"
      group "osrm"
  end

  execute "get_data" do
    cwd "#{basedir}/osmdata"
    user "osrm"
    not_if { File.exists?(osmdata) }
    command "wget http://planet.osm.org/pbf/planet-latest.osm.pbf -nc -O #{osmdata}"
  end

  execute "compile_pyosmium" do
    action :nothing
    cwd "#{basedir}/pyosmium"
    command "python3 steup.py build"
    user "osrm"
  end

  git "#{basedir}/pyosmium" do
    repository "https://github.com/osmcode/pyosmium.git"
    revision "v2.13.0"
    user "osrm"
    group "osrm"
    notifies :run, "execute[compile_pyosmium]", :immediately
  end

  git "#{basedir}/libosmium" do
    repository "https://github.com/osmcode/libosmium.git"
    revision "v2.13.1"
    user "osrm"
    group "osrm"
  end

  template "#{basedir}/scripts/build-graphs.sh" do
    source "build-graphs.erb"
    mode 0755
    variables :basedir => basedir, :osmdata => osmdata, :profiles => profiles.join(" ")
  end

  template "/etc/systemd/system/build-graphs.service" do
    source "systemd-build-graphs.erb"
    variables :basedir => basedir
  end
else

  template "#{basedir}/scripts/new-graphs.sh" do
    source "new-graphs.erb"
    mode 0755
    variables :basedir => basedir, :profiles => profiles.join(" ")
  end

  template "/etc/cron.d/new-graphs" do
      source "cron-new-graphs.erb"
      user   "root"
      group  "root"
      mode   "0644"
      variables :basedir => basedir
  end

end




current_port = routed_port
for profile in profiles do
  template "#{basedir}/cbf-routing-profiles/profile-#{profile}.conf" do
    source "profiles.erb"
    user   "osrm"
    group  "osrm"
    variables :basedir => basedir, :osmdata => osmdata, :profile => profile, :port => current_port
  end

  template "/etc/systemd/system/osrm-routed-#{profile}.service" do
    source "systemd-osrm-routed.erb"
    variables :basedir => basedir, :profile => profile, :port => current_port
  end

  current_port = current_port + 1
end

directory "/var/log/osrm" do
  owner "osrm"
  group "osrm"
  mode 0755
end

directory "#{basedir}/build" do
  owner "osrm"
  if node[:osrm][:preprocess]
    group "osrm"
  else
    group "osrmdata"
  end
  mode 0775
end

# munin

service 'munin-node' do
action [:enable, :start]
end

node['munin']['plugin']['list'].each do |name, thing|
    link "/etc/munin/plugins/#{name}#{thing}" do
        to "/usr/share/munin/plugins/#{name}"
        owner 'root'
        group 'root'
        notifies :restart, 'service[munin-node]'
    end
end

# Apache configuration

apache_module "proxy"
apache_module "proxy_http"

apache_site "routing.openstreetmap.de" do
    template "apache.erb"
    directory "#{basedir}/osrm-frontend/"
    variables :domain => "#{node[:myhostname]}.#{node[:rooturl]}", :munindir => "/var/cache/munin/www", :port => 80
end

apache_site "routing.openstreetmap.de-ssl" do
    template "apache.erb"
    directory "#{basedir}/osrm-frontend/"
    variables :domain => "#{node[:myhostname]}.#{node[:rooturl]}", :munindir => "/var/cache/munin/www", :port => 443
end


