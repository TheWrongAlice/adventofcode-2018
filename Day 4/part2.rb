#!/usr/bin/env ruby

# --- Part Two ---
# Strategy 2: Of all guards, which guard is most frequently asleep on the same minute?
#
# In the example above, Guard #99 spent minute 45 asleep more than any other guard or minute - three times in total. (In all other cases, any guard spent any minute asleep at most twice.)
#
# What is the ID of the guard you chose multiplied by the minute you chose? (In the above example, the answer would be 99 * 45 = 4455.)


require 'date'
require 'time_difference'

class String
  def between(a, b)
    self.split(a)[1].split(b)[0]
  end
end

class ShiftMinute
  attr_accessor :datetime
  attr_accessor :guard_id
  attr_accessor :awake

  def self.all
    ObjectSpace.each_object(self).to_a
  end
  def self.with_guard_id(guard_id)
    all.select {|sm| sm.guard_id == guard_id }
  end
  def self.with_sleeping_guard
    all.select {|sm| sm.awake == false }
  end

  def initialize(datetime, guard_id, awake)
    self.datetime = datetime
    self.guard_id = guard_id
    self.awake = awake
  end
  def hour_and_minute
    datetime.strftime('%H:%M')
  end
end

class Guard
  attr_accessor :id
  attr_accessor :shift_minutes

  def self.all
    ObjectSpace.each_object(self).to_a
  end
  def self.by_id(id)
    all.find {|s| s.id == id }
  end

  def initialize(id)
    self.id = id
    self.shift_minutes = []
  end
  def minutes_slept
    ShiftMinute.with_guard_id(id).select{|m| m.awake == false}
  end
end

class Event
  attr_accessor :raw
  attr_accessor :type
  attr_accessor :datetime

  def self.all
    ObjectSpace.each_object(self).to_a
  end
  def self.by_time
    self.all.sort! { |a, b|  a.datetime <=> b.datetime }
  end

  def initialize(raw)
    self.raw = raw
    self.datetime = DateTime.parse(raw)
    if raw.include? 'Guard #'
      self.type = 'begins shift'
    elsif raw.include? 'falls asleep'
      self.type = 'falls asleep'
    elsif raw.include? 'wakes up'
      self.type = 'wakes up'
    end
  end
  def date
    datetime.to_date.to_s
  end
  def time
    datetime.strftime("%H:%M")
  end
  def guard_id
    return raw.between('Guard #', ' ') if type == 'begins shift'
    nil
  end

end


# Parse input and create events
events = []
input = File.readlines('input.txt')
input.each do |line|
  events << Event.new(line)
end

# Create Guards and Shiftminutes from Events
guards = []
current_guard = nil
period_start = nil
period_awake = nil
Event.by_time.each do |e|
  if period_start and current_guard
    period_length = TimeDifference.between(period_start, e.datetime).in_minutes.to_i
    puts "Guard #{'#' + current_guard.id} #{period_awake ? 'was awake' : 'slept'} for #{period_length} minutes starting at #{period_start}"

    # For each minute in the time period, create a ShiftMinute object for the guard
    period_length.times do |index|
      current_guard.shift_minutes << ShiftMinute.new(period_start + index.minutes, current_guard.id, period_awake)
    end
  end

  period_start = e.datetime
  if e.type == 'begins shift'
    period_awake = true
    current_guard = Guard.by_id(e.guard_id)
    if current_guard.nil?
      guards << Guard.new(e.guard_id)
      current_guard = guards.last
    end
  elsif e.type == 'falls asleep'
    period_awake = false
  elsif e.type == 'wakes up'
    period_awake = true
  end
end

# Determine most common combination of guard id and minute slept
combos = []
ShiftMinute.with_sleeping_guard.each do |sm|
  combos << "#{sm.guard_id}_#{sm.hour_and_minute}"
end
most_common_combo = combos.group_by(&:itself).values.max_by(&:size).first

# Return
puts most_common_combo
puts "Puzzle solution: #{most_common_combo.split('_')[0].to_i * most_common_combo.split(':')[1].to_i}"
