module Rip::Nodes
  class Keyword < Base
    attr_reader :name

    def initialize(name)
      @name = name.to_sym
    end

    def ==(other)
      name == other.name
    end

    def self.[](word)
      _word = word.to_sym
      all.detect { |keyword| keyword.name == _word }
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
      make_keywords(:class, '->'.to_sym, '=>'.to_sym)
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
      keywords.map { |keyword| new(keyword) }
    end
  end
end
