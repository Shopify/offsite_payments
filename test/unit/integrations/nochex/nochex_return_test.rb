# frozen_string_literal: true

require 'test_helper'

class NochexReturnTest < Test::Unit::TestCase
  include OffsitePayments::Integrations

  def test_return
    r = Nochex::Return.new('')
    assert r.success?
  end
end
