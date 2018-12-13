#!/usr/bin/env ruby


# Your puzzle answer was 9526.
#
# The first half of this puzzle is complete! It provides one gold star: *
#
# --- Part Two ---
# Time to improve the polymer.
#
# One of the unit types is causing problems; it's preventing the polymer from collapsing as much as it should. Your goal is to figure out which unit type is causing the most problems, remove all instances of it (regardless of polarity), fully react the remaining polymer, and measure its length.
#
# For example, again using the polymer dabAcCaCBAcCcaDA from above:
#
# Removing all A/a units produces dbcCCBcCcD. Fully reacting this polymer produces dbCBcD, which has length 6.
# Removing all B/b units produces daAcCaCAcCcaDA. Fully reacting this polymer produces daCAcaDA, which has length 8.
# Removing all C/c units produces dabAaBAaDA. Fully reacting this polymer produces daDA, which has length 4.
# Removing all D/d units produces abAcCaCBAcCcaA. Fully reacting this polymer produces abCBAc, which has length 6.
# In this example, removing all C/c units was best, producing the answer 4.
#
# What is the length of the shortest polymer you can produce by removing all units of exactly one type and fully reacting the result?


input = File.readlines('input.txt')[0].strip

def reacts?(a, b)
  a != b and a.upcase == b.upcase
end

def chain_reaction(str)
  loop do
    reaction_found = false
    for i in 0..str.length-3 do
      if reacts?(str[i], str[i+1])
        2.times do
          str.slice!(i)
        end
        reaction_found = true
        break
      end
    end
    break unless reaction_found
  end
  return str
end

shortest = ''
'abcdefghijklmnopqrstuvwxyz'.split('').each do |letter|
  modified_input = input.gsub(letter, '').gsub(letter.upcase, '')
  str = chain_reaction(modified_input)
  if str.length < shortest.length or shortest.empty?
    shortest = str
  end
end

puts shortest.length
