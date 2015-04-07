require 'erubis'
require 'socket'
require 'colorize'
require 'ostruct'

require 'docker_init'

module DockerInit
  class Base

    attr_reader :vagranthome, :name, :dir, :port, :tls, :hostname, :store

    DOCKER_INIT_HOME = "#{ENV['HOME']}/.docker_init"

    def setup(vagranthome, name, options={})
      @vagranthome = vagranthome
      @name = name
      @dir = "#{vagranthome}/#{name}/"
      @port = get_open_port
      @tls = options[:tls]
      @hostname = options[:hostname]
      @store = "#{DOCKER_INIT_HOME}/#{name}/"

      puts run('hostname')

      create_directories(dir)
      vagrantfile
      provision_file
      configure_tls if tls
      run("cd #{dir}; vagrant up")
      display_info
    end

    def create_directories(dir)
      raise("Directory #{dir} exists! Please use another name") if directory_exists? dir
      FileUtils.mkdir_p(dir)
      FileUtils.mkdir_p(store)
    end

    def vagrantfile
      File.open(dir+'Vagrantfile', 'w') do |f|
        f << template(File.join(DockerInit.data_dir, 'templates/Vagrantfile.erb'))
      end
    end

    def provision_file
      File.open(store+'provision.sh', 'w') do |f|
        f << template(File.join(DockerInit.data_dir, 'templates/provision.sh.erb'))
      end
    end

    def configure_tls
      ca_reqeust_config
      tls_sh
      run("sh #{store}/tls.sh")
    end

    def ca_reqeust_config
      File.open(store+'ca.cnf', 'w') do |f|
        f << template(File.join(DockerInit.data_dir, 'templates/ca_req.erb'))
      end
    end

    def tls_sh
      File.open(store+'tls.sh', 'w') do |f|
        f << template(File.join(DockerInit.data_dir, 'templates/tls.sh.erb'))
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
      if tls
        puts ("export DOCKER_HOST=tcp://#{hostname}:#{port} DOCKER_TLS_VERIFY=1").green
      else
        puts ("export DOCKER_HOST=tcp://localhost:#{port}").green
      end
      puts ("export DOCKER_CERT_PATH=#{store}").green if tls
    end

    def docker_options
      if tls
        '--tlsverify --tlscacert=/etc/pki/tls/docker/ca.pem --tlscert=/etc/pki/tls/docker/server.pem --tlskey=/etc/pki/tls/docker/server-key.pem -H 0.0.0.0:2376 -H unix:///var/run/docker.sock'
      else
        '-H 0.0.0.0:2376 -H unix:///var/run/docker.sock'
      end
    end

    def client_hostname
      Socket.gethostname
    end

    def data
      OpenStruct.new(
        name: name,
        port: port,
        docker_options: docker_options,
        tls: tls,
        hostname: hostname,
        client_hostname: client_hostname,
        store: store
      )
    end

  end
end
