$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),"..","..",".."))

Puppet::Type.type(:elasticsearch_plugin).provide(:plugin) do
  desc "A provider for the resource type `elasticsearch_plugin`,
        which handles plugin installation"

  commands :plugin => '/usr/share/elasticsearch/bin/plugin'
  commands :es => '/usr/share/elasticsearch/bin/elasticsearch'

  def exists?
    es_version
    if !File.exists?(pluginfile)
      debug "Plugin file #{pluginfile} does not exist"
      return false
    elsif File.exists?(pluginfile) && readpluginfile != pluginfile_content
      debug "Got #{readpluginfile} Expected #{pluginfile_content}. Removing for reinstall"
      self.destroy
      return false
    else
      debug "Plugin exists"
      return true
    end
  end

  def pluginfile_content
    return @resource[:name] if is1x?

    if @resource[:name].split("/").count == 1 # Official plugin
      version = plugin_version(@resource[:name])
      return "#{@resource[:name]}/#{version}"
    else
      return @resource[:name]
    end
  end

  def pluginfile
    File.join(@resource[:plugin_dir], plugin_name(@resource[:name]), '.name')
  end

  def writepluginfile
    File.open(pluginfile, 'w') do |file|
      file.write pluginfile_content
    end
  end

  def readpluginfile
    f = File.open(pluginfile)
    f.readline
  end

  def install1x
    if !@resource[:url].nil?
      commands = [ plugin_name(@resource[:name]), '--url', @resource[:url] ]
    elsif !@resource[:source].nil?
      commands = [ plugin_name(@resource[:name]), '--url', "file://#{@resource[:source]}" ]
    else
      commands = [ @resource[:name] ]
    end
    commands
  end

  def install2x
    if !@resource[:url].nil?
      commands = [ @resource[:url] ]
    elsif !@resource[:source].nil?
      commands = [ "file://#{@resource[:source]}" ]
    else
      commands = [ @resource[:name] ]
    end
    commands
  end

  def create
    es_version
    commands = []
    commands << @resource[:proxy_args].split(' ') if @resource[:proxy_args]
    commands << 'install'
    commands << install1x if is1x?
    commands << install2x if is2x?
    debug("Commands: #{commands.inspect}")
    
    plugin(commands)
    writepluginfile
  end

  def destroy
    plugin(['remove', @resource[:name]])
  end

  def es_version
    return @es_version if @es_version
    begin
      version = es('-v') # ES 1.x
    rescue
      version = es('--version') # ES 2.x
    rescue
      raise "Unknown ES version. Got #{version.inspect}"
    ensure
      @es_version = version.scan(/\d+\.\d+\.\d+(?:\-\S+)?/).first
      debug "Found ES version #{@es_version}"
    end
  end

  def is1x?
    Puppet::Util::Package.versioncmp(@es_version, '2.0.0') < 0
  end

  def is2x?
    (Puppet::Util::Package.versioncmp(@es_version, '2.0.0') >= 0) && (Puppet::Util::Package.versioncmp(@es_version, '3.0.0') < 0)
  end

  def plugin_version(plugin_name)
    vendor, plugin, version = plugin_name.split('/')
    return @es_version if is2x? && version.nil?
    return version.scan(/\d+\.\d+\.\d+(?:\-\S+)?/).first unless version.nil?
    return false
  end

  def plugin_name(plugin_name)

    vendor, plugin, version = plugin_name.split('/')

    endname = vendor if plugin.nil? # If its a single name plugin like the ES 2.x official plugins
    endname = plugin.gsub(/(elasticsearch-|es-)/, '') unless plugin.nil?

    return endname.downcase if is2x?
    return endname

  end

end
