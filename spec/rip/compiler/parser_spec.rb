require 'spec_helper'

describe Rip::Compiler::Parser do
  context 'some basics' do
    it 'parses an empty module' do
      expect(parser).to parse('').as('')
    end

    it 'recognizes comments' do
      expect(parser.comment).to parse('# this is a comment').as(:comment => ' this is a comment')
    end

    it 'recognizes various whitespace sequences' do
      {
        [' ', "\t", "\r", "\n", "\r\n"] => :whitespace,
        [' ', "\t\t"]                   => :whitespaces,
        ['', "\n", "\t\r"]              => :whitespaces?,
        [' ', "\t"]                     => :space,
        [' ', "\t\t", "  \t  \t  "]     => :spaces,
        ['', ' ', "  \t  \t  "]         => :spaces?,
        ["\n", "\r", "\r\n"]            => :line_break,
        ['', "\n", "\r\r"]              => :line_breaks
      }.each do |whitespaces, method|
        space_parser = parser.send(method)
        whitespaces.each do |space|
          expect(space_parser).to parse(space).as(space)
        end
      end
    end
  end

  describe '#parse' do
    it 'recognizes several statements together' do
      expected = [
        {
          :block_sequence => {
            :if_block => {
              :if => 'if',
              :argument => { :reference => 'true' },
              :body => [
                {
                  :operator_invocation => {
                    :operand => { :reference => 'lambda' },
                    :operator => { :reference => '=' },
                    :argument => {
                      :block => {
                        :lambda_dash => '->',
                        :body => [ {:comment => ' comment'} ]
                      }
                    }
                  }
                },
                {
                  :invocation => {
                    :reference => 'lambda',
                    :arguments => []
                  }
                }
              ]
            },
            :else_block => {
              :else => 'else',
              :body => [
                {
                  :operator_invocation => {
                    :operand => { :integer => '1' },
                    :operator => { :reference => '+' },
                    :argument => { :integer => '2' }
                  }
                }
              ]
            }
          }
        }
      ]

      expect(parser).to parse(<<-RIP).as(expected)
                              if (true) {
                                lambda = -> {
                                  # comment
                                }
                                lambda()
                              } else {
                                1 + 2
                              }
                              RIP
    end
  end

  describe '#reference' do
    it 'recognizes valid references, including predefined references' do
      [
        'name',
        'Person',
        '==',
        'save!',
        'valid?',
        'long_ref-name',
        # '*/-+<>&$~%',
        '*/-+&$~%',
        'one_9',
        'É¹ÇÊ‡É¹oÔ€uÉlâˆ€â„¢',
        'nilly',
        'nil',
        'true',
        'false',
        'Kernel',
        'returner'
      ].each do |reference|
        expect(parser.reference).to parse(reference).as(:reference => reference)
      end
    end

    it 'skips invalid references' do
      [
        'one.two',
        '999',
        '6teen',
        'rip rocks',
        'key:value'
      ].each do |non_reference|
        expect(parser.reference).to_not parse(non_reference)
      end
    end
  end

  describe '#expression' do
    context 'block' do
      it 'recognizes empty block' do
        expected = {
          :block_sequence => {
            :try_block => {
              :try => 'try',
              :body => []
            }
          }
        }
        expect(parser.expression).to parse('try {}').as(expected)
      end

      it 'recognizes block with argument' do
        expected = {
          :block_sequence => {
            :unless_block => {
              :unless => 'unless',
              :argument => { :string => rip_parsed_string('name') },
              :body => []
            },
            :else_block => {
              :else => 'else',
              :body => []
            }
          }
        }
        expect(parser.expression).to parse('unless (:name) {} else {}').as(expected)
      end

      it 'recognizes block with multiple arguments' do
        expected = {
          :class_block => {
            :class => 'class',
            :arguments => [
              { :reference => 'one' },
              { :reference => 'two' }
            ],
            :body => []
          }
        }
        expect(parser.expression).to parse('class (one, two) {}').as(expected)
      end

      it 'recognizes lambda with parameter and default parameter' do
        expected = {
          :lambda_block => {
            :fat_rocket => '=>',
            :required_parameters => [
              {
                :parameter => {:reference => 'platform'}
              }
            ],
            :optional_parameters => [
              {
                :parameter => {:reference => 'name'},
                :default_value => { :string => rip_parsed_string('rip') }
              }
            ],
            :body => []
          }
        }
        expect(parser.expression).to parse('=> (platform, name = :rip) {}').as(expected)
      end

      it 'recognizes blocks with block arguments' do
        expected = {
          :class_block => {
            :class => 'class',
            :arguments => [
              {
                :class_block => {
                  :class => 'class',
                  :arguments =>[],
                  :body => []
                }
              }
            ],
            :body => []
          }
        }
        expect(parser.expression).to parse('class (class () {}) {}').as(expected)
      end
    end

    context 'block body' do
      it 'recognizes comments inside block body' do
        expected = {
          :block_sequence => {
            :if_block => {
              :if => 'if',
              :argument => {:reference => 'true'},
              :body => [
                {:comment => ' comment'}
              ]
            }
          }
        }
        expect(parser.expression).to parse(<<-RIP.strip).as(expected)
                                           if (true) {
                                             # comment
                                           }
                                           RIP
      end

      it 'recognizes references inside block body' do
        expect(parser.expression).to parse('if (true) { name }').as(:block => {:if => 'if', :argument => {:reference => 'true'}, :body => [{:reference => 'name'}]})
      end

      it 'recognizes assignments inside block body' do
        expected = {
          :block => {
            :if => 'if',
            :argument => { :reference => 'true' },
            :body => [
              {
                :invocation => {
                  :operand => { :reference => 'x' },
                  :operator => { :reference => '=' },
                  :argument => { :string => rip_parsed_string('y') }
                }
              }
            ]
          }
        }
        expect(parser.expression).to parse('if (true) { x = :y }').as(expected)
      end

      it 'recognizes invocations inside block body' do
        expect(parser.expression).to parse('if (true) { run!() }').as(:block => {:if => 'if', :argument => {:reference => 'true'}, :body => [{:invocation => {:reference => 'run!', :arguments => []}}]})
      end

      it 'recognizes operator invocations inside block body' do
        expected = {
          :block => {
            :if => 'if',
            :argument => {:reference => 'true'},
            :body => [
              {
                :invocation => {
                  :operand => { :reference => 'steam' },
                  :operator => { :reference => 'will' },
                  :argument => { :string => rip_parsed_string('rise') }
                }
              }
            ]
          }
        }
        expect(parser.expression).to parse('if (true) { steam will :rise }').as(expected)
      end

      it 'recognizes literals inside block body' do
        expect(parser.expression).to parse('if (true) { `3 }').as(:block => {:if => 'if', :argument => {:reference => 'true'}, :body => [{:character => '3'}]})
      end

      it 'recognizes blocks inside block body' do
        expected = {
          :block => {
            :if => 'if',
            :argument => {:reference => 'true'},
            :body => [
              {
                :block => {
                  :unless => 'unless',
                  :argument => {:reference => 'false'},
                  :body => []
                }
              }
            ]
          }
        }
        expect(parser.expression).to parse('if (true) { unless (false) { } }').as(expected)
      end
    end

    it 'recognizes keyword' do
      expect(parser.expression).to parse('return;').as(:keyword => {:return => 'return'})
    end

    it 'recognizes keyword followed by phrase' do
      expect(parser.expression).to parse('exit 0').as(:keyword => {:exit => 'exit'}, :payload => {:integer => '0'})
    end

    it 'recognizes keyword followed by parenthesis around phrase' do
      expect(parser.expression).to parse('exit (0)').as(:keyword => {:exit => 'exit'}, :body => {:integer => '0'})
    end

    it 'recognizes list expression' do
      expect(parser.expression).to parse('[]').as(:list => [])
    end

    context 'invoking lambdas' do
      it 'recognizes lambda literal invocation' do
        expect(parser.expression).to parse('-> () {}()').as(:invocation => {:block => {:lambda_dash => '->', :parameters => [], :body => []}, :arguments => []})
      end

      it 'recognizes lambda reference invocation' do
        expect(parser.expression).to parse('full_name()').as(:invocation => {:reference => 'full_name', :arguments => []})
      end

      it 'recognizes lambda reference invocation arguments' do
        expected = {
          :invocation => {
            :reference => 'full_name',
            :arguments => [
              { :string => rip_parsed_string('Thomas') },
              { :string => rip_parsed_string('Ingram') }
            ]
          }
        }
        expect(parser.expression).to parse('full_name(:Thomas, :Ingram)').as(expected)
      end

      it 'recognizes operator invocation' do
        expect(parser.expression).to parse('2 + 2').as(:invocation => {:operand => {:integer => '2'}, :operator => {:reference => '+'}, :argument => {:integer => '2'}})
      end

      it 'recognizes assignment as an operator invocation' do
        expected = {
          :invocation => {
            :operand => { :reference => 'favorite_language' },
            :operator => { :reference => '=' },
            :argument => { :string => rip_parsed_string('rip') }
          }
        }
        expect(parser.expression).to parse('favorite_language = :rip').as(expected)
      end
    end

    context 'nested parenthesis' do
      it 'recognizes anything surrounded by parenthesis' do
        expect(parser.expression).to parse('(0)').as(:integer => '0')
      end

      it 'recognizes anything surrounded by parenthesis with crazy nesting' do
        expected = {
          :invocation => {
            :callable => { :reference => 'l' },
            :arguments => [
              {
                :operator_invocation => {
                  :operand => { :integer => '1' },
                  :operator => { :reference => '+' },
                  :argument => {
                    :operator_invocation => {
                      :operand => { :integer => '2' },
                      :operator => { :reference => '-' },
                      :argument => { :integer => '3' }
                    }
                  }
                }
              }
            ]
          }
        }
        expect(parser.expression).to parse('((((((l((1 + (((2 - 3)))))))))))').as(expected)
      end
    end

    context 'property chaining' do
      it 'recognizes chaining with properies and invocations' do
        expected = {
          :invocation => {
            :callable => {
              :property => {
                :object => {
                  :property => {
                    :object => {
                      :invocation => {
                        :callable => {
                          :property => {
                            :object => { :integer => '0' },
                            :reference => 'one'
                          }
                        },
                        :arguments => []
                      }
                    },
                    :reference => 'two'
                  }
                },
                :reference => 'three'
              }
            },
            :arguments => []
          }
        }
        expect(parser.expression).to parse('0.one().two.three()').as(expected)
      end

      it 'recognizes chaining off opererators' do
        # expected = {
        #   :invocation => {
        #     :callable => {
        #       :property => {
        #         :object => {
        #           :invocation => {
        #             :callable => {
        #               :property => {
        #                 :object => {
        #                   :integer => '1'
        #                 },
        #                 :reference => '-'
        #               }
        #             },
        #             :argument => { :integer => '2' }
        #           }
        #         },
        #         :reference => 'zero?'
        #       }
        #     },
        #     :arguments => []
        #   }
        # }
        expected = {
          :invocation => {
            :callable => {
              :property => {
                :object => {
                  :operator_invocation => {
                    :operand => { :integer => '1' },
                    :operator => { :reference => '-' },
                    :argument => { :integer => '2' }
                  }
                },
                :reference => 'zero?'
              }
            },
            :arguments => []
          }
        }
        expect(parser.expression).to parse('(1 - 2).zero?()').as(expected)
      end

      it 'recognizes chaining several opererators' do
        expected = {
          :operator_invocation => {
            :operand => {
              :operator_invocation => {
                :operand => {
                  :operator_invocation => {
                    :operand => { :integer => '1' },
                    :operator => '+',
                    :argument => { :integer => '2' }
                  }
                },
                :operator => '+',
                :argument => { :integer => '3' }
              }
            },
            :operator => '+',
            :argument => { :integer => '4' }
          }
        }
        expect(parser.expression).to parse('1 + 2 + 3 + 4').as(expected)
      end
    end

    context 'atomic literals' do
      it 'recognizes numbers' do
        expect(parser.expression).to parse('42').as(:integer => '42')
        expect(parser.expression).to parse('4.2').as(:decimal => '4.2')
        expect(parser.expression).to parse('-3').as(:sign => '-', :integer => '3')
        expect(parser.expression).to parse('123_456_789').as(:integer => '123_456_789')
      end

      it 'recognizes characters' do
        expect(parser.expression).to parse('`9').as(:character => '9')
        expect(parser.expression).to parse('`f').as(:character => 'f')
        expect(parser.expression).to parse('`\n').as(:character => { :escaped_any => 'n' })
      end

      it 'recognizes strings' do
        expect(parser.expression).to parse(':0').as(:string => [{:raw_string => '0'}])
        expect(parser.expression).to parse(':on\e').as(:string => [{:raw_string=>'o'}, {:raw_string => 'n'}, {:escaped_any => 'e'}])
        expect(parser.expression).to parse('\'two\'').as(:string => [{:raw_string => 't'}, {:raw_string => 'w'}, {:raw_string => 'o'}])
        expect(parser.expression).to parse('"three"').as(:string => [{:raw_string => 't'}, {:raw_string => 'h'}, {:raw_string => 'r'}, {:raw_string => 'e'}, {:raw_string => 'e'}])
      end

      # it 'recognizes heredocs' do
      #   expect(parser.expression).to parse(<<-RIP.split("\n").map(&:strip).join("\n")).as(:here_doc_start => 'HERE_DOC', :string => "here docs are good for multi-line strings\n", :here_doc_end => 'HERE_DOC')
      #                                      <<HERE_DOC
      #                                      here docs are good for multi-line strings
      #                                      HERE_DOC
      #                                      RIP
      # end

      # it 'recognizes heredocs with interpolation' do
      #   expect(parser.expression).to parse(<<-RIP.split("\n").map(&:strip).join("\n")).as(:here_doc_start => 'HERE_DOC', :string => "here docs are good for multi-line strings\n", :here_doc_end => 'HERE_DOC')
      #                                      <<HERE_DOC
      #                                      here docs are good for multi-line #{strings}
      #                                      HERE_DOC
      #                                      RIP
      # end

      it 'recognizes interpolation in double-quoted strings' do
        expected = {
          :string => rip_parsed_string('hello, ') + [{ :interpolation => [{ :reference => 'world' }] }]
        }
        expect(parser.expression).to parse('"hello, #{world}"').as(expected)
      end

      it 'recognizes regular expressions' do
        expect(parser.expression).to parse('/hello/').as(:regex => [{:raw_regex => 'h'}, {:raw_regex => 'e'}, {:raw_regex => 'l'}, {:raw_regex => 'l'}, {:raw_regex => 'o'}])
      end

      it 'recognizes interpolation in regular expression' do
        expect(parser.expression).to parse('/he#{ll}o/').as(:regex => [{:raw_regex => 'h'}, {:raw_regex => 'e'}, {:interpolation => [{:reference => 'll'}]}, {:raw_regex => 'o'}])
      end
    end

    context 'molecular literals' do
      it 'recognizes key-value pairs' do
        expected = {
          :key => { :integer => '5' },
          :value => { :string => rip_parsed_string('five') }
        }
        expect(parser.expression).to parse('5: \'five\'').as(expected)
        expect(parser.expression).to parse('Exception: e').as(:key => {:reference => 'Exception'}, :value => {:reference => 'e'})
      end

      it 'recognizes ranges' do
        expect(parser.expression).to parse('1..3').as(:start => {:integer => '1'}, :end => {:integer => '3'}, :exclusivity => nil)
        expect(parser.expression).to parse('1...age').as(:start => {:integer => '1'}, :end => {:reference => 'age'}, :exclusivity => '.')
      end

      it 'recognizes hashes' do
        expect(parser.expression).to parse('{}').as(:hash => [])

        expected_2 = {
          :hash => [
            {
              :key => { :string => rip_parsed_string('name')},
              :value => { :string => rip_parsed_string('Thomas') }
            }
          ]
        }
        expect(parser.expression).to parse('{:name: :Thomas}').as(expected_2)

        expected_3 = {
          :hash => [
            {
              :key => { :string => rip_parsed_string('age') },
              :value => { :integer => '31' }
            },
            {
              :key => { :string => rip_parsed_string('name') },
              :value => { :string => rip_parsed_string('Thomas') }
            }
          ]
        }
        expect(parser.expression).to parse(<<-RIP.strip).as(expected_3)
                                           {
                                             :age: 31,
                                             :name: :Thomas
                                           }
                                           RIP
      end

      it 'recognizes lists' do
        expect(parser.expression).to parse('[]').as(:list => [])

        expected_2 = {
          :list => [
            { :string => rip_parsed_string('Thomas') }
          ]
        }
        expect(parser.expression).to parse('[:Thomas]').as(expected_2)

        expected_3 = {
          :list => [
            { :integer => '31' },
            { :string => rip_parsed_string('Thomas') }
          ]
        }
        expect(parser.expression).to parse(<<-RIP.strip).as(expected_3)
                                           [
                                             31,
                                             :Thomas
                                           ]
                                           RIP
      end
    end
  end
end
