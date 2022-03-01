# frozen_string_literal: true

require 'test_helper'

class NochexModuleTest < Test::Unit::TestCase
  include OffsitePayments::Integrations

  def test_notification_method
    assert_instance_of Nochex::Notification, Nochex.notification('name=cody', {})
  end

  def test_return_method
    assert_instance_of Nochex::Return, Nochex.return('name=cody', {})
  end
end
