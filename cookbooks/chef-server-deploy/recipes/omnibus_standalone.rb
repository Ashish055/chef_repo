#
# Cookbook:: chef-server-deploy
# Recipe:: omnibus_standalone
#
# Copyright:: 2017, Chef Software Inc Engineering, All Rights Reserved.

include_recipe 'chefops-dcc::chef-server'

omnibus_service 'chef-server' do
  action :nothing
end

#########################################################################
# Expose the Supermarket OC ID creds
#########################################################################
# This is a hack to allow the Supermarket instance to get the oc-id app details
# via a HTTP call.

omnibus_service 'chef-server/nginx' do
  action :nothing
end

# Grant the opscode user access to the json file
file '/etc/opscode/oc-id-applications/supermarket.json' do
  owner 'opscode'
  action :touch
end

file '/var/opt/opscode/nginx/etc/addon.d/99-supermarket-credentials_external.conf' do
  content <<-EOF
location /supermarket-credentials {
  types { }
  default_type application/json;
  alias /etc/opscode/oc-id-applications/supermarket.json;
}
EOF
  notifies :restart, 'omnibus_service[chef-server/nginx]'
end

#########################################################################
# Create default admin users and organizations
#########################################################################

# This ensures the admin user's password is set to a known value across all
# environments. The password can be found in the `chef-cd Chef Server Admin User`
# record in LastPass.
chef_user 'admin' do
  first_name 'Chef-CD'
  last_name 'Admin'
  email 'eng-services-ops#chef-cd@chef.io'
  password citadel['chef_server_admin_password'].chomp
  serveradmin true
end

chef_user 'delivery' do
  first_name 'Delivery'
  last_name 'Admin'
  email 'eng-services-ops#delivery@chef.io'
  password citadel['automate_admin_password'].chomp
  serveradmin true
end

file '/etc/opscode/users/delivery-2.pem.pub' do
  content OpenSSL::PKey::RSA.new(citadel['delivery.pem']).public_key.to_s
  user 'root'
  group 'root'
  mode '0644'
end

# TODO: Do this in resource
execute 'add-delivery-user-key' do
  command lazy { 'chef-server-ctl add-user-key delivery --public-key-path /etc/opscode/users/delivery-2.pem.pub --key-name delivery-2' }
  not_if 'chef-server-ctl list-user-keys delivery | grep delivery-2'
end

node['automate-deploy']['chef_server_orgs'].each do |org_name|
  chef_org org_name do
    admins %w(
      admin
      delivery
    )
  end
end
