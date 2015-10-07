pax-badger
==========

A simple ruby script to notify you of impending availability of pax badges by monitoring the [@offical_pax](https://twitter.com/official_pax) Twitter and [paxsite.com](https://www.paxsite.com)!

Run this when you know badges will be coming soon to get notified as soon as possible when badges are officially mentioned by PAX!

## How to Use

#### Locally
+ Run `bundle install`
+ Create a [Twitter App](http://apps.twitter.com), and a [Twilio](http://twilio.com) account
+ Set up a .env file containing info for Twitter {API_KEY, API_SECRET, ACCESS_TOKEN, and ACCESS_SECRET}, Twilio {ACCOUNT_SID and ACCESS_TOKEN}, and your telephone numbers {MY_NUMBER and TWILIO_NUMBER}
+ Run `ruby pax-badger.rb {expo}` to run the script. {expo} can be `east`, `prime`, `south`, or `aus`

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
