module Rip::Utilities
  class Keyword
    attr_reader :name
    attr_reader :keyword

    def initialize(name, keyword = name)
      @name = name.to_sym
      @keyword = keyword.to_sym
    end

    def ==(other)
      keyword == other.keyword
    end
  end

  module Keywords
    def self.[](keyword)
      _keyword = keyword.to_sym
      all.detect { |keyword| keyword.keyword == _keyword }
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
      # make_keywords(:class, '->'.to_sym, '=>'.to_sym)
      [
        Keyword.new(:class),
        Keyword.new(:dash_rocket, '->'),
        Keyword.new(:fat_rocket, '=>')
      ]
    end

    def self.conditional
      make_keywords(:if, :unless, :switch, :case, :else)
    end

    def self.exiter
      make_keywords(:exit, :return, :throw, :break, :next)
    end

    def self.exceptional
      make_keywords(:try, :catch, :finally)
    end

    def self.reserved
      make_keywords(:from, :as, :join, :union, :on, :where, :order, :select, :limit, :take)
    end

    protected

    def self.make_keywords(*keywords)
      keywords.map { |keyword| Keyword.new(keyword) }
    end
  end
end
