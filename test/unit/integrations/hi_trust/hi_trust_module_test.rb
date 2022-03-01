# frozen_string_literal: true

require 'test_helper'

class HiTrustModuleTest < Test::Unit::TestCase
  include OffsitePayments::Integrations

  def test_notification_method
    assert_instance_of HiTrust::Notification, HiTrust.notification('name=cody', {})
  end

  def test_return_method
    assert_instance_of HiTrust::Return, HiTrust.return('name=cody', {})
  end
end
