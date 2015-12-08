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
      debug "Got #{readpluginfile} Expected #{pluginfile_content}"
      self.destroy
      false
    else
      debug "Plugin exists"
      return true
    end
  end

  def pluginfile_content
    if is2x?
      items = @resource[:name].split("/")
      if items.count == 1 # Official plugin
        version = plugin_version(@resource[:name])
        return "#{@resource[:name]}/#{version}"
      else
        return @resource[:name]
      end
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
    commands << @resource[:proxy_args] if @resource[:proxy_args]
    commands << 'install'
    commands << install1x if is1x?
    commands << install2x if is2x?
    
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
    items = plugin_name.split("/")
    if is1x?
      if items.count == 3 # 'mobz/elasticsearch-head/1.2.3'
        return items[2].scan(/\d+\.\d+\.\d+(?:\-\S+)?/).first
      end
    elsif is2x?
      if items.count == 1
        return @es_version
      elsif items.count == 3
        return items[2].scan(/\d+\.\d+\.\d+(?:\-\S+)?/).first
      end
    end
    return false
  end

  def plugin_name(plugin_name)

    items = plugin_name.split("/")

    if items.count == 1
      endname = items[0]
    elsif items.count > 1
      plugin = items[1]
      if plugin.include?('-') # example elasticsearch-head
        if plugin.start_with?('elasticsearch-')
          endname = plugin.gsub('elasticsearch-', '')
        elsif plugin.start_with?('es-')
          endname = plugin.gsub('es-', '')
        else
          endname = plugin
        end
      else
        endname = plugin
      end
    else
      raise(Puppet::ParseError, "Unable to parse plugin name: #{plugin_name}")
    end
    return endname.downcase if is2x?
    return endname

  end

end
