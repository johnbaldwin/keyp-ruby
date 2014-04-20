require 'keyp/version'
require 'keyp/bag'
require 'json'
require 'yaml'
require 'time'

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

  # number of digits for the fractional seconds in decimal
  TIMESTAMP_FS_DIGITS = 6
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
    #puts "Keyp::home, KEYP_HOME=#{ENV['KEYP_HOME']}"
    ENV['KEYP_HOME'] || File.join(ENV['HOME'], DEFAULT_KEYP_DIR)
=begin
    puts "home_dir=#{home_dir}"
    if ENV['KEYP_HOME']
      ENV['KEYP_HOME']
    else
      File.join(ENV['HOME'], DEFAULT_KEYP_DIR)
    end
=end
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
      Dir.mkdir(home, 0700)
      if Dir.exist?(home)
        home
      else
        raise "unable to create Keyp directory #{home}"
      end
    else
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
    bag = Bag.new(name, options)
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
    time_now = Time.now.utc.iso8601(TIMESTAMP_FS_DIGITS)
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

  ##
  #
  # == options
  # +:from+ current name of the bag (rename from)
  # +:to+ new name of the bag (rename to)
  #
  def self.rename_bag(options = {})

    #TODO: Implement this
    # validate_options(:from,:to)

    from_name = options[:from]
    to_name = options[:to]

    unless from_name || to_name
      raise "required parameters are missing. Requires both :from and :to"
    end

    # if current bag does not exist, we raise and exception
    unless exist?(from_name)
      raise ("cannot rename #{from_name} because it does not exist")
    end
    #bag = bag(from_name)
    #bag.rename(to_name)
    bag(from_name).rename(to_name)
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



  # Hmm, do we really need this or can we suffice with the meta hash in the bag
  class Meta
    attr_accessor :name, :description, :created, :updated
    def initialize(hash, options = {})

    end
  end
end
