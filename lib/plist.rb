# encoding: utf-8

PlistBuddy = "/usr/libexec/PlistBuddy"
AppStoreExportOptions = "AppStoreExportOptions.plist"
AdHocExportOptions = "AdHocExportOptions.plist"

def appstore_export_options(teamid, options_dir)
  options_path = File.expand_path(options_dir + "/" + AppStoreExportOptions)

  run("#{PlistBuddy} -c \"Add :method string 'app-store'\" #{options_path}")
  run("#{PlistBuddy} -c \"Add :uploadBitcode bool NO\" #{options_path}")
  run("#{PlistBuddy} -c \"Add :uploadSymbols bool YES\" #{options_path}")
  run("#{PlistBuddy} -c \"Add :teamID string '#{teamid}'\" #{options_path}")

  return options_path
end

def adhoc_export_options(teamid, options_dir)
  options_path = File.expand_path(options_dir + "/" + AdHocExportOptions)

  run("#{PlistBuddy} -c \"Add :method string 'ad-hoc'\" #{options_path}")
  run("#{PlistBuddy} -c \"Add :compileBitcode bool NO\" #{options_path}")
  run("#{PlistBuddy} -c \"Add :teamID string '#{teamid}'\" #{options_path}")

  return options_path
end

def clean_export_options(options_path)
  if File.exist?(options_path) then
    run("rm #{options_path}")
  end
end
