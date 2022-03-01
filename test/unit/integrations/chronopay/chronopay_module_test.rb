# frozen_string_literal: true

require 'test_helper'

class ChronopayModuleTest < Test::Unit::TestCase
  include OffsitePayments::Integrations

  def test_notification_method
    assert_instance_of Chronopay::Notification, Chronopay.notification('name=cody', {})
  end

  def test_return_method
    assert_instance_of Chronopay::Return, Chronopay.return('name=cody', {})
  end
end
