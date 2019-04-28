# HeyYou [Alpha]
[![Build Status](https://travis-ci.com/QNester/hey-you.svg?branch=master)](https://travis-ci.com/QNester/hey-you#)

Send multichannel notifications with one command. 
Сonvenient storage of notifications texts. Create your 
own channels. Registrate receiver and send notifications for 
him easy.

* [Requirements](#requirements)
* [Installation](#installation)
* [How to use](#how-to-use)
    * [Configure](#configure)
    * [Registrate receiver](#registrate-receiver)
    * [Build your notification](#build-your-notification)
    * [Send notification](#send-notification)
    * [Sender options](#sender-options)
    * [Create your own channels](#create-your-own-channels)    
* [Extensions](#extensions)    


## Requirements
 * Ruby 2.3.0 min (rspec works with ruby 2.3.3, 2.4.2, 2.5.3)
 * FCM - Gem send push notification using [fcm gem](https://github.com/spacialdb/fcm).
 You need *fcm server key* to successful configure push notifications.

## Installation

```ruby
gem 'hey-you'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hey-you    

## How to use

### Configure
First, you must configure HeyYou. Example:
```ruby
  HeyYou::Config.configure do
    config.collection_files = ['config/notifications.yml']
    config.email.from = 'noreply@example-mail.com'
    config.push.fcm_token = 'fcm_server_key'
  end
```
#### Required settings
Options for gem base work.
##### Base
* __config.collection_files__ - File or files contained all your notifications texts.
##### Push
* __config.push.fcm_token__ - Required setting for push channel. You can not send
push messages if setting was not set. You should set it to equal your fcm server key.
##### Email
* __config.email.from__ - Email address for send email notifications.

#### Optional settings
Additional options for configure your notifications.
#### Base
* __config.env_collection_file__ - File contained all your notifications texts for
environment. You can set it like `notifications.#{ENV['APP_ENV]}.yml`
* __config.splitter__ - Chars for split notification keys for 
builder. Default: `.`
* __config.registered_channels__ - Avialable channels for your
applications. Default: `[:push, :email]`
* __config.localization__ - Boolean. If true, hey-you begin support I18n locales for notifications collection. Your
notifications for build should be nested in `I18n.locale` key. For example:

```ruby
# config/initializers/hey-you.rb
HeyYou::Config.configure do
  ...
  config.collection_files = I18n.available_locales.map { |locale| "config/notifications/#{locale}.yml" }
  ...
end 
```

```yaml
# config/notifications/en.yml
en:
  any_key:
    any_nested_key:
      push:
        title: Test hey you
        body: Hey you, %{name}
      email:
        subject: Test hello
        body: Hey you, %{name}  
```

```yaml
# config/notifications/ru.yml
ru:
  any_key:
    any_nested_key:
      push:
        title: Эй, ты!
        body: Эй, ты, %{name}
      email:
        subject: Привет
        body: Эй, ты, %{name}  
```

```ruby
# From your code:
I18n.locale = :ru
user.send_notification('any_key.any_nested_key', name: 'QNester') #=> send notification with body `Эй, ты, QNester`
I18n.locale = :en
user.send_notification('any_key.any_nested_key', name: 'QNester') #=> send notification with body `Hey you, QNester`
user.send_notification('any_key.any_nested_key', name: 'QNester', locale: :ru) #=> send notification with body `Эй, ты, QNester`

```

##### Push
* __config.push.priority__ - priority level for your pushes.
Default: high
* __config.push.ttl__ - default time_to_live option for fcm.
Default 60
* __config.push.fcm_timeout__ - default timeout for fcm.
Default 30
##### Email
* __config.email.layout__ - default layout for email letters.
* __config.email.default_mailing__ - use default mail sending or use custom mailer classes
* __config.email.default_mailer_class__ - default mailer class for email notifications
* __config.email.default_mailer_method__ - default mailer_method for mailer_class
* __config.email.default_delivery_method__ - expects, that mailer_method will build message and delivery_method will send it.
If you use ActionMailer you can set this option like `delivery_now` or `delivery_later`.

By default all letters will send as simple text.

### Registrate receiver
You can registrate your application classes like receivers.
You can easy send notification for receiver with method
`#send_notification`. For example:
```ruby
class User < Model
  extend HeyYou::Receiver
  
  receive(
    push: -> { push_token.value }, 
    email: -> { email }
  )
end
```

Class method `#receive` will registrate your class User
as receiver. In arguments we must pass Hash instance where
keys - channels names as symbols, and values - procs for 
fetching values required to send notification. For push channel
expected that proc will return receiver's fcm registration id. For
email expected that proc will return receiver's email address.

You can pass options for receiver channels. You must pass proc with receive_data to `:subject` key and options 
pass to `:options` key:

```ruby
class User < Model
  extend HeyYou::Receiver
  
  receive(
    push: -> { push_token.value }, 
    email: { subject: -> { email }, options: { mailer_class: UserMailer, mailer_method: :notify! } }
  )
end
``` 

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
HeyYou Notification Builder - good system for store your notifications in one place.
You need create yml file with follow format:
```yaml
# config/notifications/collection.yml
any_key:
  any_nested_key:
    push:
      title: Test hey you
      body: Hey you, %{name}
    email:
      subject: Test hello
      body: Hey you, %{name}  
``` 

You should pass file path to `config.collection_file` to load your notification texts.
Now you can send notification:

```ruby
...
user.send_notification('any_key.any_nested_key', name: 'HeyYou')
```
This command with fetch notifications templates from your collection file 
for each channel and will try interpolate it. If you will not pass required 
interpolation keys then error will be raised. After successful interpolation
notification will send for all available channels for receiver: 
1) Send push via fcm
2) Send email

### Send notification
Receiver not only one way to send notification. You can send it using `HeyYou::Sender`.
Just use method `#send` for HeyYou::Sender and pass notification key and `to` options
like:

```ruby
HeyYou::Sender.send!(
  'any_key.any_nested_key', 
  to: {
    push: 'fcm_registration_token', 
    email: 'example_mail@example.com'  
  },
  name: 'HeyYou'
)

```
This command will process texts and send push and email to `to` credentials.

### Sender options
#### Only option
You can user some options for sender. You can send notification exclude
not required channels with option `:only` like:

```ruby
user.send_notification('any_key.any_nested_key', name: 'HeyYou', only: [:push])
```

It will send notification only with push channel. Email will be skipped.

#### Channels options
Channels options should pass to send method with associated channel names like:
```ruby
user.send_notification(
  'any_key.any_nested_key', 
  name: 'HeyYou', 
  email: { layout: 'layout' }
)
```

In this example we pass option for email channel. We decide
specific layout for 'any_key.any_nested_key' notification.

### Create your own channels
To create your custom channel you should create two classes:
1. HeyYou::Builders::<YOUR_CHANNEL_NAME>
2. HeyYou::Channels::<YOUR_CHANNEL_NAME>

You must extend your builder class from `HeyYou::Builder::Base` and realize
class method `#build`. In this method you should fetch notification data for 
Your channel. For example: 

```ruby
class HeyYou::Builder::CustomNotifier < HeyYou::Builder::Base
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
    push:
      # ...
    custom_notifier:
      header: Hello
      body: Hello, %{name}
      icon: 'icons.klass'
```

To check your builder you can call 
```ruby
notifier_data = HeyYou::Builder.new('any_key.any_nested_key', name: 'HeyYou').custom_notifier
notifier_data # => Instance of HeyYou::Builder::CustomNotifier
notifier_data.header # => Hello
notifier_data.body # => Hello, HeyYou
notifier_data.icon # => 'icons.klass'
```

You must extend your channel class from `HeyYou::Channels::Base` and
realize class method `#send!`. This method pass two arguments: builder instance and to option.
Finally, you channel should look like:

```ruby
class HeyYou::Channels::CustomNotifier < HeyYou::Channels::Base
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
`HeyYou::Config::<YOUR_CHANNEL_NAME>`, extend it with Configurable module and add
accessors for it. Example:

```ruby
class HeyYou::Config::CustomNotifier
  extend HeyYou::Config::Configurable

  attr_accessor :secret_key
  
  def client
    YourProviderClass::Client.new(secret_key)
  end
end
```

If your attr is required you can add checking it
in your channel:

```ruby
class HeyYou::Channels::CustomNotifier < HeyYou::Channels::Base
  class << self
    def send!(builder, to:)
      return false unless credentials_present?
    
      HeyYou::Config.instance.custom_notifier.client.send_message(
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

## Extensions
* [Slack channel](https://github.com/QNester/hey-you) 
[![Gem Version](https://badge.fury.io/rb/hey-you-slack.svg)](https://badge.fury.io/rb/hey-you-slack)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/QNester/hey-you. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.
