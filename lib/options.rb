require 'optparse'
require 'ostruct'
require 'pp'

class OptParse

  Version = "1.0.0"

  #
  # Return a structure describing the options.
  #
  def self.parse(args)
    # The options specified on the command line will be collected in *options*.
    # We set default values here.
    options = OpenStruct.new

    options.platform = :ios
    options.type = :release

    options.unity3d = "/Applications/Unity/Unity.app/Contents/MacOS/Unity"
    options.unity3d_project = ""

    options.ios_deployment = "app-store"
    options.version = ""
    options.p12 = ""
    options.p12_password = ""
    options.profile = ""
    options.teamid = ""
    options.xcode_project = ""

    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: build.rb [options]"

      opts.separator ""
      opts.separator "Specific options:"

      opts.separator ""
      opts.separator "  Build options:"
      opts.on("--platform [PLATFORM]", [:ios, :android, :osx, :win64],
              "Select platform (ios, android, osx, win64).") do |platform|
        options.platform = platform
      end

      opts.on("--type [TYPE]", [:develop, :release],
              "Select build type (develop, release).") do |type|
        options.type = type
      end

      opts.separator ""
      opts.separator "  Unity3d options:"

      opts.on("--unity3d [PATH]",
              "Unity3d path. Default: Unity3d default install path.") do |unity3d_project|
        options.unity3d_project = unity3d_project
      end

      opts.on("--unity3d-project [DIR]",
              "Unity3d project dir.") do |unity3d_project|
        options.unity3d_project = unity3d_project
      end

      opts.separator ""
      opts.separator "  iOS options:"

      opts.on("--deployment [DEPLOYMENT]", ["app-store", "ad-hoc", "development"],
              "Select ios deployment (app-store, ad-hoc, development).") do |ios_deployment|
        options.ios_deployment = ios_deployment
      end

      opts.on("--build [VERSION]",
              "Build or Bundle version.") do |version|
        options.version = version
      end

      opts.on("--p12 [PATH]",
              "P12 path.") do |p12|
        options.p12 = p12
      end

      opts.on("--p12-password [PASSWORD]",
              "P12 password.") do |p12_password|
        options.p12_password = p12_password
      end

      opts.on("--provision [PROFILE]",
              "Provisioning Profile path.") do |profile|
        options.profile = profile
      end

      opts.separator ""
      opts.separator "Common options:"

      opts.on("-n", "--dry-run", "Don't actually do anything, just show what would be done!") do |v|
        $dryrun = true
      end

      # No argument, shows at tail.  This will print an options summary.
      # Try it and see!
      opts.on_tail("-h", "--help", "Show this message.") do
        puts opts
        exit
      end

      # Another typical switch to print the version.
      opts.on_tail("-v", "--version", "Show version.") do
        puts Version
        exit
      end
    end

    opt_parser.parse!(args)
    return options
  end  # parse()

end  # class OptParse
