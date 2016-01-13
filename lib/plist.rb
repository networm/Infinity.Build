# encoding: utf-8

PlistBuddy = "/usr/libexec/PlistBuddy"
AppStoreExportOptions = "AppStoreExportOptions.plist"
AdHocExportOptions = "AdHocExportOptions.plist"

def appstore_export_options(teamid, options_dir)
  options_path = File.expand_path(options_dir + "/" + AppStoreExportOptions)

  system("#{PlistBuddy} -c \"Add :method string 'app-store'\" #{options_path}")
  system("#{PlistBuddy} -c \"Add :uploadBitcode bool NO\" #{options_path}")
  system("#{PlistBuddy} -c \"Add :uploadSymbols bool YES\" #{options_path}")
  system("#{PlistBuddy} -c \"Add :teamID string '#{teamid}'\" #{options_path}")

  return options_path
end

def adhoc_export_options(teamid, options_dir)
  options_path = File.expand_path(options_dir + "/" + AdHocExportOptions)

  system("#{PlistBuddy} -c \"Add :method string 'ad-hoc'\" #{options_path}")
  system("#{PlistBuddy} -c \"Add :compileBitcode bool NO\" #{options_path}")
  system("#{PlistBuddy} -c \"Add :teamID string '#{teamid}'\" #{options_path}")

  return options_path
end

def clean_export_options()
  if File.exist?(AppStoreExportOptions) then
    system("rm #{AppStoreExportOptions}")
  end

  if File.exist?(AdHocExportOptions) then
    system("rm #{AdHocExportOptions}")
  end
end
