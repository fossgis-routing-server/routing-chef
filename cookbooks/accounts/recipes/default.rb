#
# Cookbook Name::accounts
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

# System user setup

node[:accounts][:system].each do |name,data|

    group name.to_s do
        action :create
        system true
        members data[:members] if data[:members]
    end

    user name.to_s do
      action :create
      comment data[:comment] if data[:comment]
      home data[:home] || "/false"
      shell data[:shell] || "/usr/sbin/nologin"
      gid name.to_s
      system true
    end

    # make sure we create a completely empty directory
    if data[:home]
        directory data[:home] do
            owner name.to_s
            group name.to_s
            action :create
        end
    end
end

# Administrator setup
# Note that the accounts must exist.

group "sudo" do
    action :manage
    members node[:accounts][:admins]
end

group "adm" do
    action :modify
    members node[:accounts][:admins]
end

