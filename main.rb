require 'rubygems'
require 'rails'

START_DIRECTORY="/home/terry/Music"

def filename_without_unnecessary_dash(f)
    filename=f.split('/').last
    if filename.match(/^([0-9]*? )- /)
      f.gsub(Regexp.new(filename),filename.gsub(/^([0-9]*? )- /,$1))
    else
      f
    end
end

def has_unnecessary_dash?(f)
  test=filename_without_unnecessary_dash(f)
  f!=test
end

def parse_directory(d=nil)
  puts "Processing #{d.path}"
  files=[]
  folders=[]
  if d
    entries=d.entries-['.','..']


    if entries.any?
      entries.each do |entry|
        full_filename=[d.path,entry].join('/')
        if File.directory?(full_filename)
          folders<<Dir.new(full_filename)
        else
          files<<full_filename
        end
      end
    end

    if files.any?

      #get the files without extensions
      files_without_extensions=files.select{|f| File.extname(f).blank?}

      #get the files with extensions
      files_with_extensions=files-files_without_extensions

      #get the files with extensions and unnecessary dashes
      if files_with_extensions.any?
        files_with_unnecessary_dashes=files_with_extensions.select{|f| has_unnecessary_dash?(f)}
        files_without_unnecessary_dashes=files_with_extensions-files_with_unnecessary_dashes
      else
        files_with_unnecessary_dashes=[]
        files_without_unnecessary_dashes=[]
      end

      #delete any that match one with an extension
      if files_without_extensions.any? and files_with_extensions.any?
        files_without_extensions.each do |fwoe|
          matching_with_extension=files_with_extensions.select{|fwe| fwe.split('.').first==fwoe}
          if matching_with_extension.any?
            puts "Deleting #{fwoe}"
            File.unlink(fwoe)
          end
        end
      end

      if files_with_unnecessary_dashes.any? and files_without_unnecessary_dashes.any?
        files_with_unnecessary_dashes.each do |fwud|
          matching=files_without_unnecessary_dashes.select{|fwoud| fwoud==filename_without_unnecessary_dash(fwud)}
          if matching.any?
            puts "Deleting #{fwud}"
            File.unlink(fwud)
          end
        end
      end


    end

    if folders.any?
      folders.each{|f| parse_directory(f)}
    end

  end

end

top=Dir.open(START_DIRECTORY)
parse_directory(top)
puts "Finished"


