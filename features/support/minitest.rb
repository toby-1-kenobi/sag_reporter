require 'minitest'
require "minitest/rails/capybara"
require "minitest/spec"

module MiniTestAssertions

  def self.extended(base)
    base.extend(MiniTest::Assertions)
    base.assertions = 0
  end

  attr_accessor :assertions
  
end

World(MiniTestAssertions)