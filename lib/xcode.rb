# encoding: utf-8

require 'nokogiri'

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

def xcode(profile, p12, p12_password, xcode_project, type, version, product_name)
  log "Xcode build begin"

  if (File.exist?(profile)) then
    install_provision(profile)
  end

  codesign_begin(p12, p12_password)

  code_sign_identity = get_identity()

  # build xcode project and codesign
  xcode_project_path = xcode_project + "/Unity-iPhone.xcodeproj"

  if type == :develop then
    configuration = "Debug"
  else
    configuration = "Release"
  end

  run "xcodebuild clean -project \"#{xcode_project_path}\" -configuration \"#{configuration}\" \
      -target \"Unity-iPhone\" CODE_SIGN_IDENTITY=\"#{code_sign_identity}\""
  run "xcodebuild build -project \"#{xcode_project_path}\" -configuration \"#{configuration}\" \
      -target \"Unity-iPhone\" CODE_SIGN_IDENTITY=\"#{code_sign_identity}\""

  # package application
  type = type == :develop ? "Develop" : "Release"
  app_path = xcode_project + "/build/" + configuration + "-iphoneos/" + product_name.to_s + ".app"

  version_part = version.empty? ? "" : "-" + version
  ipa_path = xcode_project + "/build/" + configuration + "-iphoneos/" + product_name.to_s + version_part + ".ipa"
  run "xcrun --sdk iphoneos PackageApplication \"#{app_path}\" -o \"#{ipa_path}\""

  codesign_end()

  log "Xcode build end"
end
