$genre_names = ['Null', 'Pop', 'Classic', 'Jazz', 'Rock']

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
#
require 'gosu'

class SVector2
  attr_accessor :x, :y
  def initialize(x, y)
    @x = x 
    @y = y 
  end
end

class UIObject
  attr_accessor :size, :position, :anchorPoint, :zIndex
  def initialize(initSize, initAPoint, zIndex)
    @size = initSize ? SVector2.new(initSize[0], initSize[1]) : SVector2.new(100, 100)
    #@position = initPos ? SVector2.new(initPos[0], initPos[1]) : SVector2.new(0, 0)
    @anchorPoint = initAPoint ? SVector2.new(initAPoint[0].clamp(0, 1), initAPoint[1].clamp(0, 1)) : SVector2.new(0, 0)
    @zIndex = zIndex || 1
  end
  def isWithinBoundaries(x, y)
    #return (x > @position.x and x < @position.x + @size.x) and (y > @position.y and y < @position.y + @size.y)
  end
end

class TextLabel < UIObject
  attr_accessor :text, :textWidth, :font 
end

class ImageLabel < UIObject
  attr_accessor :image, :scale
  def initialize(location, initScale, initAPoint, zIndex)
    @image = Gosu::Image.new(location)
    super [@image.width * initScale[0].clamp(0, 1), @image.height * initScale[1].clamp(0, 1)], initAPoint, zIndex
    @scale = initScale ? SVector2.new(initScale[0].clamp(0, 1), initScale[1].clamp(0, 1)) : SVector2.new(1, 1)
  end
  def render(x, y)
    posX = x - @size.x*@anchorPoint.x 
    posY = y  - @size.y*@anchorPoint.y 
    @image.draw(posX, posY, @size.x, @size.y, @zIndex, @scale.x, @scale.y)
  end
end

class Frame < UIObject #Rectangular objects
  attr_accessor :color
  def initialize(initSize, initAPoint, zIndex, color)
    super initSize, initAPoint, zIndex
    @color = color.is_a?(Gosu::Color) and color || Gosu::Color::WHITE
  end
  def render(x, y)
    posX = x - @size.x*@anchorPoint.x 
    posY = y  - @size.y*@anchorPoint.y 
    Gosu.draw_rect(posX, posY, @size.x, @size.y, @color, @zIndex)
  end
end

