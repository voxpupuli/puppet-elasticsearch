desc "Verify puppet templates"
task :template do

  exclude_paths = [
    "pkg/**/*",
    "vendor/**/*",
    "spec/**/*",
  ]

  files = FileList["**/*.erb"]
  files.reject! { |f| File.directory?(f) }
  files = files.exclude(exclude_paths)

  files.each do |erb_file|
    result = `erb -P -x -T '-' #{erb_file} | ruby -c`
    puts "Verifying #{erb_file}.... #{result}"

  end

end
