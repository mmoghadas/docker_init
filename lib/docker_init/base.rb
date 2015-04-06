require 'rake'
require 'yaml'
require 'hashie'
require 'erubis'
require 'socket'
require 'timeout'
require 'colorize'
require 'ostruct'

require 'docker_init'

module DockerInit
  class Base

    attr_reader :home, :name, :dir, :port

    def setup(home, name)
      @home = home
      @name = name
      @dir = "#{home}/#{name}"
      @port = get_open_port

      create_directories(dir)
      write_vagrantfile
      run("cd #{dir}; vagrant up")
      display_info
    end

    def create_directories(dir)
      raise("Directory #{dir} exists! Please use another name") if directory_exists? dir
      FileUtils.mkdir_p(dir)
    end

    def write_vagrantfile
      File.open(dir+'/Vagrantfile', 'w') do |f|
        f << template(File.join(DockerInit.data_dir, 'templates/Vagrantfile.erb'))
      end
    end

    def directory_exists?(dir)
      test ?d, dir
    end

    def template(erb)
      Erubis::Eruby.new(File.read(File.expand_path(erb, __FILE__))).evaluate(data)
    end

    # Run a command
    def run(cmd)
      (system "#{cmd}").tap do|output|
        raise "Command #{cmd} failed: #{output}" unless $?.exitstatus == 0
      end
    end

    def get_open_port
      socket = Socket.new(:INET, :STREAM, 0)
      socket.bind(Addrinfo.tcp("127.0.0.1", 0))
      port = socket.local_address.ip_port
      socket.close
      port
    end

    def display_info
      puts ("export the following to connect to your new docker:").upcase
      puts ("export DOCKER_HOST=tcp://localhost:#{port}").green
    end

    def data
      OpenStruct.new(
        name: name,
        port: port
      )
    end

  end
end

class Hash
  include Hashie::Extensions::MethodAccess
  include Hashie::Extensions::SymbolizeKeys
end
