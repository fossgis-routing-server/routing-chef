#
# Cookbook Name:: osrm
# Recipe:: default
#
# Copyright 2020  FOSSGIS
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

package "augeas-tools"
package "unattended-upgrades"
package "apt-listchanges"

execute "prohibit_ssh_password_login" do
  user    "root"
  command "augtool set /files/etc/ssh/sshd_config/PasswordAuthentication no"
end

execute "enable_unattended_upgrades" do
  user "root"
  command "echo unattended-upgrades unattended-upgrades/enable_auto_updates boolean true | debconf-set-selections
           dpkg-reconfigure -f noninteractive unattended-upgrades"
end
