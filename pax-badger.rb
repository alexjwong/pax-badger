require 'nokogiri'
require 'open-uri'
require 'twitter'
require 'dotenv'
Dotenv.load

# TODO: Single run and background modes

twitter_client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['API_KEY']
  config.consumer_secret     = ENV['API_SECRET']
  config.access_token        = ENV['ACCESS_TOKEN']
  config.access_token_secret = ENV['ACCESS_SECRET']
end

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

  puts "...twitter"
  badge_regex = /.+?[B|b]adge(s|).+?$/
  # Most recent tweet
  paxtweet = twitter_client.user_timeline('Official_PAX')[0]
  if paxtweet.text.match(badge_regex)
    found = true
  end

  if found
    puts "BADGES ARE COMING? Sending out notifications now!"
    # TODO: Send notifications with twilio
  else
    puts "No badges yet...sit tight."

  end

  break
  # sleep(60) # seconds
end
