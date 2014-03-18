require 'spec_helper'

describe Keyp do
  it 'should return correct version string' do
    #Keyp.version_string.should == "Keyp version #{Keyp::VERSION}"
    Keyp::VERSION.should == '0.0.1'
  end

  it 'should return correct default keyp dir' do
  # DEFAULT_KEYP_DIRNAME = ENV['KEYP_DIRNAME'] || '.keyp'
    Keyp::DEFAULT_KEYP_DIRNAME.should == File.join(ENV['HOME'], '.keyp')
  end

  it 'should be able to override default keyp dir' do
    ENV['KEYP_HOME'] = File.join(ENV['HOME'], '.keyp-test')
    keyper = Keyp::keyper
    keyper.home.should == '.keyp-test'
  end
end
