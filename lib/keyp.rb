require "keyp/version"
require 'json'
require 'yaml'

#
# TODO: build out cli.rb to trim the exe script, keyp to its bare minimum
#
module Keyp
  # Your code goes here...
  ORIGINAL_ENV = ENV.to_hash

  # TODO:
  # Put this in initializer so testing can create its own directory and not muck
  # up the operational default


  KEYP_HOME = File.join(ENV['HOME'], '.keyp')
  DEFAULT_STORE = 'default'
  DEFAULT_EXT = '.yml'
  # This method sets up the keyp director
  #def self.setup
  #  # check if keyp directory exists. If not, set it up
  #  unless Dir.exist?(File.join(DEFAULT_KEYP_DIRNAME))
  #
  #  end
  #end


  def self.setup(options ={})

    # check if keyp directory exists

    unless Dir.exist?(KEYP_HOME)
      puts "making directory #{KEYP_HOME}"
      Dir.mkdir(KEYP_HOME, 0700)
    else
      Puts "#{KEYP_HOME} already exists"
    end

    KEYP_HOME
=begin
    if config_path == DEFAULT_STORE
      # create the default file

      f = File.open(DEFAULT_STORE,'w')
      #f.puts("default:")
      f.close
      return {}
    else
      raise "Non default stores not yet implemented"
    end
=end
  end

  # NOTE: No copy method
  # No method to explicitly copy one bag to another
  # Too prone to unwanted overwriting
  # Instead, use create and pass in the other bag as a
  # named parameter

  # create a new bag persist
  # TODO: check options for a has to write to the bag
  def self.create(bag, options={})
    # two root sections in a bag
    # meta:
    #   meta will contain information for use by keyp about this particular bag
    #   such as encoding rules, case sensitivity
    # data:
  end

  # Convenience method to create a new Bag
  def self.bag(name='default', options = {})
    keyper = Keyper.new(name, options)
    keyper
  end


  def self.add_to_env(bag)
    # TODO: Add checking, upcase
    bag.data.each do |key,value|
      ENV[key] = value
    end
  end

  def self.create_store(name, options = {} )
    filepath = File.join(KEYP_HOME, name + DEFAULT_EXT)

    time_now = Time.now.utc.iso8601
    file_data = {}
    file_data['meta'] = {
      'name' => name,
      'description' => '',
      'created_at' => time_now,
      'updated_at' => time_now
    }
    file_data['data'] = nil
    unless File.exist? filepath
      File.open(filepath, 'w') do |f|
        f.write file_data.to_yaml
        f.chmod(0600)
      end
    else
      raise "Unable to create a new store at #{filepath}. One already exists."
    end
    bag name
  end

  def self.parse_arg_string(arg_string, options={})

    mode = options[:token_mode] || :default

    case mode
      when :unstable
        arg_re = /(?<key>\w*)\=(?<value>.*)/
        nvp = arg_re.match(arg_string)
      when :default
        parsed = arg_string.partition('=')
        if parsed[1] == '='
          nvp = { key: parsed[0], value: parsed[2] }
        else
          # Consider: adding token_mode to error message
          raise "unable to create a key/value pair from #{arg_string}"
        end
      else
        raise "parse_arg_string unsupported mode #{mode}"
    end
    nvp
  end


  # ----------------------------------------------

  # Some inspiration:
  # http://stackoverflow.com/questions/2680523/dry-ruby-initialization-with-hash-argument
  #
  # TODO: add handling so that keys (hierarchical keys too) are accessed as members instead of
  # hash access
  #
  # TODO: move to own file, rename to "Bag"
  # TODO: i18n error messages
  #
  class Keyper

    attr_reader :keypdir, :dirty
    attr_accessor :name, :data, :file_hash

    def config_path
      File.join(@keypdir, @name)
    end

    # We expect
    # I'm not happy with how creating instance variables works. There must be a cleaner way
    def initialize(name, options = {})
      @name = name
      options.each do |k,v|
        puts "processing options #{k} = #{v}"
        instance_variable_set("@#{k}", v) unless v.nil?
      end
        # set attributes not set by params

      @keypdir ||= Keyp::KEYP_HOME
      @read_only ||= false
      @ext ||= '.yml'
      @keypfile = config_path+@ext
      # load our resource

      # load config file into hashes
      # not the most efficient thing, but simpler and safe enough for now

      unless File.exist? @keypfile
        puts "Keuper.initialize, create_store #{@keypfile}"
        Keyp::create_store(@keypfile)
      end
      file_data = load(@keypfile)

      @meta = file_data[:meta]
      @data = file_data[:data]
      @file_hash = file_data[:file_hash]
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
        raise "Keyper #{@name} is read only"
      end
    end

    def delete(key)
      unless @read_only
        if @data.key? key
          @dirty = true
        end
        val = @data.delete(key)
      else
        raise "Bag #{@name} is read only"
      end
      val
    end

    # Give full path, attempt to load
    # sticking with YAML format for now
    # May add new file format later in which case we'll
    # TODO: consider changing to class method
    def load (config_path)
      #config_data = {}
      # Get extension
      file_ext = File.extname(config_path)

      # check
      # only YAML supported for initial version. Will consider adapters to
      # abstract the persistence layer


      # TODO: make this hardcoded case a hash of helpers
      # TODO: Add two sections: Meta and data, then return as hash

      if file_ext.downcase == '.yml'

        # Either we are arbitrarily creating directories when
        # given a path for a file that doesn't exist
        # or we have special behavior for the default dir
        # or we just fault and let the caller deal with it
        unless File.exist? config_path
          raise "Keyp config file not found: #{config_path}"
        end

        file_data = YAML.load_file(config_path)

      else
          raise "Keyp version x only supports YAML for config files. You tried a #{file_ext}"
      end
      { meta: file_data['meta'], data: file_data['data'], file_hash: file_data.hash }
    end

    # NOT thread safe
    # TODO: make thread safe
    def save
      if @read_only
        raise "This bag instance is read only"
      end
      if @dirty
        # lock file
        # read checksum
        # if checksum matches our saved checksum then update file and release lock
        # otherwise, raise
        # TODO: implement merge from updated file and raise only if conflict
        begin
          file_data = { 'meta' => @meta, 'data' => @data }

          File.open(@keypfile, 'w') do |f|
            f.write file_data.to_yaml
          end
          @dirty = false
        rescue
          # TODO: log error

        end
      end
    end
  end


  # Hmm, do we really need this or can we suffice with the meta hash in the bag
  class Meta
    attr_accessor :name, :description, :created, :updated
    def initialize(hash, options = {})

    end
  end
end
