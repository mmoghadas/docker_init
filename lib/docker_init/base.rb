require 'erubis'
require 'socket'
require 'colorize'
require 'ostruct'

require 'docker_init'

module DockerInit
  class Base

    attr_reader :vagranthome, :name, :nodes, :dir, :forwarded_port, :tls, :hostname, :store, :docker_hosts

    DOCKER_INIT_HOME = "#{ENV['HOME']}/.docker_init"

    def setup(vagranthome, name, nodes, options={})
      @vagranthome = vagranthome
      @name = name
      @nodes = nodes.to_i
      @dir = "#{vagranthome}/#{name}/"
      @tls = options[:tls]
      @hostname = options[:hostname]
      @store = "#{DOCKER_INIT_HOME}/#{name}/"

      master = {name: name, forwarded_port: get_open_port}
      if nodes == 0
        @docker_hosts = [master]
      else
        @docker_hosts = cluster_config(master)
      end

      create_directories(dir)
      vagrantfile
      provision_file
      configure_tls if tls
      run("cd #{dir}; vagrant up")
      nodes == 0 ? display_info(master[:forwarded_port]) : setup_cluster
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

    def display_info(port)
      if tls
        puts ("export DOCKER_CERT_PATH=#{store}").green
        puts ("docker --tlsverify -H tcp://#{hostname}:#{port} <docker_command_here>").green
      else
        puts ("export DOCKER_HOST=tcp://localhost:#{port}").green
      end
    end

    def cluster_config(master)
      master[:swarm_port]=get_open_port
      hosts = [master]
      i = 0
      until i == @nodes
        hosts << {name: "#{name}_node_#{i+1}", forwarded_port: get_open_port}
        i +=1
      end
      hosts
    end

    def setup_cluster
      swarm_nodes = docker_hosts.clone
      swarm = swarm_nodes.shift
      docker_hosts.each{|c|c[:ip]=get_host_only_ip(c[:name])}

      cluster_id = `docker -H localhost:#{swarm[:forwarded_port]} run --rm swarm create`

      puts "cluster_id is: #{cluster_id}"

      threads = []

      swarm_nodes.each do |n|
        threads << Thread.new(n) do |t|
          `docker -H localhost:#{n[:forwarded_port]} run -d swarm join --addr=#{n[:ip]}:2376 token://#{cluster_id}`
        end
      end

      threads.each{|t|t.join}

      `docker -H tcp://localhost:#{swarm[:forwarded_port]} run -d -p 2375:2375 swarm manage token://#{cluster_id}`

      puts "docker -H tcp://127.0.0.1:#{swarm[:forwarded_port]} run --rm swarm list token://#{cluster_id}"
      puts "docker -H tcp://127.0.0.1:#{swarm[:swarm_port]} <docker_command_here>"
    end

    def template(erb)
      Erubis::Eruby.new(File.read(File.expand_path(erb, __FILE__))).evaluate(data)
    end

    # execute commands
    def run(cmd)
      (system "#{cmd}").tap do|output|
        raise "Command #{cmd} failed: #{output}" unless $?.exitstatus == 0
      end
    end

    # find an unused port on host system
    def get_open_port
      socket = Socket.new(:INET, :STREAM, 0)
      socket.bind(Addrinfo.tcp("127.0.0.1", 0))
      port = socket.local_address.ip_port
      socket.close
      port
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

    def get_host_only_ip(name)
      `ssh vagrant@localhost -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=quiet -p #{get_ssh_port(name)} -i #{dir}/.vagrant/machines/#{name}/virtualbox/private_key hostname -I | awk '{ print $2 }'`.strip
    end

    def get_ssh_port(name)
      `cd #{dir}; vagrant ssh-config #{name} | grep Port | awk '{ print $2 }'`.strip
    end

    def data
      OpenStruct.new(
        name: name,
        forwarded_port: forwarded_port,
        docker_options: docker_options,
        tls: tls,
        hostname: hostname,
        client_hostname: client_hostname,
        store: store,
        docker_hosts: docker_hosts
      )
    end

  end
end
