require 'clamp'
require 'docker_init/base'

module DockerInit
  class Cli < Clamp::Command

    option ["-d", "--vagranthome"], "VAGRANTHOME", "required: vagrant home", :required => true
    option ["-n", "--name"], "VAGRANTNAME", "required: vagrant name", :required => true
    option ["-c", "--nodes"], "NODES", "required: number of nodes", :default => 0

    def execute
      DockerInit::Base.new.setup(vagranthome, name, nodes)
    end
  end

end
