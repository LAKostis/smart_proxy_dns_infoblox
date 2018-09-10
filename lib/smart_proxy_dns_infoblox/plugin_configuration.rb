module Proxy::Dns::Infoblox
  class PluginConfiguration
    def load_classes
      require 'infoblox'
      require 'dns_common/dns_common'
      require 'smart_proxy_dns_infoblox/dns_infoblox_main'
    end

    def load_dependency_injection_wirings(container_instance, settings)
      conn_host = settings[:infoblox_host].nil? ? settings[:dns_server] : settings[:infoblox_host]
      container_instance.dependency :connection,
                                    (lambda do
                                      ::Infoblox.wapi_version = '2.0'
                                      ::Infoblox::Connection.new(:username => settings[:dns_username],
                                                                 :password => settings[:dns_password],
                                                                 :host => conn_host,
                                                                 :ssl_opts => {:verify => false})
                                    end)
      container_instance.dependency :dns_provider,
                                    lambda {::Proxy::Dns::Infoblox::Record.new(
                                        settings[:dns_server],
                                        container_instance.get_dependency(:connection),
                                        settings[:dns_ttl],
                                        settings[:dns_view]) }
    end
  end
end
