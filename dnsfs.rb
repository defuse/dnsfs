
require 'optparse'
require 'base64'
require 'resolv'

$options = {}

optparse = OptionParser.new do |opts|
  opts.banner = "Usage: --generate <folder>\n" + 
                "       --download <domain>\n\n"

  $options[:mode] = nil

  opts.on('-g', '--generate', 'Generate DNS entries') do 
    if $options[:mode]
      STDERR.puts "Choose either --generate OR --download."
      STDERR.puts opts
      exit
    else 
      $options[:mode] = :generate
    end
  end

  opts.on('-d', '--download', 'List files and download') do 
    if $options[:mode]
      STDERR.puts "Choose either --generate OR --download."
      STDERR.puts opts
      exit
    else 
      $options[:mode] = :download
    end
  end

  $options[:nameserver] = nil
  opts.on('-n', '--nameserver NS', 'Nameserver to use for downloading') do |ns|
    $options[:nameserver] = ns
  end

  $options[:subdomain] = "dnsfs"
  opts.on('-s', '--subdomain SUB', 'Filesystem subdomain') do |sub|
    $options[:subdomain] = sub
  end

end

begin
  optparse.parse!
rescue OptionParser::InvalidOption
  STDERR.puts "Invalid option"
  STDERR.puts optparse
  exit
end

if $options[:mode].nil?
  STDERR.puts "Choose either --generate OR --download."
  STDERR.puts optparse
  exit
end

if ARGV.length != 1
  if $options[:mode] == :generate
    STDERR.puts "Please specify a source folder."
  else
    STDERR.puts "Please specify a domain name."
  end
  STDERR.puts optparse
  exit
end

def generateEntries(source_dir)
  file_number = 1
  Dir.foreach(source_dir) do |item|
    next if item == '.' or item == '..'
    path = File.join(source_dir, item)
    if generateEntriesForFile(file_number, path)
      file_number += 1
    end
  end
  puts "f#{file_number}info.#{$options[:subdomain]} IN TXT \"~EOL~\""
end

def generateEntriesForFile(n, path)
  size = File.size(path)
  if size > 10 * 1024 * 1024
    STDERR.puts "Skipping #{path}, it's too big."
    return false;
  end

  name = File.basename(path)

  # Directory entry
  puts "f#{n}info.#{$options[:subdomain]} IN TXT \"Name: #{name} / Size: #{size}\""

  part = 1
  part_size = 189
  File.open(path, 'r') do |f|
    while part_contents = f.read(part_size)
      # We use encode64 instead of strict_encode64 for backwards compatibility.
      part_base64 = Base64.encode64(part_contents).gsub("\n",'')
      puts "f#{n}p#{part}.#{$options[:subdomain]} IN TXT \"#{part_base64}\""
      part += 1
    end
  end

  puts "f#{n}p#{part}.#{$options[:subdomain]} IN TXT \"~EOF~\""

  return true;
end

# Replaces dangerous characters in 'filename' with 'X'.
def safe_encode_path(filename)
  # Everything except control characters and /, {, \, ?, >, <, :, *, !
  # Source: urlchr_table in the wget source code.
  safe_chars = ('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ' +
               '0123456789' +
               '`~@#$%^&()_+-=[]}|;\'",.').split('')

  if filename == "."
    return "X"
  elsif filename == ".."
    return "XX"
  else
    safe_filename = ''
    filename.each_char do |char|
      if safe_chars.include? char
        safe_filename += char
      else
        safe_filename += "X"
      end
    end

    # Actual limits are probably bigger than this, but Ruby doesn't make it easy
    # to figure out what they are, so let's be safe.
    if safe_filename.length > 100
      return safe_filename[0,100]
    else
      return safe_filename
    end
  end
end

def interactiveDownload(domain)
  file_info = interactiveSelectFile(domain)
  return if file_info.nil?

  # The filename can be any string, need to make it safe.
  dest_path = safe_encode_path(file_info[:name])
  # Just in case the encoding is broken/insecure.
  dest_path = File.basename(dest_path)

  File.open(dest_path, File::CREAT|File::EXCL|File::WRONLY, 0600) do |f|
    part = 1
    while part_data = getFilePart(domain, file_info[:number], part)
      print "."
      STDOUT.flush
      f.write(part_data)
      part += 1
    end
    puts ""
  end

  puts "File written to #{dest_path}."

rescue Errno::EEXIST
    puts "ERROR: File already exists in #{dest_path}.\n"
end

def interactiveSelectFile(domain)
  files = []
  file_number = 1
  while file_info = getFileInfo(domain, file_number)
    files << file_info
    file_number += 1
  end

  if files.empty?
    puts "No files there."
    return nil
  else
    files.each_with_index do |file, index|
      puts "#{index+1}. #{file[:name]} (size: #{file[:size]} bytes)"
    end

    puts "Which one? (it will be saved to the current working directory)"
    index = STDIN.gets.strip.to_i
    if index < 1 || index > files.count
      puts "Bad selection."
      return nil
    end
    return files[index-1]
  end
end

def getFileInfo(domain, file_number)
  dns = getResolver()
  info = dns.getresource("f#{file_number}info." + domain, Resolv::DNS::Resource::IN::TXT)
  info = info.data()
  file = {}
  file[:number] = file_number
  if info == "~EOL~"
    return nil
  end
  if /Name: (.+) \/ Size: (\d+)/.match(info)
    file[:name] = $1
    file[:size] = $2.to_i
  else
    return nil
  end
  return file
rescue Resolv::ResolvError
  return nil
end

def getFilePart(domain, file_number, part_number)
  dns = getResolver()
  info = dns.getresource("f#{file_number}p#{part_number}." + domain, Resolv::DNS::Resource::IN::TXT)
  info = info.data()
  if info == "~EOF~"
    return nil
  else
    return Base64.decode64(info)
  end
rescue Resolv::ResolvError
  # FIXME: should expect a random error once in a while... maybe retry?
  return nil
end

def getResolver
  if $options[:nameserver]
    return Resolv::DNS.new(:nameserver => $options[:nameserver])
  else
    return Resolv::DNS.new()
  end
end

if $options[:mode] == :generate
  generateEntries(ARGV[0])
elsif $options[:mode] == :download
  interactiveDownload(ARGV[0])
end
