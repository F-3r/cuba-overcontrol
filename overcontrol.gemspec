lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "cuba-overcontrol"
  spec.version       = '1.0.0'
  spec.authors       = ['Fernando Martinez']
  spec.email         = ['fernando@templ.co']
  spec.summary       = %q{Thin controller layer for Cuba}
  spec.description   = %q{Thin controller layer for Cuba}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'tilt'

  spec.add_runtime_dependency 'cuba'
end
