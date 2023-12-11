require "uri"
require "json"
require "net/http"
require 'base64'

class Refund
  def perform(credit_cents, razorpay_payment_id, transaction_id)
    url = URI("https://api.razorpay.com/v1/payments/#{razorpay_payment_id}/refund")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE
    encoded_key = Base64.strict_encode64('rzp_test_NC0xogelGqrdPz:VLd5MQVv3yPzJ1LtvoiJMIru')
    authorization_header = "Basic #{encoded_key}"

    request = Net::HTTP::Post.new(url)
    request["Content-Type"] = "application/json"
    request["Authorization"] = authorization_header
    request.body = JSON.dump({
      "amount": credit_cents,
      "speed": "optimum"
    })

    response = https.request(request)
    response
  end
end

