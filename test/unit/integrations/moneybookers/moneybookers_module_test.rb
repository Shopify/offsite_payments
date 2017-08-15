require 'test_helper'

class MoneybookersModuleTest < Test::Unit::TestCase
  include OffsitePayments::Integrations

  def test_notification_method
    assert_instance_of Moneybookers::Notification, Moneybookers.notification('name=cody', :credential2 => 'secret')
  end

  def test_service_url
    url = 'https://www.skrill.com'
    assert_equal url, Moneybookers.service_url
  end
end
