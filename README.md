# Horn
[![Build Status](https://travis-ci.com/QNester/bullhorn.svg?branch=master)](https://travis-ci.com/QNester/bullhorn)

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
First, you must configure Horn. Example:
```ruby
  Horn::Config.configure do
    config.collection_file = 'config/notifications.yml'
    config.email.from = 'noreply@example-mail.com'
    config.push.fcm_token = 'fcm_server_key'
  end
```
#### Required settings
Options for gem base work.
##### Base
* __config.collection_file__ - File contained all your notifications texts.
##### Push
* __config.push.fcm_token__ - Required setting for push channel. You can not send
push messages if setting was not set. You should set it to equal your fcm server key.
##### Email
* __config.email.from__ - Email address for send email notifications.
##### SMS
* __config.sms.twilio_account_sid__ - Account sid for twilio. Without this settings 
you will can not send sms.
* __config.sms.twilio_auth_token__ - Secret auth token for twilio. Without this setting 
you will can not send sms.
* __config.sms.twilio_from_number__ - From number in twilio. Without this setting 
you will can not send sms.

#### Optional settings
Additional options for configure your notifications.
#### Base
* __config.env_collection_file__ - File contained all your notifications texts for
environment. You can set it like `notifications.#{ENV['APP_ENV]}.yml`
* __config.splitter__ - Chars for split notification keys for 
builder. Default: `.`
* __config.registered_channels__ - Avialable channels for your
applications. Default: `[:sms, :push, :email]`
##### Push
* __config.push.priority__ - priority level for your pushes.
Default: high
* __config.push.ttl__ - default time_to_live option for fcm.
Default 60
* __config.push.fcm_timeout__ - default timeout for fcm.
Default 30
##### Email
* __config.email.layout__ - default layout for email letters.
By default all letters will send as simple text.

### Registrate receiver
You can registrate your application classes like receivers.
You can easy send notification for receiver with method
`#send_notification`. For example:
```ruby
class User < Model
  extend Horn::Receiver
  
  receive(
    sms: -> { number }, 
    push: -> { push_token.value }, 
    email: -> { email }
  )
end
```

Class method `#receive` will registrate your class User
as receiver. In arguments we must pass Hash instance where
keys - channels names as symbols, and values - procs for 
fetching values required to send notification. For sms channel
expected that proc will return receiver's mobile number. For push channel
expected that proc will return receiver's fcm registration id. For
email expected that proc will return receiver's email address.

If you pass correct procs in `#receive` you can send notification
for your user like:

```ruby
user = User.find(1)
user.send_notification('for_users.hello')
```

Last command will fetch notifications credentials for user instance
and will try to send SMS, Push and Email for it. What argument we pass
for method? This is string key for builder. Read next to understand it.

### Build your notification
Horn Notification Builder - good system for store your notifications in one place.
You need create yml file with follow format:
```yaml
# config/notifications/collection.yml
any_key:
  any_nested_key:
    sms:
      text: Hello, %{name}
    push:
      title: Test hello
      body: Hello, %{name}
    email:
      subject: Test hello
      body: Hello, %{name}  
``` 

You should pass file path to `config.collection_file` to load your notification texts.
Now you can send notification:

```ruby
...
user.send_notification('any_key.any_nested_key', name: 'Horn')
```
This command with fetch notifications templates from your collection file 
for each channel and will try interpolate it. If you will not pass required 
interpolation keys then error will be raised. After successful interpolation
notification will send for all available channels for receiver: 
1) Send sms via twilio
2) Send push via fcm
3) Send email

### Send notification
Receiver not only one way to send notification. You can send it using `Horn::Sender`.
Just use method `#send` for Horn::Sender and pass notification key and `to` options
like:

```ruby
Horn::Sender.send!(
  'any_key.any_nested_key', 
  to: {
    push: 'fcm_registration_token', 
    email: 'example_mail@example.com'  
  },
  name: 'Horn'
)

```
This command will process texts and send push and email to `to` credentials.

### Sender options
#### Only option
You can user some options for sender. You can send notification exclude
not required channels with option `:only` like:

```ruby
user.send_notification('any_key.any_nested_key', name: 'Horn', only: [:push, :sms])
```

It will send notification only with push and email channels. Sending of sms
will be skipped.

#### Channels options
Channels options should pass to send method with associated channel names like:
```ruby
user.send_notification(
  'any_key.any_nested_key', 
  name: 'Horn', 
  email: { layout: 'layout' }
)
```

In this example we pass option for email channel. We decide
specific layout for 'any_key.any_nested_key' notification.

### Create your own channels
To create your custom channel you should create two classes:
1. Horn::Builders::<YOUR_CHANNEL_NAME>
2. Horn::Channels::<YOUR_CHANNEL_NAME>

You must extend your builder class from `Horn::Builder::Base` and realize
class method `#build`. In this method you should fetch notification data for 
Your channel. For example: 

```ruby
class Horn::Builder::CustomNotifier < Horn::Builder::Base
  class << self
    attr_reader :header, :body, :icon
  
    def build
      @header = interpolate(ch_data['header'], options)
      @body = interpolate(ch_data['body'], options)
      @icon = options[:icon] || interpolate(ch_data['icon'], options)
    end
  end
end
```

Your notifications collection YAML file will contain next:

```yaml
any_key:
  any_nested_key:
    sms:
      # ...
    custom_notifier:
      header: Hello
      body: Hello, %{name}
      icon: 'icons.klass'
```

To check your builder you can call 
```ruby
notifier_data = Horn::Builder.new('any_key.any_nested_key', name: 'Horn').custom_notifier
notifier_data # => Instance of Horn::Builder::CustomNotifier
notifier_data.header # => Hello
notifier_data.body # => Hello, Horn
notifier_data.icon # => 'icons.klass'
```

You must extend your channel class from `Horn::Channels::Base` and
realize class method `#send!`. This method pass two arguments: builder instance and to option.
Finally, you channel should look like:

```ruby
class Horn::Channels::CustomNotifier < Horn::Channels::Base
  class << self
    def send!(builder, to:)
      custom_notifier_client.send_message(
        text: builder.custom_notifier.text,
        token: to 
      )
    end
  end
end

```

If your channel require some configurations you should create class
`Horn::Config::<YOUR_CHANNEL_NAME>`, extend it with Configurable module and add
accessors for it. Example:

```ruby
class Horn::Config::CustomNotifier
  extend Horn::Config::Configurable

  attr_accessor :secret_key
  
  def client
    YourProviderClass::Client.new(secret_key)
  end
end
```

If your attr is required you can add checking it
in your channel:

```ruby
class Horn::Channels::CustomNotifier < Horn::Channels::Base
  class << self
    def send!(builder, to:)
      return false unless credentials_present?
    
      Horn::Config.instance.custom_notifier.client.send_message(
        text: builder.custom_notifier.text,
        token: to 
      )
    end
    
    def required_credentials
      [:secret_key]
    end
  end
end

```

`#credentials_present?` method check exists required_credentials
in your channel config.

Now, when you will send notification, it will be send with your channel too.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/horn. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the Horn project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/horn/blob/master/CODE_OF_CONDUCT.md).
