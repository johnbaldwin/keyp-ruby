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

  when :heroku
    # add self to libpath
    $:.unshift File.expand_path("../../lib", bin_file)

    #require "heroku/updater"
    #Heroku::Updater.disable("`heroku update` is only available from Heroku Toolbelt.\nDownload and install from https://toolbelt.heroku.com")

    # start up the CLI
    require "keyp/cli"
    # Heroku had ...agent = "heroku-gem/#{...}"
    Keyp.user_agent = "keyp/#{Keyp::VERSION} (#{RUBY_PLATFORM}) ruby/#{RUBY_VERSION}"
    Keyp::CLI.start(*ARGV)

  when :pry
    # This is what pry does. The begin, rescue is for Ruby prior to 1.9
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

