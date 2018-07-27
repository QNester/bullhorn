# Horn
[![Build Status](https://travis-ci.com/QNester/horn.svg?branch=master)](https://travis-ci.com/QNester/horn)

Send multichannel notifications with one command. 
Сonvenient storage of notifications texts. Create your 
own channels. Registrate receiver and send notifications for 
him easy.

## Requirements
 * Ruby 2.2.1+ (rspec works with ruby 2.2.1, 2.3.0, 2.4.0, 
 2.5.1)
 * FCM - Gem send push notification using [fcm gem](https://github.com/spacialdb/fcm).
 You need *fcm server key* to successful configure push notifications.
 * Twilio - Gem send sms notification using [twilio-ruby gem](twilio-ruby).
    You need *twilio account sid* and *twilio auth token* to successful configure sms notifications.

## Installation

```ruby
gem 'horn'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install horn    

## How to use

### Configure
First, you must configure Horn.
### Registrate receiver
About receiver
### Build your notification
About builder
### Send notification
About sender
### Create your own channels
How to create custom channel

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/horn. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the Horn project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/horn/blob/master/CODE_OF_CONDUCT.md).
