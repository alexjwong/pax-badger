pax-badger
==========

A simple ruby script to notify you of impending availability of pax badges by monitoring the [@offical_pax](https://twitter.com/official_pax) Twitter and [paxsite.com](https://www.paxsite.com)!

Run this as a cron job when you know badges will be coming soon to get notified as soon as possible when badges are officially mentioned by PAX!

## How to Use

**This script is designed to be run as a scheduled cron job!**

#### Locally
+ Run `bundle install`
+ Create a [Twitter App](http://apps.twitter.com), and a [Twilio](http://twilio.com) account
+ Set up a .env file containing info for Twitter {API_KEY, API_SECRET, ACCESS_TOKEN, and ACCESS_SECRET}, Twilio {ACCOUNT_SID and ACCESS_TOKEN}, and your telephone numbers {MY_NUMBER and TWILIO_NUMBER}
+ Run `ruby pax-badger.rb {expo} {interval}` to run the script.
  + {expo} can be `east`, `prime`, `south`, or `aus`
  + {interval} is the interval *in seconds* between scheduled runs of the script
  + For example, if you schedule the script to run every half hour to check for PAX East badges, run `ruby pax-badger.rb east 1800`
+ To run the script not in the context of a cron job, you can just use `ruby pax-badger.rb {expo}`.
  + This will send notifications for *any* recent mention
  + This will not take into account scheduled runs, so many duplicate notifications may be sent if you omit the interval.

#### Heroku
+ You can schedule the script to run on Heroku using the Heroku Scheduler!

## Dependencies
+ `ruby >= 2.1.0`
+ `gem 'nogokiri'` to parse html
+ `gem 'twitter'` to parse tweets
+ `gem 'dotenv'` to keep sensitive information safe
+ `gem 'twilio-ruby'` to send SMS notifications

## Authors
Alex Wong

## License
MIT
