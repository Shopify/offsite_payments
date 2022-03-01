# frozen_string_literal: true

require 'test_helper'

class DotpayModuleTest < Test::Unit::TestCase
  include OffsitePayments::Integrations

  def test_notification_method
    assert_instance_of Dotpay::Notification, Dotpay.notification('name=cody', :pin => '1234567890')
  end

  def test_return
    assert_instance_of Dotpay::Return, Dotpay.return("name=me", {})
  end
end
