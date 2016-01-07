# encoding: utf-8

def run(command)
  puts "Run: " + command
  system command
end

def log(content)
  puts "Log: " + content
end

def error(content)
  puts "Error: " + content
end
