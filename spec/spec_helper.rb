require "pry-byebug"
require "simplecov"
require "timecop"
require "active_support"
require "active_support/core_ext"

require_relative "support/fixture"

SimpleCov.start do
  add_filter "/spec/"
  add_filter "/vendor/"
end if ENV["COVERAGE"] == "true"

require_relative "../lib/ofx"

ActiveSupport::JSON::Encoding.use_standard_json_time_format = true
ActiveSupport::JSON::Encoding.time_precision = 0

RSpec::Matchers.define :have_key do |key|
  match do |hash|
    hash.respond_to?(:keys) &&
    hash.keys.kind_of?(Array) &&
    hash.keys.include?(key)
  end
end

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  config.order = "random"
  config.raise_errors_for_deprecations!
end

