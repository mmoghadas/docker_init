require 'clamp'
require 'docker_init/base'

module DockerInit
  class Cli < Clamp::Command

    option ["-d", "--home"], "VAGRANTHOME", "required: vagranthome", :required => true
    option ["-n", "--name"], "VAGRANTNAME", "required: vagrantname", :required => true

    def execute
      DockerInit::Base.new.setup(home, name)
    end
  end

end
