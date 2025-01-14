require "uri"
require "json"
require "net/http"
require 'base64'

class RazorpayRefund
  def perform(credit_cents, razorpay_payment_id)
    url = URI("https://api.razorpay.com/v1/payments/#{razorpay_payment_id}/refund")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE
    gateway = Spree::Gateway.find_by(type:"Spree::Gateway::RazorpayGateway")
    key_id = gateway.preferred_key_id
    key_secret = gateway.preferred_key_secret
    encoded_key = Base64.strict_encode64("#{key_id}:#{key_secret}")
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

