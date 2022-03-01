# frozen_string_literal: true

require 'test_helper'

class QuickpayModuleTest < Test::Unit::TestCase
  include OffsitePayments::Integrations

  def test_notification_method
    assert_instance_of Quickpay::Notification, Quickpay.notification('name=cody', {})
  end
end
