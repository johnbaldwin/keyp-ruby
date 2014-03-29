require 'keyp/version'
require 'keyp/bag'
require 'json'
require 'yaml'

##
# This is the main module for the Keyp library
#
# = Overview
#
#
# Keyp is not yet supported on Windows
#
# = Developer notes
#
# NOTE: Do not implement a copy method to explicitly copy one bag to another.
# This is too prone to undesired overwriting.
# Instead, use create and pass in the other bag as a named parameter. This way
# we express
#
module Keyp

  # TODO: Revisit constants. Make a submodule for constants


  ##
  # Constant definitions

  # Save the original environment before this module instantiates
  ORIGINAL_ENV = ENV.to_hash

  # This constant sets the default bag when one is not specified in methods that need to
  # identify the bag
  DEFAULT_BAG = 'default'

  # Default file extension for the bags
  DEFAULT_EXT = '.yml'

  # Permissions for the KEYP_HOME directory
  DEFAULT_KEYP_DIR_PERMISSIONS = 0700

  # Default home directory that keyp uses to store bags
  DEFAULT_KEYP_DIR = '.keyp'

  #TODO: set this
  #ENV_VAR_NAME_REGEX =

  # Returns the directory used by Keyp to store the key bags
  #
  # By default, Keyp uses +$HOME/.keyp+ and sets permissions to 0700 to the +.keyp+ directory
  #
  # == Environment variable overrides
  #
  # You can override the default Keyp location by defining +KEYP_HOME+
  #
  # Keyp is currently designed to have a _per user_ configuration, but you should be able to
  # set it up for system wide use if you desire.

  # === Example
  # +export KEYP_HOME=/var/lib/keyp+
  #
  # *Security note* If you do this *and* you are storing sensitive information, then
  # it is recommended you restrict permissions
  #
  def self.home
    ENV['KEPY_HOME'] || File.join(ENV['HOME'], DEFAULT_KEYP_DIR)
  end

  ##
  #
  # Returns the file extension that Keyp uses for bags
  # Should return '.yml'
  #
  def self.ext
    DEFAULT_EXT
  end

  ##
  # Returns +true+ if the Keyp home diretory exists and is readable and writeable by the user
  # running Keyp
  def self.configured?
    Dir.exist?(home) && File.executable?(home) &&
        File.readable_real?(home) && File.writable_real?(home)
  end

  ##
  # Creates the Keyp home directory and sets permissions if the directory does not exist
  # See method +Keyp::home+
  # === Options
  # Not options yet
  def self.setup(options ={})

    # check if keyp directory exists

    unless Dir.exist?(home)
      puts "making directory #{home}"
      Dir.mkdir(home, 0700)
      if Dir.exist?(home)
        home
      else
        nil
      end
    else
      Puts "#{home} already exists"
      nil
    end
  end

  ##
  # Convenience method to create a new Bag
  #
  # ==== Parameters
  #
  # * +name+ - bag name. 'default' is used if no bag name is provided
  # * +options+ - options are passed through to Bag.new
  #
  def self.bag(name='default', options = {})
    bag = Keyper.new(name, options)
    bag
  end

  ##
  # Tells if a bag already exists for the keyp dir identified by the environment
  #
  def self.exist?(name)
    path = bag_path(name)
    File.exist? path
  end

  ##
  # returns the absolute path for the given bag
  #
  #
  def self.bag_path(name)
    path = File.join(home,name+ext)
  end

  ##
  # Returns an array of bag names
  # This method returns a list of bag names for the active Keyp repository
  # The default repository is $HOME/.keyp
  # If the environment variable, KEYP_HOME is set, this directory will be used.
  def self.bag_names(options = {})
    #TODO: enable pattern matching
    bags = []
    reg = Regexp.new('\\'+ext+'$')
    puts  reg
    dir = Dir.new(home)
    dir.each do |f|
      # Filter for only
      #if /\.yml$/.match(f)
      if reg.match(f)
        bags << File.basename(f,ext)
      end
    end
    bags
  end

  ##
  # Creates a new bag if one does not already exist with the given name
  #
  def self.create_bag(name, options = {} )
    time_now = Time.now.utc.iso8601
    file_data = {}
    file_data['meta'] = {
      'name' => name,
      'description' => '',
      'created_at' => time_now,
      'updated_at' => time_now
    }
    file_data['data'] = nil
    unless exist? name
      File.open(bag_path(name), 'w') do |f|
        f.write file_data.to_yaml
        f.chmod(0600)
      end
    else
      raise "Unable to create a new store at #{filepath}. One already exists."
    end
    bag name
  end

  ##
  # Deletes the bag matching the name
  # Returns true if successful, false if not
  def self.delete_bag(name, options = {})
    if exist? name
      # TODO: add exception handling
      numfiles = File.delete(bag_path(name))
      true
    else
      false
    end
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

  # ---------------------------------------------
  # Experimental stuff

  def self.set_sys_env(key, value)

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

    def keypfile
      File.join(@keypdir, @name+@ext)
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

      @keypdir ||= Keyp::home
      @read_only ||= false
      @ext ||= Keyp::DEFAULT_EXT
      #@keypfile = config_path
      # load our resource

      # load config file into hashes
      # not the most efficient thing, but simpler and safe enough for now

      unless File.exist? keypfile
        puts "Keyper.initialize, create_bag #{keypfile}"
        Keyp::create_bag(name)
      end
      file_data = load(keypfile)

      @meta = file_data[:meta]
      @data = file_data[:data]|| {}
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
        raise "Bag #{@name} is read only"
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

    def empty?
      @data.empty?
    end


    ##
    # Adds key/value pairs from this bag to the Ruby ENV
    # NOTE: Currently in development.
    # If no options are provided, then all of the bag's key/value pairs will be assigned.
    #
    # ==== Options
    # TBD:
    #  +:sysvar+ Only use valid system environment vars
    #  +:selection+ Provide a list of keys to match
    #  +:overwrite+
    #  +:no_overwrite+  - This is enabled by default
    #  +:to_upper

    # Returns a hash of the key/value pairs which have been set
    # ==== Examples
    # +add_to_env upper:+
    # To assign keys matching a pattern:
    # +add_to_env regex: '\A(_|[A-Z])[a-zA-Z\d]*'

    def add_to_env(options = {})
      # TODO: Add checking, upcase

      # pattern matching valid env var
      sys_env_reg = /\A(_|[a-zA-Z])\w*/
      assigned = {}
      overwrite = options[:overwrite] || false
      pattern = options[:sysvar] if options.key?(:sysvar)

      pattern ||= '(...)'

      bag.data.each do |key,value|
        if pattern.match(key)
          # TODO: add overwrite checking
          ENV[key] = value
          assigned[key] = value
        end
      end
      assigned
    end


    # TODO add from hash


    def import(filename)
      raise "import not yet supported"
    end

    def export(filename)
      raise "export not yet supported"
    end


    # TODO: def to_yaml
    # TODO: def to_json
    # TODO: def to_s

    ##
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

      if file_ext.downcase == Keyp::DEFAULT_EXT

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
      { meta: file_data['meta'], data: file_data['data']||{}, file_hash: file_data.hash }
    end

    ##
    # Saves the Bag to file
    #
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

          if File.exist? keypfile
            read_file_data = load(keypfile)
            unless @file_hash == read_file_data[:file_hash]
              raise "Will not write to #{keypfile}\nHashes differ. Expected hash =#{@file_hash}\n" +
                  "found hash #{read_file_data[:file_hash]}"
            end
          end
          File.open(keypfile, 'w') do |f|
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
