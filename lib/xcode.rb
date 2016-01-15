# encoding: utf-8

require 'nokogiri'
require "./lib/plist.rb"

KEYCHAIN_NAME = "infinity-build.keychain"
KEYCHAIN_PASSWORD = "password"

def profile_uuid(provisioning_profile_path)
  profile_contents = File.open(provisioning_profile_path).read
  profile_contents = profile_contents.slice(profile_contents.index('<?'), profile_contents.length)
  doc = Nokogiri.XML(profile_contents)
  return doc.xpath('//key[text()="UUID"]')[0].next_element.text
end

# install provisioning profiles
def install_provision(profile)
  uuid = profile_uuid(profile)

  run "mkdir -p ~/Library/MobileDevice/Provisioning\\ Profiles"
  run "cp -f #{profile} ~/Library/MobileDevice/Provisioning\\ Profiles/#{uuid}.mobileprovision"
  run "ls ~/Library/MobileDevice/Provisioning\\ Profiles/"
end

def codesign_begin(p12, p12_password)
  # create temporary keychain
  run "security create-keychain -p \"#{KEYCHAIN_PASSWORD}\" \"#{KEYCHAIN_NAME}\""
  # unlock keychain
  run "security unlock-keychain -p \"#{KEYCHAIN_PASSWORD}\" \"#{KEYCHAIN_NAME}\""

  # import p12 and allow codesign access
  run "security import \"#{p12}\" -P \"#{p12_password}\" -k \"#{KEYCHAIN_NAME}\" -T /usr/bin/codesign"
  # set keychain search list
  run "security list-keychain -s \"#{KEYCHAIN_NAME}\""
end

def codesign_end()
  # restore user keychain search list
  run "security list-keychain -s login.keychain"
  # delete temporary keychain
  run "security delete-keychain \"#{KEYCHAIN_NAME}\""
end

def get_identity()
  ## retrieve identity
  dump = `security dump-keychain \"#{KEYCHAIN_NAME}\"`
  line = dump.match(/^\s+\"alis\"\<blob\>\=\"(.*)\"$/)
  return line.to_s.gsub(/^\s+\"alis\"\<blob\>\=\"(.*)\"$/, '\1')
end

def get_teamid()
  ## retrieve team id
  dump = `security dump-keychain \"#{KEYCHAIN_NAME}\"`
  line = dump.match(/^\s+\"alis\"\<blob\>\=\"(.*)\"$/)
  return line.to_s.gsub(/^\s+\"alis\"\<blob\>\=\".*\((.*)\)\"$/, '\1')
end

def archive(xcode_project_path, configuration, uuid, code_sign_identity, archive_path, export_options_plist, export_path)
  run "xcodebuild archive -project \"#{xcode_project_path}\" -configuration \"#{configuration}\" \
      -scheme \"Unity-iPhone\" CODE_SIGN_IDENTITY=\"#{code_sign_identity}\" PROVISIONING_PROFILE=\"#{uuid}\" \
      -archivePath \"#{archive_path}\""

  run "xcodebuild -exportArchive -archivePath \"#{archive_path}\" \
      -exportOptionsPlist \"#{export_options_plist}\" -exportPath \"#{export_path}\""
end

def set_bundleversion(xcode_project, version)
  info_plist = xcode_project + "/Info.plist"
  run "/usr/libexec/PlistBuddy -c \"Set :CFBundleVersion '#{version}'\" #{info_plist}"
end

def xcode(profile, p12, p12_password, xcode_project, type, version, product_name, ios_deployment, teamid)
  log "Xcode build begin"

  # set bundle Version
  set_bundleversion(xcode_project, version)

  if (File.exist?(profile)) then
    install_provision(profile)
  end

  if type == :develop then
    configuration = "Debug"
  else
    configuration = "Release"
  end

  xcode_project_path = xcode_project + "/Unity-iPhone.xcodeproj"

  codesign_begin(p12, p12_password)
  code_sign_identity = get_identity()
  uuid = profile_uuid(profile)

  if teamid.empty? then
    teamid = get_teamid()
  end

  # clean
  run "xcodebuild clean -project \"#{xcode_project_path}\" -configuration \"#{configuration}\" \
      -target \"Unity-iPhone\" CODE_SIGN_IDENTITY=\"#{code_sign_identity}\""

  case ios_deployment
  when "app-store" then
    archive_path = xcode_project + "/build/" + product_name.to_s + ".xcarchive"
    export_options_plist = appstore_export_options(teamid, xcode_project)
    # xcodebuild tool has wrong exportPath parameter, it should be exportDir actually.
    export_path = xcode_project + "/build/"

    archive(xcode_project_path, configuration, uuid, code_sign_identity, archive_path, export_options_plist, export_path)

    clean_export_options(export_options_plist)

  when "ad-hoc" then
    archive_path = xcode_project + "/build/" + product_name.to_s + ".xcarchive"
    export_options_plist = adhoc_export_options(teamid, xcode_project)
    # xcodebuild tool has wrong exportPath parameter, it should be exportDir actually.
    export_path = xcode_project + "/build/"

    archive(xcode_project_path, configuration, uuid, code_sign_identity, archive_path, export_options_plist, export_path)

    clean_export_options(export_options_plist)

  when "development" then
    run "xcodebuild build -project \"#{xcode_project_path}\" -configuration \"#{configuration}\" \
        -target \"Unity-iPhone\" CODE_SIGN_IDENTITY=\"#{code_sign_identity}\" PROVISIONING_PROFILE=\"#{uuid}\""

    # package application
    type = type == :develop ? "Develop" : "Release"
    app_path = xcode_project + "/build/" + configuration + "-iphoneos/" + product_name.to_s + ".app"

    version_part = version.empty? ? "" : "-" + version
    ipa_path = xcode_project + "/build/" + configuration + "-iphoneos/" + product_name.to_s + version_part + ".ipa"
    run "xcrun --sdk iphoneos PackageApplication \"#{app_path}\" -o \"#{ipa_path}\""

  else
    error "ios_deployment wrong!"
  end

  codesign_end()

  log "Xcode build end"
end
