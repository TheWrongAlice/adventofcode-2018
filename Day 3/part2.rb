#!/usr/bin/env ruby

# --- Part Two ---
# Amidst the chaos, you notice that exactly one claim doesn't overlap by even a single square inch of fabric with any other claim. If you can somehow draw attention to it, maybe the Elves will be able to make Santa's suit after all!
#
# For example, in the claims above, only claim 3 is intact after all claims are made.
#
# What is the ID of the only claim that doesn't overlap?

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

# Go through claims again to find the only non-conflicting claim
area_claims.each do |area_claim|
  conflict_found = false
  area_claim.covered_tiles.each do |tile_claim|
    tile = fabric.grid[tile_claim.x][tile_claim.y]
    if tile.conflict?
      conflict_found = true
      break
    end
  end

  if conflict_found == false
    puts area_claim.id
    exit
  end
end
