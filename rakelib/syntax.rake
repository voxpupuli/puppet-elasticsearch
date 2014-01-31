desc "Check puppet module syntax."
task :syntax do
  begin
    require 'puppet/face'
  rescue LoadError
    fail 'Cannot load puppet/face, are you sure you have Puppet 2.7?'
  end

  exclude_paths = [
  "pkg/**/*",
  "vendor/**/*",
  "spec/**/*",
  ]
  puts "Checking puppet module syntax..."

  success = true

  files = FileList["**/*.pp"]
  files.reject! { |f| File.directory?(f) }
  files = files.exclude(exclude_paths)

  files.each do |manifest|
    puts "Evaluating syntax for #{manifest}"
    begin
      Puppet::Face[:parser, '0.0.1'].validate(manifest) 
    rescue Puppet::Error => error
      puts error.message
      success = false
    end
  end

  abort "Checking puppet module syntax FAILED" if success.is_a?(FalseClass)
end
