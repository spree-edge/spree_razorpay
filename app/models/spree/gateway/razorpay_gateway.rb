require 'razorpay'

module Spree
  class Gateway::RazorpayGateway < Gateway
    preference :key_id, :string
    preference :key_secret, :string
    preference :merchant_name, :string
    preference :merchant_description, :text
    preference :merchant_address, :string
    preference :theme_color, :string, default: '#F37254'


    def supports?(_source)
      true
    end

    def provider_class
      self
    end

    def provider
      Razorpay.setup(
        preferred_key_id,
        preferred_key_secret
      )
    end

    def credit(credit_cents, payment_id, transaction_id, originator)
      razorpay_payment_id = Spree::Payment.find(payment_id).source.razorpay_payment_id
      response = RazorpayRefund.new.perform(credit_cents, razorpay_payment_id, transaction_id)
       ActiveMerchant::Billing::Response.new(
        success(response),
        response, 
        error_code: success(response) ? nil : "error"
       )
    end

    def success(response)
      response.code == "200"
    end

    def auto_capture?
      true
    end

    def method_type
      'razorpay'
    end

    def purchase(_amount, _transaction_details, _gateway_options = {})
      ActiveMerchant::Billing::Response.new(true, 'razorpay success')
    end

    def request_type
      'DEFAULT'
    end
  end
end
