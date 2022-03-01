# frozen_string_literal: true

require 'test_helper'

class UniversalModuleTest < Test::Unit::TestCase
  include OffsitePayments::Integrations

  def test_notification
    assert_instance_of Universal::Notification, Universal.notification('name=zork')
  end

  def test_return
    assert_instance_of Universal::Return, Universal.return('name=zork')
  end

  def test_sign
    expected = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA256.new, 'zork', 'a1b2')
    assert_equal expected, Universal.sign({:b => '2', :a => '1'}, 'zork')
  end

end
