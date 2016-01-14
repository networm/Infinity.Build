# encoding: utf-8

require "./lib/options.rb"
require "./lib/common.rb"
require "./lib/unity3d.rb"
require "./lib/plist.rb"
require "./lib/xcode.rb"
require "./lib/clean.rb"

def options_check(options)
  if options.unity3d_project.empty? && Dir.exist?("../Assets") then
    options.unity3d_project = File.expand_path(Dir.pwd + "/..")
  end

  if options.xcode_project.empty? && !options.unity3d_project.empty? then
    options.xcode_project = xcode_project(options.unity3d_project)
  end

  if options.unity3d_project.empty? || !Dir.exist?(options.unity3d_project) then
    error "Unity3d project dir empty or didn't exist!"
    return false
  end

  if options.platform == :ios then
    if options.xcode_project.empty? then
      error "Xcode project dir empty!"
      return false
    end

    if options.p12.empty? then
      p12 = File.expand_path("~/Documents/Develop/Distribution.p12")

      if File.exist?(p12) then
        options.p12 = p12
      else
        error "P12 empty!"
        return false
      end
    end

    if options.profile.empty? then
      error "provisioning profile doesn't exist!"
      return false
    end
  end

  # Output final options
  puts "Final options"
  puts options
  puts

  return true
end

def main
  options = OptParse.parse(ARGV)

  if options_check(options) == false then
    exit
  end

  # Clean build
  clean(build_dir(options.unity3d_project))

  # Unity3d build
  unity3d(options.unity3d, options.unity3d_project, options.platform, options.type)

  # Platform build
  case options.platform
  when :ios then
    if  !Dir.exist?(options.xcode_project) then
      error "Xcode project dir didn't exist!"
      exit
    end

    xcode(options.profile, options.p12, options.p12_password,
      options.xcode_project, options.type, options.version,
      product_name(options.unity3d_project), options.ios_deployment)
  when :android then
    # TODO
  when :osx then
    # nothing
  when :win64 then
    # TODO
  else
    error "Platform error: " + options.platform
  end
end

# run
main()
