# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = 'docker_init'
  spec.version       = File.read 'VERSION'
  spec.authors       = %w'mmoghadas'
  spec.email         = %w'mike.moghadas@gmail.com'
  spec.description   = %q{docker_init: image building tool}
  spec.summary       = %q{docker_init: image building tool}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w'lib'

  spec.add_dependency 'rake', '10.0.3'
  spec.add_dependency 'clamp'
  spec.add_dependency 'hashie'
  spec.add_dependency 'erubis'
  spec.add_dependency 'net-ssh'
  spec.add_dependency 'net-scp'
  spec.add_dependency 'colorize'
end
