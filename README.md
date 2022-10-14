[![Gem Version](https://badge.fury.io/rb/mprofi_api_client.svg)](http://badge.fury.io/rb/mprofi_api_client)

# Mprofi API connector

This is a mProfi library for Ruby, supportig the mProfi.pl HTTP API.


## Installation

### In Bundler:

```ruby
gem 'mprofi_api_client'

# or

gem 'mprofi_api_client', :git => 'https://github.com/comverga/mprofi_api_client_ruby.git'

```

### From github.com

```bash
git clone https://github.com/comverga/mprofi_api_client_ruby.git
cd mprofi_api_client_ruby
rake build
gem install mprofi_api_client-0.1.1.gem
```

# Usage

```ruby
require 'mprofi_api_client'

API_TOKEN = 'token from mprofi.pl website'

connector = MprofiApiClient::Connector.new(API_TOKEN)
# or
# connector = MprofiApiClient::Connector.new(API_TOKEN, 'http://your_proxy_host_address:8080/')
begin
    # you can change read_timeout if the default of 60 seconds is not enough
    # connector.read_timeout = 120
    connector.add_message('501002003', 'Test message 1', 'your-msg-id-001')
    # message with Polish diacritics
    connector.add_message('601002003', 'Test message ąćęłńóśźż', 'your-msg-id-002', encoding: 'utf-8')
    # scheduled message
    connector.add_message('701002003', 'Test message 3', 'your-msg-id-003', date: '2022-08-30T12:00:00+02:00')
    result = connector.send
    # => [{"id"=>58},{"id"=>59},{"id"=>60}]

    result.each do |r|
        status = connector.get_status(r['id'])
        # => {"status"=>"delivered", "id"=>58, "reference"=>"your-msg-id-001", "ts"=>"2015-03-26T10:55:06.098Z"}

        # do sth with status
    end

rescue MprofiAuthError
    # invalid token
rescue MprofiConnectionError
    # communication error
end

```

## Copyright

Copyright (c) 2015 COMVERGA Sp. z o. o. See LICENSE for details.
