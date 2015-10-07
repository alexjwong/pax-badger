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
east_regex = /.+?[E|e]ast.+?$/
south_regex = /.+?[S|s]outh.+?$/
prime_regex = /.+?[P|p]rime.+?$/
aus_regex = /.+?[A|a]us.+?$/
oldtweets = [nil,nil,nil,nil,nil]

# Read command-line argument to choose expo
case ARGV[0]
when /east/i
  expo = "east"
  expo_regex = east_regex
when /south/i
  expo = "south"
  expo_regex = south_regex
when /prime/i
  expo = "prime"
  expo_regex = prime_regex
when /aus/i
  expo = "aus"
  expo_regex = aus_regex
else
  puts "Error: '" + ARGV[0] + "' is not a valid expo."
  exit
end

puts "pax-badger by alexjwong"
puts "======================="
puts "\n"

puts "Starting monitor for PAX " + expo + " badges."
puts "\n"

loop do
  found = false
  source = ""

  # monitor..
  puts "checking..."

  print "website..."
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
  puts "...done"

  print "twitter..."

  # Most recent 5 tweets
  paxtweets = @twitter_client.user_timeline('Official_PAX')[0..5]

  for i in 0..5 do
    # Make sure there are new tweets
    if paxtweets[i].text.match(badge_regex) && paxtweets[i] != oldtweets[i]
      # See if a specific expo is mentioned
      if paxtweets[i].text.match(expo_regex)
        found = true
        source = "Badges mentioned by @Official_PAX!: " + paxtweets[i].text
      end
      break
    end
  end
  oldtweets = paxtweets

  puts "...done"
  puts "\n"

  if found
    puts source
    puts "\n"
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
    puts "\n"
  end

  sleep(60*5) # 5 Minutes
end
