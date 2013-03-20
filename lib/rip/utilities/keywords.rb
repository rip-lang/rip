module Rip::Utilities
  module Keywords
    class Keyword < Struct.new(:name, :keyword, :rule)
      def initialize(name, keyword = name, rule = name)
        super name, keyword, "#{rule}_keyword".to_sym
      end
    end

    def self.all
      [
        object,
        conditional,
        exiter,
        exceptional,
        reserved
      ].flatten
    end

    def self.object
      [
        Keyword.new(:class),
        Keyword.new(:lambda_dash, '->'),
        Keyword.new(:lambda_fat, '=>')
      ]
    end

    def self.conditional
      make_keywords :if, :unless, :switch, :case, :else
    end

    def self.exiter
      make_keywords :exit, :return, :throw, :break, :next
    end

    def self.exceptional
      make_keywords :try, :catch, :finally
    end

    def self.reserved
      make_keywords :from, :as, :join, :union, :on, :where, :order, :select, :limit, :take
    end

    protected

    def self.make_keywords(*keywords)
      keywords.map { |keyword| Keyword.new(keyword) }
    end
  end
end
