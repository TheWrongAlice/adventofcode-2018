#!/usr/bin/env ruby

# --- Day 3: No Matter How You Slice It ---
# The Elves managed to locate the chimney-squeeze prototype fabric for Santa's suit (thanks to someone who helpfully wrote its box IDs on the wall of the warehouse in the middle of the night). Unfortunately, anomalies are still affecting them - nobody can even agree on how to cut the fabric.
#
# The whole piece of fabric they're working on is a very large square - at least 1000 inches on each side.
#
# Each Elf has made a claim about which area of fabric would be ideal for Santa's suit. All claims have an ID and consist of a single rectangle with edges parallel to the edges of the fabric. Each claim's rectangle is defined as follows:
#
# The number of inches between the left edge of the fabric and the left edge of the rectangle.
# The number of inches between the top edge of the fabric and the top edge of the rectangle.
# The width of the rectangle in inches.
# The height of the rectangle in inches.
# A claim like #123 @ 3,2: 5x4 means that claim ID 123 specifies a rectangle 3 inches from the left edge, 2 inches from the top edge, 5 inches wide, and 4 inches tall. Visually, it claims the square inches of fabric represented by # (and ignores the square inches of fabric represented by .) in the diagram below:
#
# ...........
# ...........
# ...#####...
# ...#####...
# ...#####...
# ...#####...
# ...........
# ...........
# ...........
# The problem is that many of the claims overlap, causing two or more claims to cover part of the same areas. For example, consider the following claims:
#
# #1 @ 1,3: 4x4
# #2 @ 3,1: 4x4
# #3 @ 5,5: 2x2
# Visually, these claim the following areas:
#
# ........
# ...2222.
# ...2222.
# .11XX22.
# .11XX22.
# .111133.
# .111133.
# ........
# The four square inches marked with X are claimed by both 1 and 2. (Claim 3, while adjacent to the others, does not overlap either of them.)
#
# If the Elves all proceed with their own plans, none of them will have enough fabric. How many square inches of fabric are within two or more claims?

class String
  def between(a, b)
    self.split(a)[1].split(b)[0]
  end
end

class Coordinates
  attr_accessor :x
  attr_accessor :y

  def initialize(x, y)
    self.x = x
    self.y = y
  end
end

class AreaClaim
  attr_accessor :raw
  attr_accessor :id
  attr_accessor :left
  attr_accessor :top
  attr_accessor :width
  attr_accessor :height

  def initialize(raw)
    self.raw = raw
    self.id = raw.between('#', ' ').to_i
    self.left = raw.between('@ ', ',').to_i
    self.top = raw.between(',', ':').to_i
    self.width = raw.between(': ', 'x').to_i
    self.height = raw.between('x', '\n').to_i
  end

  def covered_tiles
    list = []
    x = left
    y = top
    width.times do |width_index|
      height.times do |height_index|
        list << Coordinates.new(x + width_index, y + height_index)
      end
    end
    return list
  end
end

class Tile
  attr_accessor :coordinates
  attr_accessor :claims

  def initialize(x, y)
    self.coordinates = Coordinates.new(x, y)
    self.claims = []
  end
  def claim!(claim)
    claims << claim
  end
  def conflict?
    claims.length > 1
  end
end

class Fabric
  attr_accessor :grid

  def initialize(width, height)
    self.grid = []
    width.times do |x|
      self.grid[x] = []
      height.times do |y|
        self.grid[x][y] = Tile.new(x, y)
      end
    end
  end

  def tiles_with_conflicts
    list = []
    grid.each do |row|
      row.each do |tile|
        list << tile if tile.conflict?
      end
    end
    return list
  end
end



# Setup
fabric = Fabric.new(1000, 1000)
area_claims = []

# Parse text file and create claims
input = File.readlines('input.txt')
input.each do |line|
  area_claims << AreaClaim.new(line)
end

# Register claims on the fabric grid
area_claims.each do |area_claim|
  area_claim.covered_tiles.each do |tile_claim|
    tile = fabric.grid[tile_claim.x][tile_claim.y]
    tile.claim!(area_claim)
  end
end

# Return
puts fabric.tiles_with_conflicts.length
