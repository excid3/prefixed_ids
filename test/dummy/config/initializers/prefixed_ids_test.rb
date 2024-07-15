# Largely copied from https://github.com/heartcombo/devise/blob/main/test/rails_app/config/boot.rb

module PrefixedIds
  module Test
    # Detection for minor differences between Rails versions in tests.

    def self.rails71_and_up?
      !rails70? && ::Rails::VERSION::MAJOR >= 7
    end

    def self.rails70_and_up?
      ::Rails::VERSION::MAJOR >= 7
    end

    def self.rails70?
      ::Rails.version.start_with? "7.0"
    end
  end
end
