# encoding: utf-8

def clean_dir(dir)
  if Dir.exist?(dir) then
    run ("rm -rf #{dir}")
  end
end

def clean(build_dir)
  log "Clean begin"
  clean_dir(build_dir)
  log "Clean end"
end
