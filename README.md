# ErratumResponsum

[![Build Status: master](https://travis-ci.com/XPBytes/erratum_responsum.svg)](https://travis-ci.com/XPBytes/erratum_responsum)
[![Gem Version](https://badge.fury.io/rb/erratum_responsum.svg)](https://badge.fury.io/rb/erratum_responsum)
[![MIT license](https://img.shields.io/badge/license-MIT-brightgreen.svg)](http://opensource.org/licenses/MIT)

Error response handlers for a Rails controller, that always return JSON.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'erratum_responsum'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install erratum_responsum

## Usage

Add the concern to your `ApplicationController` or `ApiController`

```ruby
require 'erratum_responsum'

class ApiController < ActionController::API
  include ErratumResponsum
end
```

### Media Type

You can optionally set the class variable `error_media_type` to change the `Content-Type` of error responses.

```ruby
  self.error_media_type = 'application/vnd.xpbytes.errors.v1+json'
```

### Rescue Errors

In order to use the error responses, use `rescue_from` to handle them:

```ruby
  rescue_from CanCan::AccessDenied, AuthorizedTransaction::TransactionUnauthorized, with: :forbidden
  rescue_from OptimisticallyStale::MissingLockVersion, ActionController::BadRequest,
              RequestMissingParam, with: :bad_request
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActionController::UnknownFormat, NoAcceptSerializer, with: :not_acceptable
  rescue_from ResourceGone, with: :gone
  rescue_from ActiveRecord::StatementInvalid, ActiveRecord::RecordInvalid,
              ContentDoesNotMatchContentType, with: :unprocessable_entity
  rescue_from ActiveRecord::RecordNotUnique, ActiveRecord::StaleObjectError, with: :conflict
  rescue_from ContentTypeNotRecognised, with: :unsupported_media_type
```

Now, when one of these error is raised in a controller action, the error response is generated automatically.

> 💡 Remove `CanCan` if you don't use `cancancan`.
>
> 💡 Remove `AuthorizedTransaction` , if you don't use `authorized_transaction`.
>
> 💡 Remove `OptimisticallyStale` if you don't use `optimistically_stale`

When the exception has more information, such as an `error_code`, the code will use that instead, prefixed with `Ex`.
If there is no such information, the error class name is used to generate the error code, prefixed with `Gx`.
Change this behaviour by overriding `def error_code(error)`.

This gem does expose more errors

## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `rake test` to run the tests.
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at [XPBytes/erratum_responsum](https://github.com/XPBytes/erratum_responsum).
