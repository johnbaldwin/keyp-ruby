[![Gem Version](https://badge.fury.io/rb/keyp.png)](http://badge.fury.io/rb/keyp)

# Keyp

Keyp is an executable Ruby gem that manages user/machine specific key/value pairs for your Ruby application.

Web applications generally need sensitive information, like salts and keys. Managing these generally involves writing
 a custom solution for your application. Approaches are typically environment variables, custom data files, or
 environment setting scripts. Following best practices, we don't want to store these in version control with our
 application source. So I'm creating Keyp to make it simple to manage keys for your application across the development,
 testing, and production environments.

## Important

Keyp is still in early development and is experimental. As such it is very much a work in progress. Not all features
expressed in the documentation may be working. The documentation may be plain wrong. I don't recommend you use Keyp
for any kind of production code at this point in this gem's lifecycle.

## Quick Tour

To install, see "Installation" below

Keyp manages key value pairs in collections. As of version 0.0.4, Keyp refers to collections as *bags*. There is a
default bag called *default*. Unless you specify a bag name, *default* will be used.

Here are some command line examples showing some basic Keyp functionality using the default bag. Here we set a couple
of keys, list all the key/value pairs in the default bag, and finally get the value for a single key.

    $ keyp set cloud_access_id=BMT216AF63958
    $ keyp set cloud_secret_key=eabca9a58834aec15af0578ac84abfbdab7c3795

    $ keyp list
    * bag:default
    cloud_access_id: BMT216AF63958
    cloud_secret_key: eabca9a58834aec15af0578ac84abfbdab7c3795

    $ keyp get cloud_access_id
    BMT216AF63958

In your Ruby application, you can use Keyp as follows:

    # get keys from the default key collection and use
    bag = Keyp.bag
    my_account.authenticate(bag['cloud_access_id'],bag['cloud_secret_key'])

    # or update ENV
    bag = Keyp.bag
    Keyp::add_to_env(bag)

    my_account.authenticate(ENV['cloud_access_id'],ENV['cloud_secret_key'])

Keyp is not limited to just access keys. Any kind of string based name/value pair can be used.

TODO: Improve description

_CAVEAT:_ This gem is at an early stage in development. Functionality is 
subject to change depending on need and clarity.

## Installation

Add this line to your application's Gemfile:

    gem 'keyp'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install keyp

## Setup

Run the following to set up default installation
    $ keyp init
This will create a $HOME/.keyp directory if one does not already exist, configure this director for use with Keyp.

### Customization

Keyp uses the ~/.keyp directory by default. To override, set the environment variable, KEYP_HOME to your choice
of directory.

TODO: add Bash config setting to export Keyp ENV vars to the ENV or make ENV vars accessible via Keyp hashes

## Usage

TODO: Write detailed usage instructions here

###


### Command line interface

TODO: Write more detailed documentation, For now, see the quick start above and run the following to see CLI options
    $ keyp --help

## Release Notes
* v 0.0.7 - Added loading a bag from the ENV. fixed error with keys of lett than three characters.
* v 0.0.6 - Added copying key:values to the Ruby ENV in the library (still have to implement in the CLI)
* v 0.0.5 - Fixed iso8601 error
* v 0.0.4 - Fixed missing file error

## Development plan/Features to implement

* Fill out rspec tests 
* Incorporate with shell configuration
* Write very clear documentation
* Implement import/Export to YAML and/or JSON
* Add API interfaces for other language, starting with Python
* Consider: Add configuration options for storage (YAML,JSON, SQLITE)


## Contributing

1. Fork it ( http://github.com/<my-github-username>/keyp/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
