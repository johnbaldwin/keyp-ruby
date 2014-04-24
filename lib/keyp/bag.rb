module Keyp
  # ----------------------------------------------

  # Some inspiration:
  # http://stackoverflow.com/questions/2680523/dry-ruby-initialization-with-hash-argument
  #
  # TODO: add handling so that keys (hierarchical keys too) are accessed as members instead of hash access
  #
  # TODO: i18n error messages
  # TODO: handle symbol to string and back for keys. Need instance setting to handle validating keys as symbols
  #
  class Bag

    # TODO: Make name attr_reader
    # TODO: See if we need data as an attr_accessor If not then it makes
    # it easier to encapsulate handling of string/symbol keys
    attr_reader :keypdir, :dirty, :meta
    attr_accessor :data, :file_hash

    def name
      @meta['name']
    end

    ##
    # Returns the full path of this Bag's file
    def keypfile
      File.join(@keypdir, name+@ext)
    end

    ##
    # Object initializer
    #
    # === options
    # +keypdir+
    # +read_only+
    # +ext+
    def initialize(bag_name, options = {})
      # I'm not happy with how creating instance variables works. There must be a cleaner way
      @meta = { 'name' => bag_name}
      options.each do |k,v|
        #JB set debug log: puts "processing options #{k} = #{v}"
        instance_variable_set("@#{k}", v) unless v.nil?
      end

      # set attributes not set by params
      @keypdir ||= Keyp::home
      @read_only ||= false
      @ext ||= Keyp::DEFAULT_EXT

      unless File.exist? keypfile
        #JB set debug log: puts "Bag.initialize, create_bag #{keypfile}"
        #TODO: move this to its own method
        time_now = Time.now.utc.iso8601(TIMESTAMP_FS_DIGITS)
        file_data = {}
        file_data['meta'] = {
            'name' => bag_name,
            'description' => '',
            'created_at' => time_now,
            'updated_at' => time_now
        }
        file_data['data'] = nil
        File.open(Keyp::bag_path(bag_name), 'w') do |f|
          f.write file_data.to_yaml
          f.chmod(0600)
        end
      end
      load_file
      @dirty = false
    end

    ##
    #
    def [](key)
      # TODO: convert from any symbols to string
      @data[key]
    end

    ##
    #
    def []=(key, value)
      set_prop(key, value)
    end

    ##
    # Sets a key:value pair
    # NOTE: This may be made protected
    def set_prop(key, value)
      # TODO
      unless @read_only
        # TODO: check if data has been modified
        # maybe there is a way hash tells us its been modified. If not then
        # just check if key,val is already in hash and matches
        unless @data.key?(key) && @data[key] == value
          @data[key] = value
          @dirty = true
        end
      else
        raise "Bag #{name} is read only"
      end
    end

    ##
    # Deletes the key:value pair from this bag for the given key
    def delete(key)
      if @read_only
        raise "Cannot delete key \"#{key}\". Bag \"#{name}\" is read only."
      end

      @dirty = true if @data.key? key
      @data.delete(key)
    end

    ##
    # Returns true if there are no key:value pairs, false if there are any
    def empty?
      @data.empty?
    end


    def read_only?
      @read_only
    end

    def key?(key)
      @data.key?(key)
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
    #  +:to_upper+

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

      pattern ||= /(..*)/
      @data.each do |key,value|
        if pattern.match(key)
          # TODO: add overwrite checking
          ENV[key] = value
          assigned[key] = value
        end
      end
      assigned
    end

    ##
    # load environment variables into this bag
    # === Options
    # +:pattern+ Applies keys matching this pattern
    # +:overwrite+ true to overwrite existing keys, false (default) to not overwrite existing keys
    #
    #
    def load_from_env(options = {})
      assigned = {}
      overwrite = options[:overwrite] || false
      pattern = options[:pattern] || /(..*)/
      ENV.each do | key, value|
        if pattern.match(key)
          unless overwrite && @data.key?(key)
            @data[key] = value
            assigned[key] = value
          end
        else
          puts "load_from_env. No match for #{key}"
        end
      end
      assigned
    end

    # TODO add from hash

    ##
    # renames the bag to +new_name+
    # returns new bag name if succesful, raises exception if not
    #
    def rename(new_name, options = {})

      # Since we are not changing any key pairs, the only meta to be changed is +name+
      #
      # TODO: Check for valid key name
      #TODO: change to try to create a new file and lock it. If we can, then we fill it
      if Keyp::exist?(new_name)
        raise "Bag rename error. Target \"#{new_name}\" already exists."
      end

      if @dirty
        # We don't want to allow renaming a bag with modified values because it will complicate rollback
        #TODO: improve error message
        raise "Can't rename a modified bag. Save first"
      end

      # TODO: treat the following as a transaction so if the bag file can't be renamed then
      # the old file is restored unmodified
      #curr_name = @meta['name']
      curr_name = name
      old_file = Keyp::bag_path(curr_name)
      to_file = Keyp::bag_path(new_name)
      #TODO: Add file locking for concurrency protection
      @meta['name'] = new_name
      @meta['last_name'] =curr_name
      @renaming = true
      # saves with the new name
      save
      @renaming = nil
      # now remove the old file
      File.delete(old_file)

      load_file
      @meta['name']
    end

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
    #
    def load_file
      file_data = Bag::load_file(keypfile)
      @meta = file_data[:meta]
      @data = file_data[:data]|| {}
      @file_hash = file_data[:file_hash]
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
      if @dirty || @renaming
        # lock file
        # read checksum
        # if checksum matches our saved checksum then update file and release lock
        # otherwise, raise
        # TODO: implement merge from updated file and raise only if conflict
        begin
          if File.exist? keypfile
            read_file_data = Bag::load_file(keypfile)
            unless @file_hash == read_file_data[:file_hash]
              raise "Will not write to #{keypfile}\nHashes differ. Expected hash =#{@file_hash}\n" +
                        "found hash #{read_file_data[:file_hash]}"
            end
          end
          if @dirty && !@renaming
            @meta['updated_at'] = Time.now.utc.iso8601(Keyp::TIMESTAMP_FS_DIGITS)
          end

          file_data = { 'meta' => @meta, 'data' => @data }
          File.open(keypfile, 'w') do |f|
            f.write file_data.to_yaml
          end
          @dirty = false
        rescue
          # TODO: log error

        end
      else
        puts "save called but not saving (not dirty or renaming flag set"
      end
    end


    # Class methods
    ##
    # Give full path, attempt to load
    # sticking with YAML format for now
    # May add new file format later in which case we'll
    # TODO: Make this a class method and an instance method
    # that calls the class method and does the instance assignment
    def self.load_file (config_path)
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


  end # class Bag
end # module Keyp