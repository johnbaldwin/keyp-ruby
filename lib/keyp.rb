require "keyp/version"
require 'json'
require 'yaml'

module Keyp
  # Your code goes here...
  ORIGINAL_ENV = ENV.to_hash

  # TODO:
  # Put this in initializer so testing can create its own directory and not muck
  # up the operational default


  KEYP_HOME = File.join(ENV['HOME'], '.keyp')
  DEFAULT_STORE = 'default'
  DEFAULT_STORE_FILE = 'default.yml'
  # This method sets up the keyp director
  #def self.setup
  #  # check if keyp directory exists. If not, set it up
  #  unless Dir.exist?(File.join(DEFAULT_KEYP_DIRNAME))
  #
  #  end
  #end


  # Give full path, attempt to load
  # TODO: consider changing to class method
  def self.load_config(config_path)
    #config_data = {}
    # Get extension
    file_ext = File.extname(config_path)

    # Either we are aribitrarily creating directories when
    # given a path for a file that doesn't exist
    # or we have special behavior for the default dir
    # or we just fault and let the caller deal with it
    unless File.exist? config_path
      raise "Keyp config file not found: #{config_path}"
    end

    # check
    # only YAML supported for initial version

    # TODO: make this hardcoded case a hash of helpers
    case file_ext
      when '.yml'
        config_data = YAML.load_file(config_path)

      when '.json'
        config_data = JSON.parse(File.read(config_path))
      else
        raise "Keyp version x only supports YAML for config files. You tried a #{file_ext}"
    end
    config_data || {}
  end

  def keyper(bagname, options: "options", scpe: "scope")
    puts options
  end

  def self.setup(options ={})

    if config_path == DEFAULT_STORE
      # create the default file

      f = File.open(DEFAULT_STORE,'w')
      #f.puts("default:")
      f.close
      return {}
    else
      raise "Non default stores not yet implemented"
    end

  end

  def self.bag(bag='default', options = {})
    keyper = Keyper.new(bag, options)
    keyper
  end

  # Some inspiration:
  # http://stackoverflow.com/questions/2680523/dry-ruby-initialization-with-hash-argument
  #
  # TODO: add handling so that keys (hierarchical keys too) are accessed as members instead of
  # hash access
  class Keyper

    attr_reader :keypdir, :default_bag
    attr_accessor :bag, :data

    def config_path
      File.join(@keypdir, @bag)
    end

    # I'm not happy with how this works. There must be a cleaner way
    def initialize(bag=default, options = {})
      @bag = bag
      options.each do |k,v|
        puts "processing options #{k} = #{v}"
        instance_variable_set("@#{k}", v) unless v.nil?
      end
        # set attributes not set by params

      @keypdir ||= Keyp::KEYP_HOME
      @read_only ||= false
      @ext ||= '.yml'
      # load our resource

      # load config file into hash

      @data = Keyp::load_config(config_path+@ext)
      @dirty = false
    end

    def [](key)
      @data[key]
    end

    def []=(key, value)
      set_prop(key, value)
    end

    def set_prop(key, value)
      unless @read_only
        # TODO: check if data has been modified
        # maybe there is a way hash tells us its been modified. If not then
        # just check if key,val is already in hash and matches
        @data[key] = value
        @dirty = true
      else
        raise "Keyper #{@bag} is read only"
      end

    end
  end

end
