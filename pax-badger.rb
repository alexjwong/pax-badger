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
message_cooldown = 0

badge_regex = /.+?[B|b]adge(s|).+?$/
east_regex = /east/
south_regex = /.+?[S|s]outh.+?$/
prime_regex = /.+?[P|p]rime.+?$/
aus_regex = /.+?[A|a]us.+?$/
oldtweets = [nil,nil,nil,nil,nil]

# Read command-line argument to choose expo
case ARGV[0]
when east_regex
  expo = "east"
  expo_regex = east_regex
when south_regex
  expo = "south"
  expo_regex = south_regex
when prime_regex
  expo = "prime"
  expo_regex = prime_regex
when aus_regex
  expo = "aus"
  expo_regex = aus_regex
else
  puts "Error: '" + ARGV[0] + "' is not a valid expo."
  exit
end

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
    source = "Badges may be available! - check " + expo + ".paxsite.com"
  end

  puts "twitter..."

  # Most recent 5 tweets
  paxtweets = @twitter_client.user_timeline('Official_PAX')[0..5]

  for i in 0..5 do
    # Make sure there are new tweets
    if paxtweets[i].text.match(badge_regex) && paxtweets[i] != oldtweets[i]
      # See if a specific expo is mentioned
      if paxtweets[i].text.match(expo_regex)
        found = true
        source = "@Official_PAX:" + paxtweets[i].text
      else
        found = true
        source = "@Official_PAX:" + paxtweets[i].text
        puts "Badges!"
      end
    end
  end
  oldtweets = paxtweets

  puts "...finished"

  if found
    puts "BADGES ARE COMING? Sending out notifications now!"
    if message_cooldown == 0
      # Send text notifications
      @twilio_client.messages.create(
        from: ENV['TWILIO_NUMBER'],
        to: ENV['MY_NUMBER'],
        body: source
      )
      # Reset cooldown -
      # time equal to loop sleep time * message_cooldown
      message_cooldown = 2
    else
      message_cooldown = message_cooldown - 1
    end

  else
    puts "No badges yet...sit tight."
  end

  sleep(60*5) # 5 Minutes
end
