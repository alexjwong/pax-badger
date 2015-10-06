pax-badger
==========

(development still in progress...!)

A simple ruby script to notify you of impending availability of pax badges by monitoring the [@offical_pax](https://twitter.com/official_pax) Twitter and [paxsite.com](https://www.paxsite.com)!

## How to Use

#### Locally
+ Run `bundle install`  
+ Set up a .env file containing info for Twitter {API_KEY, API_SECRET, ACCESS_TOKEN, and ACCESS_SECRET}, Twilio {ACCOUNT_SID and ACCESS_TOKEN}, and your telephone numbers {MY_NUMBER and TWILIO_NUMBER}.
+ Run `ruby pax-badger.rb {expo}` to run the script. {expo} can be `east`, `prime`, `south`, or `aus`


## Dependencies
+ `ruby >= 2.1.0`
+ `gem 'nogokiri'` to parse html
+ `gem 'twitter'` to parse tweets
+ `gem 'dotenv'` to keep sensitive information safe
+ `gem 'twilio-ruby'` to send SMS notifications


## Authors
Alex Wong
