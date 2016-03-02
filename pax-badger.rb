require 'nokogiri'
require 'open-uri'
require 'twitter'
require 'twilio-ruby'
require 'dotenv'
Dotenv.load

# Run this script as a cron job!
# Running `ruby pax-badger.rb east 600`
# configures checking for pax east badges every 10 minutes,
# provided it is scheduled to run every 10 minutes.

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
west_regex = /.+?[W|w]est.+?$/
aus_regex = /.+?[A|a]us.+?$/
dev_regex = /.+?[D|d]ev.+?$/

# Read command-line argument to choose expo
case ARGV[0]
when /east/i
  expo = "east"
  expo_regex = east_regex
when /south/i
  expo = "south"
  expo_regex = south_regex
when /west/i
  expo = "west"
  expo_regex = west_regex
when /aus/i
  expo = "aus"
  expo_regex = aus_regex
when /dev/i
  expo = "dev"
  expo_regex = dev_regex
when nil
  puts "Error: no expo selected."
  exit
else
  puts "Error: '" + ARGV[0] + "' is not a valid expo."
  exit
end

# Read interval input in seconds
if ARGV[1].nil?
  single = true
else
  single = false
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
hold = false
source = ""

# monitor..
puts "checking..."

print "twitter..."

# Most recent 5 tweets
paxtweets = @twitter_client.user_timeline('Official_PAX')[0..5]

for i in 0..5 do
  # Check to see if a tweet contains 'badge'
  if paxtweets[i].text.match(badge_regex)
    # Check if a specific expo is mentioned
    if paxtweets[i].text.match(expo_regex)
      # Single run mode
      if single == true
        found = true
        source = "Badges mentioned by @Official_PAX!: " + paxtweets[i].text
      else
        # Only register found if tweet occurred after the last run, indicated by interval
        if (Time.now - paxtweets[i].created_at) < interval
          found = true
          source = "Badges mentioned by @Official_PAX!: " + paxtweets[i].text
        else
          # Since we know we sent a notification about this already,
          # set flag indicating ignoring the website results
          hold = true
        end
      end
    end
    break
  end
end

puts "...done"

print "website..."
# If nothing has been found after checking tweets, check website
# **west.paxsite is not created yet, so ignore it for now**
if (!found && hold == false && expo != "west")
  paxsite = Nokogiri::HTML(open("http://" + expo + ".paxsite.com"))
  badges = paxsite.css("ul#badges")

  if badges.css("li.soldOut").empty?
    found = true
    source = "BADGES MAY BE AVAILABLE! - check " + expo + ".paxsite.com"
  end
end
puts "...done"
puts "\n"

if found
  puts source
  puts "\n"

  # Send text notifications (if not running in single-run mode)
  if (!single)
    @twilio_client.messages.create(
      from: ENV['TWILIO_NUMBER'],
      to: ENV['MY_NUMBER'],
      body: "pax-badger: " + source
    )
  end

else
  puts "No badges mentioned recently...sit tight."
  puts "\n"
end
