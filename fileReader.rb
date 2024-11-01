require './classes.rb'

def read_track(music_file)
  track = Track.new(music_file.gets, music_file.gets.chomp)
  return track
end

def read_tracks(music_file)
  count = music_file.gets().to_i()
  tracks = Array.new()
  # Put a while loop here which increments an index to read the tracks
  index = 0
  while index < count 
    track = read_track(music_file)
    tracks << track
    index += 1
  end
  return tracks
end

def read_albums(music_file)
  count = music_file.gets().to_i()
  albums = Array.new()
  # read in all the Album's fields/attributes including all the tracks
  index = 0
  while index < count
    album_artist = music_file.gets.chomp
    album_title = music_file.gets.chomp
    album_year = music_file.gets()
    album_genre = music_file.gets()
    album_icon = music_file.gets.chomp
    tracks = read_tracks(music_file)
    album = Album.new(album_title, album_artist, album_genre, album_icon, tracks)
    albums << album
    index += 1
  end
  return albums
end
#Debuggin functions
def print_track(track)
	puts(track.name)
	#puts(track.location)
end

def print_tracks(tracks)
	index = 0
	while index < tracks.length
		print_track(tracks[index])
		index += 1
	end
end

def print_album(album)
  puts(album.title)
	puts(album.artist)
	puts('Genre is ' + album.genre.to_s)
	puts($genre_names[album.genre.to_i])
	print_tracks(album.tracks)
end

def print_albums(albums)
  index = 0
  while index < albums.length
    print_album(albums[index])
    index += 1
  end
end