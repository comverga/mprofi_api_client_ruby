require 'net/https'
require 'json'
require 'mprofi_api_client/connector_exception'

# Module with connector managing communication with mProfi API.
module MprofiApiClient

  API_BASE_URL = 'https://api.mprofi.pl' #:nodoc:
  API_VERSION = '1.0' #:nodoc:

  class MprofiConnectionError < ConnectorException ; end
  class MprofiAuthError < ConnectorException ; end
  class MprofiNotFoundError < ConnectorException ; end

  # Connector class that manages communication with mProfi public API.
  class Connector

    attr_reader :messages
    attr_accessor :clear_messages #:nodoc:

    # +api_token+:: api token, as string. If api_token is not specified `MPROFI_API_TOKEN` env variable will be used.
    # +proxy_url+:: proxy URL (optional)
    def initialize(api_token = nil, proxy_url = nil)
      @api_token = api_token || ENV['MPROFI_API_TOKEN']
      raise ArgumentError, "API token not defined!" unless @api_token

      @proxy_url = proxy_url
      @messages = []
      @clear_messages = true
      @read_timeout = nil
    end

    # Add one message to message queue.
    # +recipient+:: Message recipient as string (phone number format: XXXXXXXXX f.e. 664400100).
    # +message+:: Message content as string.
    # +reference+:: Client message ID defined by user for message tracking. (optional)
    # +options+:: Message options: encoding (default: {}):
    #             +:encoding+ - set to 'utf-8' if you need special characters (diacritical marks, emoji),
    #             +:date+ - time the message will be sent (accepted formats: ISO-8601, unix epoch)
    def add_message(recipient, message, reference = nil, options = {})
      raise ArgumentError, "`recipient` cannot be empty" if recipient.nil? || recipient.empty?
      raise ArgumentError, "`message` cannot be empty" if message.nil? || message.empty?

      message = { 'recipient' =>  recipient, 'message' => message }
      message['reference'] = reference if reference
      message['encoding'] = options[:encoding] if options.key?(:encoding)
      message['date'] = options[:date] if options.key?(:date)

      @messages << message
    end

    # Send messages stored in message queue.
    # +raises+:: _MprofiAuthError_, _MprofiNotFoundError_, _MprofiConnectionError_
    def send
      raise StandardError, 'Empty payload. Please use `add_message` first.' unless @messages.size > 0

      if send_bulk?
        operation = 'sendbulk'
        payload = { 'messages' => @messages }
      else
        operation = 'send'
        payload = @messages.first
      end

      request = create_request(operation, :post, payload.to_json)
      result = send_request(request)
      @messages.clear if @clear_messages

      if result.has_key?('result')
        return result['result']
      else
        return [result]
      end
    end

    # Check status of message with given id
    # +msg_id+:: message id
    #
    # +raises+:: _MprofiNotFound_ - if message id not found
    def get_status(msg_id)
      raise ArgumentError, '`msg_id` cannot be nil' if msg_id.nil?

      request = create_request('status', :get, "id=#{msg_id}")
      result = send_request(request)

      return result
    end

    # Set read timeout
    # +timeout+ - number of seconds
    def read_timeout=(timeout)
      @read_timeout = timeout
    end

    private

    def send_bulk? #:nodoc:
      @messages.size > 1
    end

    def create_request(operation, req_method = :get, body_or_query_string = nil) #:nodoc:
      uri = URI.parse([API_BASE_URL, API_VERSION, operation, ''].join('/'))

      case req_method
      when :post
        request = Net::HTTP::Post.new(uri)
        request.content_type = 'application/json'
        request.body = body_or_query_string
      when :get
        uri.query = body_or_query_string
        request = Net::HTTP::Get.new(uri)
      else
        raise ArgumentError, 'Method not supported'
      end

      request['Authorization'] = "Token #{@api_token}"

      return request
    end

    def send_request(request) #:nodoc:
      uri = request.uri
      begin
        http = Net::HTTP.new(uri.host, uri.port)
        http.proxy_address = @proxy_url if @proxy_url

        if uri.scheme == 'https'
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end

        http.read_timeout = @read_timeout unless @read_timeout.nil?

        result = http.request(request)
      rescue Exception => err
        raise MprofiConnectionError.new(err.message, err)
      end

      raise MprofiAuthError, 'Invalid API token' if result.is_a?(Net::HTTPUnauthorized)
      raise MprofiNotFoundError, 'Not found' if result.is_a?(Net::HTTPNotFound)
      raise MprofiConnectionError, "HTTP code: #{result.code}, result: #{result.body}" unless result.is_a?(Net::HTTPSuccess)

      return JSON.parse(result.body)
    end

  end

end
