module DockerInit
  def self.data_dir
    File.join __dir__, '../data'
  end
end
