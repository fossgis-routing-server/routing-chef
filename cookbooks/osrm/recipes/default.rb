#
# Cookbook Name:: osrm
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

include_recipe "apache"
include_recipe "apache::ssl"

basedir = node[:accounts][:system][:osrm][:home]
osmdata = "#{basedir}/osmdata/osmdata.pbf"
myhost = node[:myhostname]
profiles = node[:profiles]
profileareas = node[:profileareas]
thishostprofiles = []
hostmapping = {}

for profile in profileareas.keys do
  if profileareas[profile][:host] == myhost
    thishostprofiles.push(profile)
  end
  hostlist = hostmapping[profileareas[profile][:host]] || []
  hostlist.push(profile)
  hostmapping[profileareas[profile][:host]] = hostlist
end


frontenddomain = ""
website_dir = "/var/www/routing"

# Building OSRM (only on installation)
package "git"
package "build-essential"
package "cmake" 
package "pkg-config"
package "libprotoc-dev"
package "protobuf-compiler"
package "libprotobuf-dev"
package "libosmpbf-dev"
package "libpng-dev"
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
package "nodejs"
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

# about page
package "python-markdown"

# request-by-coordinate dispatch script
package "libapache2-mod-wsgi-py3"
package "python3-cherrypy3"

# osmium tool for planet update and transform
package "pyosmium"
package "osmium-tool"

directory "#{basedir}" do
    user  "osrm"
    group "osrm"
end

directory "#{basedir}/data" do
  owner "osrm"
  group "osrm"
end

directory "#{basedir}/extract" do
  owner "root"
  group "root"
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
          "&& cmake -DCMAKE_BUILD_TYPE=Release -DENABLE_STXXL=ON .. && make -j 6"
  user "osrm"
end

git "#{basedir}/osrm-backend" do
  repository "git://github.com/fossgis-routing-server/osrm-backend.git"
  revision "2f0f085ea301289824d197f4fa7628e26eb00043"
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

directory website_dir do
    user  "osrm"
    group "osrm"
end

if node[:osrm][:runfrontend]

  frontenddomain=node[:osrm][:frontenddomain]

  execute "compile_osrm_frontend" do
    action :nothing
    cwd "#{basedir}/osrm-frontend"
    environment 'HOME' => "#{basedir}/osrm-frontend"
    command "npm install && npm run build && "\
        "cp -r css fonts images bundle.js bundle.js.map "\
        "bundle.raw.js index.html debug #{website_dir}"
    user "osrm"
  end

  git "#{basedir}/osrm-frontend" do
    repository "git://github.com/fossgis-routing-server/osrm-frontend.git"
    revision "dc07ddb6088a1fcb26fdbf01b5cad3611d91f5df"
    user "osrm"
    group "osrm"
    notifies :run, "execute[compile_osrm_frontend]", :immediately
  end

  directory "#{basedir}/about/" do
      user  "osrm"
      group "osrm"
  end

  # about page

  git "#{basedir}/about/splendor/" do
    repository "https://github.com/markdowncss/splendor.git"
    revision "40db29539e4e8c733dec7f941833dcc21ed60504"
    user "osrm"
    notifies :run, "execute[create_about_page]"
  end


  cookbook_file "#{basedir}/about/about.md" do
    source "about.md"
    user "osrm"
    notifies :run, "execute[create_about_page]"
  end

  execute "create_about_page" do
    action :nothing
    cwd "#{basedir}/about"
    command "cp splendor/css/splendor.css #{website_dir}/splendor.css && "\
        "echo '<!DOCTYPE html><html lang=\"en\"><head><meta charset=\"utf-8\">"\
        "<title>About #{frontenddomain}</title>"\
        "<link rel=\"stylesheet\" href=\"splendor.css\">"\
        "</head><body>' > #{website_dir}/about.html && "\
        "markdown_py about.md -o html5 >> #{website_dir}/about.html && "\
        "echo '</body></html>' >> #{website_dir}/about.html"
    user "osrm"
  end
end

git "#{basedir}/cbf-routing-profiles" do
  repository "git://github.com/fossgis-routing-server/cbf-routing-profiles.git"
  revision "5c0ed5c5c4540dd50752053674fffa094f0c23a4"
  user "osrm"
  group "osrm"
end

for profilemain in profiles.keys
  for profile in profiles[profilemain]
    if profile != profilemain
      link "#{basedir}/cbf-routing-profiles/#{profile}.lua" do
        to "#{basedir}/cbf-routing-profiles/#{profilemain}.lua"
        owner 'osrm'
      end
    end
  end
end


