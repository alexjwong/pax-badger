require 'nokogiri'
require 'open-uri'
require 'twitter'
require 'twilio-ruby'
require 'dotenv'
Dotenv.load

# TODO: Single run and background modes

@twitter_client = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['API_KEY']
  config.consumer_secret     = ENV['API_SECRET']
  config.access_token        = ENV['ACCESS_TOKEN']
  config.access_token_secret = ENV['ACCESS_SECRET']
end

# preconfigure the Twilio client
Twilio.configure do |config|
  config.account_sid = ENV['ACCOUNT_SID']
  config.auth_token = ENV['AUTH_TOKEN']
end

# create twilio client
@twilio_client = Twilio::REST::Client.new
message_cooldown = 30

badge_regex = /.+?[B|b]adge(s|).+?$/
east_regex = /.+?[E|e]ast.+?$/
south_regex = /.+?[S|s]outh.+?$/
prime_regex = /.+?[P|p]rime.+?$/
oldtweets = [nil,nil,nil,nil,nil]

puts "pax-badger by alexjwong"
puts "======================="
puts "\n"

loop do
  found = false
  source = ""

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
    source = "website"
  end

  puts "twitter..."

  # Most recent 5 tweets
  paxtweets = @twitter_client.user_timeline('Official_PAX')[0..5]

  sampletweet = "pax East badges now available!"

  for i in 0..5 do
    if paxtweets[i].text.match(badge_regex) && paxtweets[i] != oldtweets[i]
      if paxtweets[i].text.match(east_regex)
        found = true
        puts "PAX East Badges!"
      elsif paxtweets[i].text.match(south_regex)
        found = true
        puts "PAX South Badges!"
      elsif paxtweets[i].text.match(prime_regex)
        found = true
        puts "PAX Prime Badges!"
      else
        found = true
        puts "Badges!"
      end
    end
  end
  # cache the old tweets
  oldtweets = paxtweets

  if found
    puts "BADGES ARE COMING? Sending out notifications now!"

    @twilio_client.messages.create(
      from: ENV['TWILIO_NUMBER'],
      to: ENV['MY_NUMBER'],
      body: 'Hey there!'
    )
  else
    puts "No badges yet...sit tight."
  end

  sleep(60*5) # seconds
end
