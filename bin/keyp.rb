#!/usr/bin/env ruby
# encoding: UTF-8

#
# NOTE: This is my first ruby gem and first executable ruby gem. I see a bunch of different
# implementations. A good number and a few well known use Thor, so seems like a good idea to
# figure out how to use Thor as well.
#
# I'm trying out some of the different impementations for Keyp, learning how they work, pros and cons
# Then I'll pick a single approach after exploring them


# resolve bin path, ignoring symlinks
require 'pathname'
bin_file = Pathname.new(__FILE__).realpath

# add self to libpath
#$:/

run_mode = :bundler

case run_mode

  when :bundler
# this is what bundler does in bundle

    Signal.trap('INT') { exit 1 }
    require 'keyp'

# Check if an older version

  when :pry
    # This is what pry does
    $0 = 'keyp'
    begin
      require 'keyp'
    rescue LoadError
      require 'rubygems'
      require 'keyp'
    end

# PRocess command line options and run Keyp
    Keyp::CLI.parse_options
  else
    puts "unhandled run_mode #{run_mode}"

end

