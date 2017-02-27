[![Build Status](https://secure.travis-ci.org/twilio/twilio-php.png?branch=master)](http://travis-ci.org/twilio/twilio-php)
[![Packagist](https://img.shields.io/packagist/v/twilio/sdk.svg)](https://packagist.org/packages/twilio/sdk)
[![Packagist](https://img.shields.io/packagist/dt/twilio/sdk.svg)](https://packagist.org/packages/twilio/sdk)

## Installation

You can install **twilio-php** via PEAR or by downloading the source.

#### Via PEAR (>= 1.9.3):

PEAR is a package manager for PHP. Open a command line and use these PEAR
commands to download the helper library:

    $ pear channel-discover twilio-pear.herokuapp.com/pear
    $ pear install twilio/Services_Twilio

If you get the following message:

    $ -bash: pear: command not found

you can install PEAR from their website, or download the source directly.

#### Via Composer:

**twilio-php** is available on Packagist as the
[`twilio/sdk`](http://packagist.org/packages/twilio/sdk) package.

## Quickstart

### Send an SMS

```php
// Send an SMS using Twilio's REST API and PHP
<?php
$sid = "ACXXXXXX"; // Your Account SID from www.twilio.com/console
$token = "YYYYYY"; // Your Auth Token from www.twilio.com/console

$client = new Twilio\Rest\Client($sid, $token);
$message = $client->messages->create(
  '8881231234', // Text this number
  array(
    'from' => '9991231234', // From a valid Twilio number
    'body' => 'Hello from Twilio!'
  )
);

print $message->sid;
```

### Make a Call

```php
<?php
$sid = "ACXXXXXX"; // Your Account SID from www.twilio.com/console
$token = "YYYYYY"; // Your Auth Token from www.twilio.com/console

$client = new Twilio\Rest\Client($sid, $token);

// Read TwiML at this URL when a call connects (hold music)
$call = $client->calls->create(
  '8881231234', // Call this number
  '9991231234', // From a valid Twilio number
  array(
      'url' => 'https://twimlets.com/holdmusic?Bucket=com.twilio.music.ambient'
  )
);
```

### Generating TwiML

To control phone calls, your application needs to output
[TwiML](https://www.twilio.com/docs/api/twiml/ "Twilio Markup Language"). Use
`Twilio\Twiml` to easily create such responses.

```php
<?php
$response = new Twilio\Twiml();
$response->say('Hello');
$response->play('https://api.twilio.com/cowbell.mp3', array("loop" => 5));
print $response;
```

That will output XML that looks like this:

```xml
<?xml version="1.0" encoding="utf-8"?>
<Response>
    <Say>Hello</Say>
    <Play loop="5">https://api.twilio.com/cowbell.mp3</Play>
<Response>
```

## Documentation

The documentation for the Twilio API is located [here][apidocs].

The PHP library documentation can be found [here][documentation].

## Versions

`twilio-php`'s versioning strategy can be found [here][versioning].

## Prerequisites

* PHP >= 5.3
* The PHP JSON extension

## Reporting Issues

We would love to hear your feedback. Report issues using the [Github
Issue Tracker](https://github.com/twilio/twilio-php/issues) or email
[help@twilio.com](mailto:help@twilio.com).

[apidocs]: https://twilio.com/api/docs
[documentation]: https://twilio.github.io/twilio-php/
[versioning]: https://github.com/twilio/twilio-php/blob/master/VERSIONS.md
