require 'clamp'
require 'docker_init/base'

module DockerInit
  class Cli < Clamp::Command

    option ["-d", "--vagranthome"], "VAGRANTHOME", "required: vagrant home", :required => true
    option ["-n", "--name"], "VAGRANTNAME", "required: vagrant name", :required => true
    option ["-h", "--hostname"], "HOSTNAME", "required if tls enabled"
    option "--tls", :flag, "USE TLS"

    def execute
      DockerInit::Base.new.setup(vagranthome, name, {tls: tls?, hostname: hostname})
    end
  end

end
