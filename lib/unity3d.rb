# encoding: utf-8

require 'yaml'

def product_name(unity3d_project)
  project_settings_path = unity3d_project + "/ProjectSettings/ProjectSettings.asset"
  project_settings = YAML.load_file(project_settings_path)
  return project_settings["PlayerSettings"]["productName"]
end

def xcode_project(unity3d_project)
  return unity3d_project + "/Build/iOS"
end

def build_dir(unity3d_project)
  return unity3d_project + "/Build"
end

def unity3d(unity3d, project, platform, type)
  log "Unity3d build begin"

  run "\"#{unity3d}\" \
    -batchmode \
    -quit \
    -projectPath \"#{project}\" \
    -buildTarget #{platform} \
    -logFile $stdout \
    -executeMethod Infinity.Build.BuildPlayer#{type.to_s.capitalize}"

  log "Unity3d build end"
end
