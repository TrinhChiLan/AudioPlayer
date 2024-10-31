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

def processString(str)
  if str.length > 26 then
    str = str[0..25].chomp + ".."
  end
  return str
end

$albumButtons = [
  [25, 25], [275, 25], [25, 275], [275, 275]
]

#Main
class AudioPlay < Gosu::Window
  #
  def initialize
    super(500, 500)
    #1: Main menu, 2: Playing an album
    @currentState = 1
    @currentAlbum = nil
    @trackFont = Gosu::Font.new(20)
    #
    albumfile = File.new('Assets\album.txt', 'r') 
    @albums = read_albums(albumfile)
    albumfile.close()
    @currentAlbumIcon = nil
    #
    @page = 1
    @maxPage = @albums.length/4 + @albums.length%4
    puts "Max page: #{@maxPage}"
    #
    @currentTrack = nil
    @currentTrackIndex = nil
    @trackButtons = []
    @audioPaused = false
    #
    @homeIcon = Gosu::Image.new('Assets\Images\Icons\home.png')
    @playIcon = Gosu::Image.new('Assets\Images\Icons\play-button-arrowhead.png')
    @pauseIcon = Gosu::Image.new('Assets\Images\Icons\pause.png')
    @nextIcon = Gosu::Image.new('Assets\Images\Icons\next.png')
    @previousIcon = Gosu::Image.new('Assets\Images\Icons\previous.png')
  end
  #
  def needs_cursor?; true; end
  def playIndexedTrack()
    albumTracks = @albums[@currentAlbum].tracks
    puts "Playing track with index #{@currentTrackIndex} - #{albumTracks[@currentTrackIndex].name}"
    @currentTrack = Gosu::Song.new(albumTracks[@currentTrackIndex].location)
    @currentTrack.play
  end
  #
  def getButtonClicked()
    if @currentState == 1 then
      for i in (4*(@page - 1))..[3 + (4*(@page - 1)), @albums.length - 1].min do
        aButtonIndex = i - 4*(@page - 1) #aButtonIndex stands for Album Buttons index, since it only ranges from 1-4 we need to deduct from the actual index.
        if (mouse_x > $albumButtons[aButtonIndex][0] and mouse_x < $albumButtons[aButtonIndex][0] + 200) and (mouse_y > $albumButtons[aButtonIndex][1] and mouse_y < $albumButtons[aButtonIndex][1] + 200) then
          if @playingBack then return end
          @playingBack = true
          @currentAlbum = i
          @currentAlbumIcon = Gosu::Image.new(@albums[@currentAlbum].albumicon)
          @currentState = 2
          @currentTrackIndex = 0
          playIndexedTrack()
          #Generate track buttons
          albumTracks = @albums[@currentAlbum].tracks
          buttonX = 25
          buttonY = 310
          for i in 0..[15, albumTracks.length - 1].min do
            @trackButtons[i] = [buttonX, buttonY, @trackFont.text_width(processString(albumTracks[i].name))]
            if i%2 == 0 then buttonX += 225 else buttonX -= 225; buttonY += 20 end
          end
        end
      end
    elsif @currentState == 2 then
      #Check for track buttons
      albumTracks = @albums[@currentAlbum].tracks
      for i in 0..[15, albumTracks.length - 1].min do
        if (mouse_x > @trackButtons[i][0] and mouse_x < @trackButtons[i][0] + @trackButtons[i][2]) and (mouse_y > @trackButtons[i][1] and mouse_y < @trackButtons[i][1] + 20) then
          @currentTrack.stop
          @currentTrackIndex = i
          if @audioPaused then @currentTrack = Gosu::Song.new(albumTracks[@currentTrackIndex].location) else playIndexedTrack() end
        end
      end
      #Check for utility buttons
      #Pause and unpause
      if (mouse_x > 240 and mouse_x < 260) and (mouse_y > 280 and mouse_y < 300) then
        if @audioPaused then
          @audioPaused = false
          @currentTrack.play
        else
          @audioPaused = true
          @currentTrack.pause
        end
      end
      #Home button
      if (mouse_x > 5 and mouse_x < 25) and (mouse_y > 5 and mouse_y < 25) then
        @playingBack = false
        @currentAlbum = nil
        @currentState = 1
        @currentTrackIndex = nil
        @audioPaused = false
        @trackButtons = []
        if @currentTrack then @currentTrack.stop end
        @currentTrack = nil
      end
      #Next and previous button
      if (mouse_x > 270 and mouse_x < 290) and (mouse_y > 280 and mouse_y < 300) then #Next
        @currentTrack.stop
        @currentTrackIndex += 1
        if @currentTrackIndex > albumTracks.length - 1 then @currentTrackIndex = 0 end
        if @audioPaused then @currentTrack = Gosu::Song.new(albumTracks[@currentTrackIndex].location) else playIndexedTrack() end
      elsif (mouse_x > 210 and mouse_x < 230) and (mouse_y > 280 and mouse_y < 300) then #Previous
        @currentTrack.stop
        @currentTrackIndex -= 1
        if @currentTrackIndex < 0 then @currentTrackIndex = albumTracks.length - 1 end
        if @audioPaused then @currentTrack = Gosu::Song.new(albumTracks[@currentTrackIndex].location) else playIndexedTrack() end
      end
    end
    return nil
  end
  #
  def update()
    if @currentTrack and @playingBack then
      if !@audioPaused and !@currentTrack.playing? then
        albumTracks = @albums[@currentAlbum].tracks
        @currentTrackIndex += 1
        if @currentTrackIndex > albumTracks.length - 1 then @currentTrackIndex = 0 end
        playIndexedTrack()
      end
    end
  end
  #
  def draw()
    if @currentState == 1 then
      #Drawing the page shift buttons
      @trackFont.draw_text(@page.to_s, 245, 5, 0)
      # @nextIcon.draw(480, 250, 0, 20.0/@nextIcon.width, 20.0/@nextIcon.height)
      # @previousIcon.draw(0, 250, 0, 20.0/@previousIcon.width, 20.0/@previousIcon.height)
      #Drawing the album buttons
      for i in (4*(@page - 1))..[3 + (4*(@page - 1)), @albums.length - 1].min do 
        if !@albums[i] then next end
        aButtonIndex = i - 4*(@page - 1) 
        iconpath = @albums[i].albumicon
        albumicon = Gosu::Image.new(iconpath)
        scaleX = 200.0/albumicon.width
        scaleY = 200.0/albumicon.height
        albumicon.draw($albumButtons[aButtonIndex][0], $albumButtons[aButtonIndex][1], 0, scaleX, scaleY)
        #Album name
        displayText = @albums[i].title + ' - ' + @albums[i].artist
        posX = $albumButtons[aButtonIndex][0] + 100 - @trackFont.text_width(displayText)/2.0
        posY = $albumButtons[aButtonIndex][1] == 275 ? 475 : 225
        #Check if mouse is on any of the button
        hovering = false
        if (mouse_x > $albumButtons[aButtonIndex][0] and mouse_x < $albumButtons[aButtonIndex][0] + 200) and (mouse_y > $albumButtons[aButtonIndex][1] and mouse_y < $albumButtons[aButtonIndex][1] + 200) then
          rectX = $albumButtons[aButtonIndex][0] - 10 #(+100 - 110)
          rectY = $albumButtons[aButtonIndex][1] - 10
          Gosu.draw_rect(rectX, rectY, 220, 240, Gosu::Color::WHITE, -1)
          hovering = true
        end
        if hovering then
          @trackFont.draw_text(displayText, posX, posY, 0, 1, 1, Gosu::Color::BLACK)
        else
          @trackFont.draw_text(displayText, posX, posY, 0, 1, 1, Gosu::Color::WHITE)
        end
      end  
    elsif @currentState == 2 then
      albumTracks = @albums[@currentAlbum].tracks
      #Drawing utility buttons
      @homeIcon.draw(5, 5, 0, 20.0/@homeIcon.width, 20.0/@homeIcon.height)
      @nextIcon.draw(270, 280, 0, 20.0/@nextIcon.width, 20.0/@nextIcon.height)
      @previousIcon.draw(210, 280, 0, 20.0/@previousIcon.width, 20.0/@previousIcon.height)
      if !@audioPaused then
        @pauseIcon.draw(240, 280, 0, 20.0/@pauseIcon.width, 20.0/@pauseIcon.height)
        displayText = "#{albumTracks[@currentTrackIndex].name}"
        posX = 250 - @trackFont.text_width(displayText)/2
        @trackFont.draw_text(displayText, posX, 260, 0)
      else
        @playIcon.draw(240, 280, 0, 20.0/@playIcon.width, 20.0/@playIcon.height)
        displayText = "Paused - #{albumTracks[@currentTrackIndex].name}"
        posX = 250 - @trackFont.text_width(displayText)/2
        @trackFont.draw_text(displayText, posX, 260, 0)
      end
      #Drawing track buttons
      @currentAlbumIcon.draw(125, 5, 0, 250.0/@currentAlbumIcon.width, 250.0/@currentAlbumIcon.height)
      for i in 0..@trackButtons.length - 1 do
        buttonX = @trackButtons[i][0]
        buttonY = @trackButtons[i][1]
        @trackFont.draw_text(processString(albumTracks[i].name), buttonX, buttonY, 0)
      end
      #Mark the current track that is being indexed.
      Gosu.draw_rect(@trackButtons[@currentTrackIndex][0] - 10, @trackButtons[@currentTrackIndex][1] + 5, 5, 5, Gosu::Color::RED)
    end
  end
  #
  def button_down(id)
    if id == Gosu::MsLeft then
      getButtonClicked()
    elsif id == Gosu::KbEscape then
      exit
    elsif id == Gosu::KbLeft
      if @page > 1 then @page -= 1 end
    elsif id == Gosu::KbRight
      if @page < @maxPage then @page += 1 end
    end
    
  end
end

AudioPlay.new.show