require 'json'
require 'pedant/rspec/common'

describe "running configs required by chef-server-ctl", :config do
  let (:complete_config) { JSON.parse(IO.read("/etc/opscode/chef-server-running.json")) }
  let (:config) { complete_config['private_chef'] }

  context "partybus upgrade framework" do
    it "postgresql/vip" do
      expect(config["postgresql"]["vip"].to_s).to_not eq('')
    end

    it "postgresql/port" do
      expect(config["postgresql"]["port"].to_i).to_not eq(0)
    end

    it "postgresql/db_superuser" do
      expect(config["postgresql"]["db_superuser"].to_s).to_not eq('')
    end
  end

  context "migration 20" do
    it "opscode-erchef/sql_user" do
      expect(config["opscode-erchef"]["sql_user"].to_s).to_not eq('')
    end

    it "postgresql/vip" do
      expect(config["postgresql"]["vip"].to_s).to_not eq('')
    end

    it "postgresql/port" do
      expect(config["postgresql"]["port"].to_i).to_not eq(0)
    end
  end

  context "migration 31" do
    it "rabbitmq/user" do
      expect(config["rabbitmq"]["user"].to_s).to_not eq('')
    end

    it "rabbitmq/actions_user" do
      expect(config["rabbitmq"]["actions_user"].to_s).to_not eq('')
    end

    it "rabbitmq/management_user" do
      expect(config["rabbitmq"]["management_user"].to_s).to_not eq('')
    end
  end

  context "password" do
    it "ldap/enabled" do
      expect(config["ldap"]["enabled"]).to be(true).or be(false).or be(nil)
    end
  end

  context "ha" do
    it "runit/sv_dir" do
      expect(complete_config["runit"]["sv_dir"].to_s).to_not eq("")
      expect(File.exist?(complete_config["runit"]["sv_dir"])).to be(true)
    end

    it "keepalived/enable" do
      expect(config['keepalived']['enable']).to be(true).or be(false)
    end

    it "keepalived/vrrp_instance_ipaddress" do
      expect(config['keepalived']['vrrp_instance_ipaddress'])
    end

    it "keepalived/vrrp_instance_ipaddress_dev" do
      expect(config['keepalived']['vrrp_instance_ipaddress_dev'])
    end

    it "keepalived/vrrp_instance_interface" do
      expect(config['keepalived']['vrrp_instance_interface'])
    end
  end

  context "reindex" do
    it "fips_enabled" do
      expect(config['fips_enabled']).to be(true).or be(false)
    end

    it "opscode-erchef/search_queue_mode" do
      expect(config["opscode-erchef"]["search_queue_mode"]).to eq("rabbitmq")
                                                                 .or eq("batch")
                                                                       .or eq("inline")
    end

    it "redis_lb/vip" do
      expect(config["redis_lb"]["vip"].to_s).to_not eq("")
    end

    it "redis_lb/port" do
      expect(config["redis_lb"]["vip"].to_i).to_not eq(0)
    end
  end
end
