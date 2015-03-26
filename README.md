
# Mprofi API connector

This is a mProfi library for Ruby, supportig the mProfi.pl HTTP API.


## Installation

### In Bundler:

```ruby
gem 'mprofi_api_client'

# or

gem 'mprofi_api_client', :git => 'https://github.com/materna/mprofi_api_client_ruby.git'

```

### From github.com

```bash
git clone https://github.com/materna/mprofi_api_client_ruby.git
cd mprofi_api_client_ruby
rake build
gem install mprofi_api_client-0.1.0.gem
```

# Usage

```ruby
require 'mprofi_api_client'

API_TOKEN = 'token from mprofi.pl website'

connector = MprofiApiClient::Connector.new(API_TOKEN)
# or
# connector = MprofiApiClient::Connector.new(API_TOKEN, 'http://your_proxy_host_address:8080/')
begin
    connector.add_message('501002003', 'Test message 1', 'your-msg-id-001')
    connector.add_message('601002003', 'Test message 2', 'your-msg-id-002')
    result = cliend.send
    # => [{"id"=>58}, {"id"=>59}]

    result.each do |r|
        status = connector.get_status(r['id'])
        # => {"status"=>"delivered", "id"=>11, "reference"=>"your-msg-id-001", "ts"=>"2015-03-26T10:55:06.098Z"}

        # do sth with status
    end

rescue MprofiAuthError
    # invalid token
rescue MprofiConnectionError
    # communication error
end

```

## Copyright

Copyright (c) 2015 Materna Communications. See LICENSE for details.