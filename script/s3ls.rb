#!/usr/bin/env ruby

app_root = File.expand_path("../..", __FILE__)
require "#{app_root}/app/classes/image_s3.rb"
require "fileutils"

abort(<<"EOB") if ARGV.any? { |arg| arg == "-h" || arg == "--help" }

  USAGE::

    script/s3ls.rb server [--replace]

  DESCRIPTION::

    Gets a list of files on the given S3 server.
    NOTE: This takes *forever* and should only be run sparingly!!

  PARAMETERS::

    server     Primary key in MO.s3_credentials configuration hash.
    --replace  Completely replace old file.  Default behavior is to keep
               entries from old file where the new listing omits them.
               This makes it much more robust, since the S3 server will
               often skip entire segments of files.
    --verbose  Print what's happening to stdout.
    --help     Print this message.

EOB

verbose = true if ARGV.any? { |arg| arg == "-v" || arg == "--verbose" }
replace = true if ARGV.any? { |arg| arg == "-r" || arg == "--replace" }
flags = ARGV.select { |arg| arg.match(/^-/) }.
        reject { |arg| arg.match(/^(-v|-r|--verbose|--replace)$/) }
words = ARGV.reject { |arg| arg.match(/^-/) }
abort("Bad flag(s): #{flags.inspect}") if flags.length > 0
abort("Missing server!") if words.length == 0
server = words.shift
abort("Unexpected parameter(s): #{words.inspect}") if words.length > 0

cache_file = "#{app_root}/public/images/#{server}.files"
temp_file1 = "#{app_root}/tmp/#{server}.files.#{Process.pid}.1"
temp_file2 = "#{app_root}/tmp/#{server}.files.#{Process.pid}.2"

# Hacky way to grab MO.s3_credentials from config files using script/config.rb.
cmd = File.expand_path("../../script/config.rb", __FILE__)
url               = `#{cmd} MO.s3_credentials[:#{server}][:server]`
bucket            = `#{cmd} MO.s3_credentials[:#{server}][:bucket]`
access_key_id     = `#{cmd} MO.s3_credentials[:#{server}][:access_key_id]`
secret_access_key = `#{cmd} MO.s3_credentials[:#{server}][:secret_access_key]`
abort("Bad server: #{server.inspect}") unless url

def log(msg)
  $stdout.write(msg)
  $stdout.flush
end

begin
  log("Connecting...\r") if verbose
  s3 = ImageS3.new(
    server: url,
    bucket: bucket,
    access_key_id: access_key_id,
    secret_access_key: secret_access_key
  )
rescue => e
  abort("Failed: couldn't connect: #{e}")
end

if replace
  FileUtils.rm(cache_file)
  FileUtils.touch(cache_file)
else
  FileUtils.touch(cache_file)
  FileUtils.mv(cache_file, temp_file1)
  FileUtils.touch(cache_file)
end

num = 0
sum = 0
File.open(cache_file, "a") do |fh|
  s3.list.each do |obj|
    key  = obj.key
    size = obj.size
    md5  = obj.etag.gsub(/^"|"$/, "")
    num += 1
    sum += size
    fh.puts [key, size, md5].join("\t")
    log("#{sum} bytes in #{num} files...\r") if verbose
  end
end
log("#{sum} bytes in #{num} files\n") if verbose

unless replace
  FileUtils.mv(cache_file, temp_file2)
  FileUtils.touch(cache_file)
  system("cat #{temp_file1} #{temp_file2} | #{app_root}/script/s3uniq.rb >> #{cache_file}")
  FileUtils.rm(temp_file1)
  FileUtils.rm(temp_file2)
end

exit 0
