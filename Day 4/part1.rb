#!/usr/bin/env ruby

# --- Day 4: Repose Record ---
# You've sneaked into another supply closet - this time, it's across from the prototype suit manufacturing lab. You need to sneak inside and fix the issues with the suit, but there's a guard stationed outside the lab, so this is as close as you can safely get.
#
# As you search the closet for anything that might help, you discover that you're not the first person to want to sneak in. Covering the walls, someone has spent an hour starting every midnight for the past few months secretly observing this guard post! They've been writing down the ID of the one guard on duty that night - the Elves seem to have decided that one guard was enough for the overnight shift - as well as when they fall asleep or wake up while at their post (your puzzle input).
#
# For example, consider the following records, which have already been organized into chronological order:
#
# [1518-11-01 00:00] Guard #10 begins shift
# [1518-11-01 00:05] falls asleep
# [1518-11-01 00:25] wakes up
# [1518-11-01 00:30] falls asleep
# [1518-11-01 00:55] wakes up
# [1518-11-01 23:58] Guard #99 begins shift
# [1518-11-02 00:40] falls asleep
# [1518-11-02 00:50] wakes up
# [1518-11-03 00:05] Guard #10 begins shift
# [1518-11-03 00:24] falls asleep
# [1518-11-03 00:29] wakes up
# [1518-11-04 00:02] Guard #99 begins shift
# [1518-11-04 00:36] falls asleep
# [1518-11-04 00:46] wakes up
# [1518-11-05 00:03] Guard #99 begins shift
# [1518-11-05 00:45] falls asleep
# [1518-11-05 00:55] wakes up
# Timestamps are written using year-month-day hour:minute format. The guard falling asleep or waking up is always the one whose shift most recently started. Because all asleep/awake times are during the midnight hour (00:00 - 00:59), only the minute portion (00 - 59) is relevant for those events.
#
# Visually, these records show that the guards are asleep at these times:
#
# Date   ID   Minute
#             000000000011111111112222222222333333333344444444445555555555
#             012345678901234567890123456789012345678901234567890123456789
# 11-01  #10  .....####################.....#########################.....
# 11-02  #99  ........................................##########..........
# 11-03  #10  ........................#####...............................
# 11-04  #99  ....................................##########..............
# 11-05  #99  .............................................##########.....
# The columns are Date, which shows the month-day portion of the relevant day; ID, which shows the guard on duty that day; and Minute, which shows the minutes during which the guard was asleep within the midnight hour. (The Minute column's header shows the minute's ten's digit in the first row and the one's digit in the second row.) Awake is shown as ., and asleep is shown as #.
#
# Note that guards count as asleep on the minute they fall asleep, and they count as awake on the minute they wake up. For example, because Guard #10 wakes up at 00:25 on 1518-11-01, minute 25 is marked as awake.
#
# If you can figure out the guard most likely to be asleep at a specific time, you might be able to trick that guard into working tonight so you can have the best chance of sneaking in. You have two strategies for choosing the best guard/minute combination.
#
# Strategy 1: Find the guard that has the most minutes asleep. What minute does that guard spend asleep the most?
#
# In the example above, Guard #10 spent the most minutes asleep, a total of 50 minutes (20+25+5), while Guard #99 only slept for a total of 30 minutes (10+10+10). Guard #10 was asleep most during minute 24 (on two days, whereas any other minute the guard was asleep was only seen on one day).
#
# While this example listed the entries in chronological order, your entries are in the order you found them. You'll need to organize them before they can be analyzed.
#
# What is the ID of the guard you chose multiplied by the minute you chose? (In the above example, the answer would be 10 * 24 = 240.)


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

# Determine which guard slept the most
guard_that_slept_most = guards.max {|a,b| a.minutes_slept.count <=> b.minutes_slept.count }
puts "Guard #{'#' + guard_that_slept_most.id} slept the most (#{guard_that_slept_most.minutes_slept.count} minutes)"

# Determine when that guard is most likely to be asleep
time_most_slept_at = guard_that_slept_most.minutes_slept.group_by(&:hour_and_minute).values.max_by(&:size).first
puts "Guard #{'#' + guard_that_slept_most.id} is most likely to be asleep at #{time_most_slept_at.hour_and_minute}"

# Return
puts "Puzzle solution: #{guard_that_slept_most.id.to_i * time_most_slept_at.datetime.minute}"
