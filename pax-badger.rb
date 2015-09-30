require 'nokogiri'
require 'open-uri'
require 'twitter'

# TODO: Single run and background modes


puts "pax-badger by alexjwong"
puts "======================="
puts "\n"

loop do
  found = false

  # monitor..
  puts "checking..."

  puts "website..."
  paxsite = Nokogiri::HTML(open("http://east.paxsite.com"))
  badges = paxsite.css("ul#badges")

  # Local testing
  # paxsite = Nokogiri::HTML(open("test.html"))
  # badges = paxsite.css("ul#badges")
  # puts badges
  # puts badges.css("li.soldOut").empty?

  if badges.css("li.soldOut").empty?
    puts "something's different...BADGES ARE NOT SOLD OUT!"
    found = true
  end

  # TODO: implement twitter parsing
  # puts "...twitter"

  if found
    puts "BADGES ARE COMING! Sending out notifications now!"
  else
    puts "No badges yet...sit tight."

  end

  break
  # sleep(60) # seconds
end
