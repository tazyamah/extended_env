# -*- coding: utf-8 -*- 
class ExtendedEnv
  @@init = false
  @@config_file = ".env"
  @@keygen = lambda{|name| [name.to_s.upcase, name.to_s.downcase]}
  @@namegen = lambda{|name| name.to_s.downcase}

  def self.method_missing(name, *args, &block)
    init
    define_env_method(name)
    send name
  end

  def self.config_file=(config_file)
    @@config_file = config_file
  end

  def self.env_key_generator=(gen)
    @@keygen = gen
  end
  
  def self.env_name_generator=(gen)
    @@namegen = gen
  end

  private

  def self.init
    unless @@init
      @@init = true
      if File.exist?(@@config_file)
        open(@@config_file).each_line do |line|
          key, value = line.scan(/([a-zA-Z0-9_-]+)\s*=\s*(\S*)/).first
          next unless key
          define_env_method(key, value)
        end
      end
    end
  end

  def self.define_env_method(key, value=nil)
    name = @@namegen.call(key)
    return if respond_to? name
    value = @@keygen.call(name).map{|env_key| ENV[env_key]}.compact.first unless value
    
    sig = class << self; self end
    sig.send :define_method, name.to_sym, Proc.new{ value }
  end
end

if $0==__FILE__
  p ENV["PATH"]
  p ExtendedEnv.methods.include?(:path)
  p ExtendedEnv.path
  p ExtendedEnv.methods.include?(:path)
  p ExtendedEnv.path
  puts "=================================="
  p ExtendedEnv.methods
end
