# frozen_string_literal: true

require 'test_helper'

class WirecardCheckoutPageModuleTest < Test::Unit::TestCase
  include OffsitePayments::Integrations

  def test_notification_method
    assert_instance_of WirecardCheckoutPage::Notification, WirecardCheckoutPage.notification('name=cody', {})
  end
end
