#!/usr/bin/env ruby
require "pathname"
require "erb"

class BG
  attr_reader :config_file, :images, :image, :template
  HOME = Pathname.new(ENV["HOME"])
  def initialize
    @images      = HOME.join("Pictures").children
    @images.push(HOME.join("Dropbox", "dev","getsnsdimg").children)
    @images.keep_if { |i| i.to_s =~ /.jpg/ } 
    @images.flatten!
    @template    = HOME.join(".config", "nitrogen", "bg-saved.cfg.erb")
    @config_file = HOME.join(".config", "nitrogen", "bg-saved.cfg")
  end

  def change_background
    @image_xin0 = @images.reject { |i| i.to_s == get_current_image("[xin_0]\n") }[rand(@images.size - 1)]
    @image_xin1 = @images.reject { |i| i.to_s == get_current_image("[xin_1]\n") }[rand(@images.size - 1)]
    puts @image_xin0 if $DEBUG
    puts @image_xin1 if $DEBUG
    erb = ERB.new(File.read(@template))
    File.open(@config_file, "w+") { |f| f.puts erb.result(binding) }
  end
  
  def get_current_image(searchstring)
    lines = File.readlines(@config_file)
    file_index = (lines.index { |a| a == searchstring } + 1)
    lines[file_index].split(/\s*=\s*/,2)[1].chomp
  end

#  def current_image
#    lines = File.readlines(@config_file)
#    file_index = (lines.index { |a| a == "[xin_0]\n" } + 1)
#    lines[file_index].split(/\s*=\s*/,2)[1].chomp
#  end

  def self.change_background
    new.change_background
  end

  def self.current_image_xin0
    #new.current_image
    new.get_current_image("[xin_0]\n")
  end

  def self.current_image_xin1
    new.get_current_image("[xin_1]\n")
  end
end

if $0 == __FILE__
  #loop do
    print "Current images:\n"
    print "#{BG.current_image_xin0}\n"
    print "#{BG.current_image_xin1}\n"
    print "Images changed to:\n"
    BG.change_background
    print "#{BG.current_image_xin0}\n#{BG.current_image_xin1}\n"
    exec "export DISPLAY=:0.0;/usr/bin/nitrogen --restore"
    #sleep 15
  #end
end

