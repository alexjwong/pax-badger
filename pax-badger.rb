require 'nokogiri'
require 'open-uri'
require 'twitter'
require 'twilio-ruby'
require 'dotenv'
Dotenv.load

# Run this script as a cron job!
# Running `ruby pax-badger.rb east 1800`
# configures checking for pax east badges every half hour,
# provided it is scheduled to run every half hour.

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

badge_regex = /.+?[B|b]adge(s|).+?$/
east_regex = /.+?[E|e]ast.+?$/
south_regex = /.+?[S|s]outh.+?$/
prime_regex = /.+?[P|p]rime.+?$/
aus_regex = /.+?[A|a]us.+?$/

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
when nil
  puts "Error: no expo selected."
  exit
else
  puts "Error: '" + ARGV[0] + "' is not a valid expo."
  exit
end

# Read interval input in seconds
if ARGV[1].nil?
  interval = 0
else
  interval = ARGV[1].to_i
  if interval == 0 # non-integer entered or 0 entered
    puts "Error: invalid interval."
    puts "Interval is the time in seconds between scheduled runs of this script."
    exit
  end
end

puts "pax-badger by alexjwong"
puts "======================="
puts "\n"

puts "Starting monitor for PAX " + expo + " badges."
puts "\n"

found = false
source = ""

# monitor..
puts "checking..."

print "website..."
paxsite = Nokogiri::HTML(open("http://" + expo + ".paxsite.com"))
badges = paxsite.css("ul#badges")

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
  # Check to see if a tweet contains 'badge'
  if paxtweets[i].text.match(badge_regex)
    # Check if a specific expo is mentioned
    if paxtweets[i].text.match(expo_regex)
      # Only register found if tweet occurred after the last run, indicated by interval
      if (Time.now - paxtweets[i].created_at) < interval
        found = true
        source = "Badges mentioned by @Official_PAX!: " + paxtweets[i].text
      end
    end
    break
  end
end

puts "...done"
puts "\n"

if found
  puts source
  puts "\n"

  # Send text notifications
  @twilio_client.messages.create(
    from: ENV['TWILIO_NUMBER'],
    to: ENV['MY_NUMBER'],
    body: "pax-badger: " + source
  )

else
  puts "No badges mentioned recently...sit tight."
  puts "\n"
end
