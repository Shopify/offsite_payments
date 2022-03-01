# frozen_string_literal: true

require 'test_helper'

class Ipay88NotificationTest < Test::Unit::TestCase
  include OffsitePayments::Integrations

  def setup
    @ipay88 = build_notification(http_raw_data)
  end

  def test_accessors
    assert_equal "ipay88merchcode",              @ipay88.account
    assert_equal 6,                              @ipay88.payment
    assert_equal "order-500",                    @ipay88.item_id
    assert_equal "1523.00",                      @ipay88.gross
    assert_equal "MYR",                          @ipay88.currency
    assert_equal "Remarkable",                   @ipay88.remark
    assert_equal "12345",                        @ipay88.transaction_id
    assert_equal "auth123",                      @ipay88.auth_code
    assert_equal "Completed",                    @ipay88.status
    assert_equal "Invalid merchant",             @ipay88.error
    assert_equal "qRkTjHm5O9RXD8/0S/EYKJ7U8y0=", @ipay88.signature
  end

  def test_secure_request
    assert @ipay88.secure?
  end

  def test_success
    assert @ipay88.success?
  end

  def test_insecure_request
    assert !build_notification(http_raw_data(:invalid_sig)).secure?
  end

  def test_acknowledge
    params = parameterize(payload)
    @ipay88.expects(:ssl_post).with(Ipay88.requery_url, params,
      { "Content-Length" => params.size.to_s, "User-Agent" => "Active Merchant -- http://activemerchant.org" }
    ).returns("00")

    assert @ipay88.acknowledge
  end

  def test_unsuccessful_acknowledge_due_to_signature
    ipay = build_notification(http_raw_data(:invalid_sig))
    assert !ipay.acknowledge
  end

  def test_unsuccessful_acknowledge_due_to_requery
    params = parameterize(payload)
    @ipay88.expects(:ssl_post).with(Ipay88.requery_url, params,
      { "Content-Length" => params.size.to_s, "User-Agent" => "Active Merchant -- http://activemerchant.org" }
    ).returns("Invalid parameters")
    assert !@ipay88.acknowledge
  end

  def test_successful_acknowledge_on_cancellation
    ipay = build_notification(http_raw_data(:payment_cancelled))
    assert ipay.acknowledge
  end

  def test_unsuccessful_acknowledge_due_to_missing_amount
    ipay = build_notification(http_raw_data(:missing_amount))
    assert !ipay.acknowledge
  end

  def test_gross_strips_commas
    @ipay88.stubs(:params).returns("Amount" => "23,123.00")
    assert_equal "23123.00", @ipay88.gross

    @ipay88.stubs(:params).returns("Amount" => "1,123,123.00")
    assert_equal "1123123.00", @ipay88.gross
  end

  private
  def http_raw_data(mode=:success)
    base = { "MerchantCode" => "ipay88merchcode",
             "PaymentId"    =>  6,
             "RefNo"        =>  "order-500",
             "Amount"       =>  "1,523.00",
             "Currency"     =>  "MYR",
             "Remark"       =>  "Remarkable",
             "TransId"      =>  "12345",
             "AuthCode"     =>  "auth123",
             "Status"       =>  1,
             "ErrDesc"      =>  "Invalid merchant" }

    case mode
    when :success
      parameterize(base.merge("Signature" => "qRkTjHm5O9RXD8/0S/EYKJ7U8y0="))
    when :invalid_sig
      parameterize(base.merge("Signature" => "hacked"))
    when :payment_cancelled
      parameterize(base.merge("Status" => 0, "Signature" => "dzn4gOE2R5Jlzr6fs6nz418LsU4="))
    when :missing_amount
      parameterize(base.except("Amount"))
    else
      ""
    end
  end

  def payload
    { "MerchantCode" => "ipay88merchcode", "RefNo" => "order-500", "Amount" => "1523.00" }
  end

  def parameterize(params)
    params.reject{|k, v| v.blank?}.keys.sort.collect { |key| "#{key}=#{CGI.escape(params[key].to_s)}" }.join("&")
  end

  def build_notification(data)
    Ipay88::Notification.new(data, :credential2 => "apple")
  end
end
