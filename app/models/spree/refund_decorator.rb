module Spree
  module RefundDecorator
    def process!(credit_cents)
      response = if payment.payment_method.payment_profiles_supported?
                   payment.payment_method.credit(credit_cents, payment.source, payment.transaction_id, originator: self)
                 else
                   payment.payment_method.credit(credit_cents, payment.source.razorpay_payment_id, originator: self)
                 end

      unless response.success?
        Rails.logger.error(Spree.t(:gateway_error) + "  #{response.to_yaml}")
        text = response.params['message'] || response.params['response_reason_text'] || response.message
        raise Core::GatewayError, text
      end

      response
    rescue ActiveMerchant::ConnectionError => e
      Rails.logger.error(Spree.t(:gateway_error) + "  #{e.inspect}")
      raise Core::GatewayError, Spree.t(:unable_to_connect_to_gateway)
    end

    ::Spree::Refund.prepend self
  end
end
