require "open-uri"
require "nokogiri"
require "bigdecimal"

require "kconv"
require "active_support/core_ext"
require "rest_client"
# require 'yajl'

require "ofx/errors"
require "ofx/parser"
require "ofx/parser/base"
require "ofx/parser/ofx102"
require "ofx/parser/ofx211"
require "ofx/base"
require "ofx/balance"
require "ofx/account"
require "ofx/accounts"
require "ofx/sign_on"
require "ofx/transaction"

def OFX(resource, &block)
  parser = OFX::Parser::Base.new(resource).parser

  if block_given?
    if block.arity == 1
      yield parser
    else
      parser.instance_eval(&block)
    end
  end

  parser
end
