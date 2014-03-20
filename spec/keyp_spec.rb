require 'spec_helper'

describe Keyp do
  it 'should return correct version string' do
    #Keyp.version_string.should == "Keyp version #{Keyp::VERSION}"
    Keyp::VERSION.should == '0.0.1'
  end

  it 'should return correct default keyp dir' do
  # DEFAULT_KEYP_DIRNAME = ENV['KEYP_DIRNAME'] || '.keyp'
    Keyp::KEYP_HOME.should == File.join(ENV['HOME'], '.keyp')
  end

  it 'should specify default store' do
    Keyp::DEFAULT_STORE.should == 'default'
  end
  it 'should specify default store file' do
    Keyp::DEFAULT_STORE_FILE.should == 'default.yml'
  end

  it 'should be able to override default keyp dir'

  it 'should return default bag' do
    keyper = Keyp::bag
    keyper.bag.should == 'default'
  end

  it 'should return a key with data member'
  it 'should return a key acting as a hash'
  it 'should allow assigning a key if not read only'
  it 'should not allow assigning a key if read only'
  it 'should set the dirty flag if a new key is created'
  it 'should set the dirty flag if a key is given a new value'
  it 'should not set the dirty flag if a key is assigned a value equal to its existing value'

end
