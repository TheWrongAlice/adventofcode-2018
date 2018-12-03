#!/usr/bin/env ruby

# --- Part Two ---
# Confident that your list of box IDs is complete, you're ready to find the boxes full of prototype fabric.
#
# The boxes will have IDs which differ by exactly one character at the same position in both strings. For example, given the following box IDs:
#
# abcde
# fghij
# klmno
# pqrst
# fguij
# axcye
# wvxyz
# The IDs abcde and axcye are close, but they differ by two characters (the second and fourth). However, the IDs fghij and fguij differ by exactly one character, the third (h and u). Those must be the correct boxes.
#
# What letters are common between the two correct box IDs? (In the example above, this is found by removing the differing character from either ID, producing fgij.)


def near_match? (a, b)
  return false if a == b # Exact match doesn't count

  char_missmatch_count = 0
  a.length.times do |index|
    if a[index] != b[index]
      char_missmatch_count +=1
      return false if char_missmatch_count > 1 # Too much difference
    end
  end

  return true
end

boxes = File.readlines('input.txt')
boxes.each do |a|
  boxes.each do |b|

    if near_match?(a.strip, b.strip)
      common_chars = ''
      a.length.times do |index|
        common_chars << a[index] if a[index] == b[index]
      end
      puts common_chars
      exit
    end

  end
end
