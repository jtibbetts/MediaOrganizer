
ENV["RAILS_ENV"] = "development"
require File.expand_path('../../config/environment', __FILE__)

require 'itunes/library'

# registry = Registry.new
#
# itunes_library_location = registry['itunes_library_location']
# target_folder = registry['target_folder']

# itunes_library_location = '/Users/johntibbetts/Music/iTunes/iTunes Music Library.xml'
# target_folder = '/Users/johntibbetts/tt/music'

if ARGV.size != 2
  puts "usage: organize_music <itunes_library_filename> <target_folder>"
  exit
end


itunes_library_location = ARGV[0]
target_folder = ARGV[1]

library = ITunes::Library.load(itunes_library_location)

def copy_file_if_not_exists(source, target)
  unless File.exists?(source)
    puts "Error: Source file #{source} doesn't exist"
    return
  end

  if File.exists?(target)
    puts "Warning: Target file #{target} already exists"
    return
  end

  #puts "Copying file"
  FileUtils.copy(source, target)
end

library.playlists.each do |playlist|
  playlist_name = playlist.name
  if playlist_name.include? '::'
    playlist_db_obj = Playlist.where(:name => playlist_name).first
    if playlist_db_obj.blank?
      playlist_db_obj = Playlist.new
      playlist_db_obj.name = playlist_name
      playlist_db_obj.is_download = true
      playlist_db_obj.save

      puts "New playlist added: #{playlist_name}"
    end

    # no process playlist
    if playlist_db_obj.is_download
      puts "Processing: #{playlist_name}"
      zones = playlist_name.split('::')
      path = File.join(zones)
      path = path.gsub(/\s+/, '_')

      full_folder_path = File.join(target_folder, path)
      FileUtils.mkdir_p full_folder_path

      item_namer = {}
      track_offset = 0
      playlist.tracks.each do |track|
        source_location = track['Location']
        source_fullpath = URI.unescape(URI.parse(source_location).path)
        name = track.name
        name = name.gsub(/\s+/, '_')
        name = name.gsub(/\s*-\s*/, '_')    # intervening ' - '
        name = name.gsub(/\//, '_')
        name = name.gsub(/\\/, '_')
        name = name.gsub(/\?/, '_')
        name = name.gsub(/:/, '_')
        name = name.gsub(/"/, '_')
        name = name.gsub(/_+/, '_')

        # generate a final_name to ensure uniqueness
        unless item_namer.has_key? name
          final_name = name
        else
          last_name_used = item_namer[name]
          m = /.*\[(\d+)\]$/.match last_name_used
          if m.present?
            name_digit = m[1].to_i
            name_digit += 1
          else
            name_digit = 1
          end
          final_name = "#{name}[#{name_digit}]"
        end
        item_namer[name] = final_name
        target_fullpath = File.join(full_folder_path, "#{'%03i' % track_offset}-#{final_name + File.extname(source_fullpath)}")

        copy_file_if_not_exists(source_fullpath, target_fullpath)

        puts "target_fullpath: #{target_fullpath}"
        track_offset += 1
      end
    end
  end
end

