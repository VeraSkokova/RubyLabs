require 'date'

regexp = /^(\w+) (\w+) (?<username>\w+) (?<email><[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+>) (?<timestamp>(\d){10}) (?<timezone>\+(\d){4})\t(?<action>(.+):(.+))$/

def read_file_lines(filename)
  file = File.open(filename)
  file.readlines.map(&:chomp)
end

def map_captures(strings, regexp)
  strings.map { |string| string.match(regexp).named_captures }.map { |capture| yield(capture) }
end

stats = Hash.new
strings = read_file_lines('master')
map_captures(strings, regexp) {
    |capture|
  month = Time.at(capture["timestamp"].to_i).to_datetime.strftime("%B")
  username = capture["username"]
  username_mentions_count = stats.fetch(month, Hash.new).fetch(username, 0)
  stats.store(month, Hash[username, username_mentions_count + 1])
}


#puts stats
puts stats.map { |stat_element| "Top of " + stat_element[0] + " is " + stat_element[1].sort_by { |key, value| value }.to_a[0][0].to_s }
