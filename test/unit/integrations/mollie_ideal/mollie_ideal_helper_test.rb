# frozen_string_literal: true

require 'test_helper'

class MollieIdealHelperTest < Test::Unit::TestCase
  include OffsitePayments::Integrations

  def setup
    @required_options = {
      :account_name => "My shop",
      :description => 'Order #111',
      :amount => 500,
      :currency => 'EUR',
      :redirect_param => 'ideal_TESTNL99',
      :return_url => 'https://return.com'
    }

    @helper = MollieIdeal::Helper.new('order-500','1234567', @required_options)

    Mollie::API.stubs(:new).with('1234567').returns(@mock_api = mock())
  end

  def test_credential_based_url
    @mock_api.expects(:post_request)
      .with('payments', :amount => 500, :description => 'Order #111', :method => 'ideal', :issuer => 'ideal_TESTNL99', :redirectUrl => 'https://return.com', :metadata => {:order => 'order-500'})
      .returns(CREATE_PAYMENT_RESPONSE_JSON)

    assert_equal Hash.new, @helper.fields
    uri = @helper.credential_based_url

    assert_equal 'tr_djsfilasX', @helper.transaction_id
    assert_equal "https://www.mollie.nl/paymentscreen/ideal/testmode", uri
    assert_equal "20a5a25c2bce925b4fabefd0410927ca", @helper.fields['transaction_id']
    assert_equal "0148703115482464", @helper.fields['bank_trxid']
  end

  def test_credential_based_url_errors
    @mock_api.expects(:post_request)
      .with('payments', :amount => 500, :description => 'Order #111', :method => 'ideal', :issuer => 'ideal_TESTNL99', :redirectUrl => 'https://return.com', :metadata => {:order => 'order-500'})
      .raises(ActiveUtils::ResponseError.new(stub(:code => "403", :message => "Internal Server Error", :body => '{"error": {"message": "bleh"}}')))

    assert_raises ActionViewHelperError do
      @helper.credential_based_url
    end
  end

  def test_credential_based_url_server_errors
    @mock_api.expects(:post_request).raises(ActiveUtils::ResponseError.new(stub(:code => "503", :message => "Service Unavailable")))

    assert_raises ActionViewHelperError do
      @helper.credential_based_url
    end
  end

  def test_raises_without_required_options
    assert_raises(ArgumentError) { MollieIdeal::Helper.new('order-500','1234567', @required_options.merge(:redirect_param => nil)) }
    assert_raises(ArgumentError) { MollieIdeal::Helper.new('order-500','1234567', @required_options.merge(:return_url => nil)) }
    assert_raises(ArgumentError) { MollieIdeal::Helper.new('order-500','1234567', @required_options.merge(:description => nil)) }
  end

  def test_without_query_params
    @mock_api.expects(:post_request)
      .with('payments', :amount => 500, :description => 'Order #111', :method => 'ideal', :issuer => 'ideal_TESTNL99', :redirectUrl => 'https://return.com', :metadata => {:order => 'order-500'})
      .returns(RESPONSE_WITHOUT_PARAMS)

    uri = @helper.credential_based_url

    assert_equal 'tr_djsfilasX', @helper.transaction_id
    assert_equal "https://www.mollie.nl/paymentscreen/ideal/testmode", uri
    assert_equal 0, @helper.fields.length
  end

  CREATE_PAYMENT_RESPONSE_JSON = JSON.parse(<<-JSON)
    {
      "id":"tr_djsfilasX",
      "mode":"test",
      "createdDatetime":"2014-03-03T10:17:05.0Z",
      "status":"open",
      "amount":"500.00",
      "description":"My order description",
      "method":"ideal",
      "metadata":{
        "my_reference":"unicorn"
      },
      "details":null,
      "links":{
        "paymentUrl":"https://www.mollie.nl/paymentscreen/ideal/testmode?transaction_id=20a5a25c2bce925b4fabefd0410927ca&bank_trxid=0148703115482464",
        "redirectUrl":"https://example.com/return"
      }
    }
  JSON

  RESPONSE_WITHOUT_PARAMS = JSON.parse(<<-JSON)
    {
      "id":"tr_djsfilasX",
      "mode":"test",
      "createdDatetime":"2014-03-03T10:17:05.0Z",
      "status":"open",
      "amount":"500.00",
      "description":"My order description",
      "method":"ideal",
      "metadata":{
        "my_reference":"unicorn"
      },
      "details":null,
      "links":{
        "paymentUrl":"https://www.mollie.nl/paymentscreen/ideal/testmode",
        "redirectUrl":"https://example.com/return"
      }
    }
  JSON
end
