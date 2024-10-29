require 'gosu'

$genre_names = ['Null', 'Pop', 'Classic', 'Jazz', 'Rock']

#Classes
class Album
    attr_accessor :title, :artist, :genre, :albumicon, :tracks
    def initialize (title, artist, genre, icon, tracks)
      @title = title
      @artist = artist
      @genre = genre
      @albumicon = icon
      @tracks = tracks
    end
end

class Track
	attr_accessor :name, :location

	def initialize (name, location)
		@name = name
		@location = location
	end
end

#Essential functions
def read_track(music_file)
	  track = Track.new(music_file.gets, music_file.gets)
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
    album_artist = music_file.gets()
    album_title = music_file.gets()
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

$albumButtons = [
  [25, 25], [250, 25], [25, 250], [250, 250]
]

$buttons = [
  [50, 50, Gosu::Color::GREEN, 'Better Off Alone', 'Assets\Audios\Combat Initiation\Better Off Alone.mp3'],
  [250, 50, Gosu::Color::RED, 'Cursed Abbey', 'Assets\Audios\Combat Initiation\Cursed Abbey.mp3'],
  [50, 250, Gosu::Color::BLUE, 'Delicate Glass in Ice', 'Assets\Audios\Combat Initiation\Delicate Glass in Ice.mp3'],
  [250, 250, Gosu::Color::YELLOW, 'Darkness Dueling', 'Assets\Audios\Combat Initiation\Darkness Dueling.mp3']
]

#Main
class AudioPlay < Gosu::Window
  #
  def initialize
    super(500, 500)
    #1: Main menu, 2: Playing an album
    @currentState = 1
    @currentAlbum = nil
    @stateFont = Gosu::Font.new(20)
    @audio = nil
    #
    albumfile = File.new('Assets\album.txt', 'r') 
    @albums = read_albums(albumfile)
    albumfile.close()
  end
  #
  def needs_cursor?; true; end
  #Behaviour of this function: If user press a button, a song will play.
  def playAudio(path)
    if @audio != nil then
      @audio.stop
    end
    if path != nil then
      @audio = Gosu::Song.new(path)
      @audio.play
    end
  end
  def getButtonHovering()
    if @currentState == 1 then
      for i in 0..[3, @albums.length - 1].min do
        if (mouse_x > $albumButtons[i][0] and mouse_x < $albumButtons[i][0] + 200) and (mouse_y > $albumButtons[i][1] and mouse_y < $albumButtons[i][1] + 200) then
          return i
        end
      end
    end
    return nil
  end
  #
  def draw()
    if @currentState == 1 then
      for i in 0..[3, @albums.length - 1].min do 
        iconpath = @albums[i].albumicon
        albumicon = Gosu::Image.new(iconpath)
        scaleX = 200.0/albumicon.width
        scaleY = 200.0/albumicon.height
        albumicon.draw($albumButtons[i][0], $albumButtons[i][1], 0, scaleX, scaleY)
      end  
    else
      currentAlbumIcon = Gosu::Image.new(@albums[@currentAlbum].albumicon)
      currentAlbumIcon.draw(25, 100, 0, 250.0/currentAlbumIcon.width, 250.0/currentAlbumIcon.height)
    end
  end

  def button_down(id)
    unless getButtonHovering() then return end
    returninfo = getButtonHovering()
    if @currentState == 1 then
      @currentAlbum = returninfo
      @currentState = 2
      puts @currentAlbum, @currentState
    end
  end
end

AudioPlay.new.show