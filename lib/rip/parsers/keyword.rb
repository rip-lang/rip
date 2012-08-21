# encoding: utf-8

require 'parslet'

require 'rip'

module Rip::Parsers
  module Keyword
    include Parslet

    def self.make_keywords(*keywords)
      keywords.each do |keyword|
        name = "#{keyword}_keyword".to_sym
        rule(name) { str(keyword).as(name) }
      end
    end

    #---------------------------------------------

    rule(:keyword) { object_keyword | conditional_keyword | exit_keyword | exception_keyword | reserved_keyword }

    #---------------------------------------------

    rule(:object_keyword) { class_keyword | lambda_keyword }

    make_keywords :class

    rule(:lambda_keyword) { (str('->') | str('=>')).as(:lambda_keyword) }

    #---------------------------------------------

    rule(:conditional_keyword) { if_keyword | unless_keyword | switch_keyword | case_keyword | else_keyword }

    make_keywords :if, :unless, :switch, :case, :else

    #---------------------------------------------

    rule(:exiter) { exit_keyword | return_keyword | throw_keyword | break_keyword | next_keyword }

    make_keywords :exit, :return, :throw, :break, :next

    #---------------------------------------------

    rule(:exception_keyword) { try_keyword | catch_keyword | finally_keyword }

    make_keywords :try, :catch, :finally

    #---------------------------------------------

    rule(:reserved_keyword) { from_keyword | as_keyword | join_keyword | union_keyword | on_keyword | where_keyword | order_keyword | select_keyword | limit_keyword | take_keyword }

    make_keywords :from, :as, :join, :union, :on, :where, :order, :select, :limit, :take
  end
end
