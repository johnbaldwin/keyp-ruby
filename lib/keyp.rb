require "keyp/version"
require 'json'
require 'yaml'

module Keyp
  # Your code goes here...
  ORIGINAL_ENV = ENV.to_hash

  # TODO:
  # Put this in initializer so testing can create its own directory and not muck
  # up the operational default

  DEFAULT_KEYP_DIRNAME= '.keyp'
  DEFAULT_KEYP_DIRPATH = File.join(ENV['HOME'], DEFAULT_KEYP_DIRNAME)
  DEFAULT_STORE = File.join(DEFAULT_KEYP_DIRPATH,'default.yml')
  # This method sets up the keyp director
  #def self.setup
  #  # check if keyp directory exists. If not, set it up
  #  unless Dir.exist?(File.join(DEFAULT_KEYP_DIRNAME))
  #
  #  end
  #end

  # Give full path
  # TODO: consider changing to class method
  def self.load_config(config_path)
    config_data = {}
    # Get extension
    file_ext = File.extname(config_path)

    unless File.exist? config_path
      if config_path == DEFAULT_STORE
        # create the default file
        f = File.open(DEFAULT_STORE,'w')
        #f.puts("default:")
        f.close
        return {}
      else
        raise "Keyp config file not found: #{config_path}"
      end
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
    config_data
  end

  # Some inspiration:
  # http://stackoverflow.com/questions/2680523/dry-ruby-initialization-with-hash-argument
  #
  # TODO: add handling so that keys (hierarchical keys too) are accessed as members instead of
  # hash access
  class Keyper

    attr_reader :keypdir, :default_bag
    attr_accessor :current_bag, :config

    def config_path
      File.join(@keypdir, @current_bag)
    end


    # I'm not happy with how this works. There must be a cleaner way
    def initialize(args={})
      args.each do |k,v|
        puts "processing args #{k} = #{v}"
        instance_variable_set("@#{k}", v) unless v.nil?

        @keypdir ||= Keyp::DEFAULT_KEYP_DIRPATH
        @default_bag ||= 'default'
        @current_bag ||= @default_bag
        @read_only ||= false
        @ext ||= '.yml'
        # load our resource

        # load config file into hash

        @config = Keyp::load_config(config_path+@ext)
      end

    end

  end

end
