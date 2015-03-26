$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))

require 'minitest/autorun'
require 'webmock/minitest'
require 'minitest/reporters'

require 'mprofi_api_client'


Minitest::Reporters.use!

class ConnectorTest < Minitest::Test

  API_TOKEN = '420000000000010666'  
  API_BASE_URL = [MprofiApiClient::API_BASE_URL, MprofiApiClient::API_VERSION, ''].join('/')

  MSISDN = '501002003'
  MESSAGE = 'Test sms 1'


  def setup
    @connector = MprofiApiClient::Connector.new(API_TOKEN)
  end


  def test_undefined_api_token__exception_thrown
    assert_raises ArgumentError do
      MprofiApiClient::Connector.new
    end
  end

  def test_add_message__invalid_recipient__exception_thrown
    assert_raises ArgumentError do
      @connector.add_message('', MESSAGE)
    end
  end

  def test_add_message__empty_message__exception_thrown
    assert_raises ArgumentError do
      @connector.add_message(MSISDN, '')
    end
  end  

  def test_send__empty_payload__exception_thrown    
    assert_raises StandardError do
      @connector.send
    end
  end

  def test_send__invalid_authorization__exception_thrown
    stub_request(:post, API_BASE_URL + 'send/').to_return(:status => 401)

    @connector.add_message(MSISDN, MESSAGE)

    assert_raises MprofiApiClient::MprofiAuthError do
      @connector.send
    end
  end

  def test_send__unexpected_api_server_response__exception_thrown
    stub_request(:post, API_BASE_URL + 'send/').to_return(:status => 503)

    @connector.add_message(MSISDN, MESSAGE)

    assert_raises MprofiApiClient::MprofiConnectionError do
      @connector.send
    end
  end

  def test_status__msg_id_is_nil__exception_thrown
    assert_raises ArgumentError do
      @connector.get_status(nil)
    end
  end

  def test_status__non_existent_or_invalid_msg_id__exception_thrown
    stub_request(:get, API_BASE_URL + 'status/?id=-2').to_return(:status => 404, :body => '{"detail":"Not found"}')

    assert_raises MprofiApiClient::MprofiNotFoundError do
      @connector.get_status(-2)
    end
  end

  def test_status__unexpected_api_server_response__exception_thrown
    stub_request(:get, API_BASE_URL + 'status/?id=100').to_return(:status => 408)

    assert_raises MprofiApiClient::MprofiConnectionError do
      @connector.get_status(100)
    end
  end

end