# routing graph processing
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

  template "#{basedir}/scripts/build-graphs.sh" do
    source "build-graphs.erb"
    mode 0755
    variables :basedir => basedir, :osmdata => osmdata,\
	    :profilelist => profileareas.keys.join(" "),\
	    :thishostprofiles => thishostprofiles ,\
            :hostmapping => hostmapping, :myhost => myhost
  end

  template "/etc/sudoers.d/osrm" do
    source "sudoers-osrm.erb"
    mode 0440
    user "root"
    group "root"
    variables :modes => thishostprofiles
  end

  template "/etc/systemd/system/build-graphs.service" do
    source "systemd-build-graphs.erb"
    variables :basedir => basedir
  end
else

  template "#{basedir}/scripts/new-graphs.sh" do
    source "new-graphs.erb"
    mode 0755
    variables :basedir => basedir, :profiles => thishostprofiles.join(" ")
  end

  template "/etc/cron.d/new-graphs" do
      source "cron-new-graphs.erb"
      user   "root"
      group  "root"
      mode   "0644"
      variables :basedir => basedir
  end

end

for profile in profileareas.keys do
  template "#{basedir}/cbf-routing-profiles/profile-#{profile}.conf" do
    source "profiles.erb"
    user   "osrm"
    group  "osrm"
    variables :basedir => basedir, :osmdata => "#{basedir}/osmdata/#{profile}.pbf", \
        :profile => profile, :port => profileareas[profile][:port]
  end

  if profileareas[profile][:poly]
    template "#{basedir}/extract/#{profile}.geojson" do
      source "poly.geojson.erb"
      user "root"
      variables :polygon => profileareas[profile][:poly]
    end
  end
end

for profile in thishostprofiles do
  template "/etc/systemd/system/osrm-routed-#{profile}.service" do
    source "systemd-osrm-routed.erb"
    variables :basedir => basedir, :profile => profile, :port => profileareas[profile][:port]
  end
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

cookbook_file "/etc/munin/plugin-conf.d/routing" do
  source "munin_plugin-conf_routing"
end

if node[:osrm][:runfrontend]
  template "/etc/munin/plugins/routing_count" do
    source "munin_count.erb"
    mode 0755
    variables :profiles => profiles.keys
  end

  template "/etc/munin/plugins/routing_latency" do
    source "munin_latency.py.erb"
    mode 0755
    variables :profiles => profiles.keys
  end
end

if thishostprofiles.length > 0
  template "/etc/munin/plugins/routing_size" do
    source "munin_size.erb"
    mode 0755
    variables :thishostprofiles => thishostprofiles
  end
elsif node[:osrm][:preprocess]
  template "/etc/munin/plugins/routing_size" do
    source "munin_size.erb"
    mode 0755
    variables :thishostprofiles => profileareas.keys
  end
end

# Apache configuration

apache_module "proxy"
apache_module "proxy_http"
apache_module "rewrite"

apache_site "#{node[:myhostname]}.#{node[:rooturl]}" do
    template "apache.erb"
    directory website_dir
    variables :domain => "#{node[:myhostname]}.#{node[:rooturl]}", :port => 80,\
            :munin => true, :munindir => "/var/cache/munin/www", \
	    :rbs => false
end

apache_site "#{node[:myhostname]}.#{node[:rooturl]}-ssl" do
    template "apache.erb"
    directory website_dir
    variables :domain => "#{node[:myhostname]}.#{node[:rooturl]}", :port => 443,\
            :munin => true, :munindir => "/var/cache/munin/www", \
	    :rbs => false
end

if node[:osrm][:runfrontend]
  apache_site "#{frontenddomain}" do
      template "apache.erb"
      directory website_dir
      variables :domain => frontenddomain, :port => 80,\
              :munin => false ,\
              :rbs => true, :rbcdir => "#{basedir}/request-by-coordinate",\
              :profiles => profiles.keys
  end

  apache_site "#{frontenddomain}-ssl" do
      template "apache.erb"
      directory website_dir
      variables :domain => frontenddomain, :port => 443,\
              :munin => false, \
              :rbs => true, :rbcdir => "#{basedir}/request-by-coordinate",\
              :profiles => profiles.keys
  end

  apache_site "map.project-osrm.org" do
      template "apache.erb"
      directory website_dir
      variables :domain => "map.project-osrm.org", :port => 80,\
              :munin => false, \
              :rbs => false
  end

  apache_site "map.project-osrm.org-ssl" do
      template "apache.erb"
      directory website_dir
      variables :domain => "map.project-osrm.org", :port => 443,\
              :munin => false, \
              :rbs => false
  end
end

# script for dispatching routing requests by region
git "#{basedir}/request-by-coordinate" do
  repository "git://github.com/fossgis-routing-server/request-by-coordinate.git"
  revision "8bf7783311c8f1efc7b0185aa57b41cfd90ecd37"
  user "osrm"
  group "osrm"
end

template "#{basedir}/request-by-coordinate/settings.cfg" do
  source "request-by-coordinate.cfg.erb"
  user   "osrm"
  group  "osrm"
  mode 0644
  variables :basedir => basedir, :modes => profiles.keys,\
            :moderegs =>profiles, :modeprops => profileareas
end

