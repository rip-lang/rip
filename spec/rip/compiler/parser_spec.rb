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
    let(:rip) do
      strip_heredoc(<<-RIP)
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
                    :callable => { :reference => 'lambda' },
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

      expect(parser).to parse(rip).as(expected)
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
      recognizes_as_expected 'empty block' do
        let(:rip) { 'try {}' }
        let(:expected) do
          {
            :block_sequence => {
              :try_block => {
                :try => 'try',
                :body => []
              }
            }
          }
        end
      end

      recognizes_as_expected 'block with argument' do
        let(:rip) { 'unless (:name) {} else {}' }
        let(:expected) do
          {
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
        end
      end

      recognizes_as_expected 'block with multiple arguments' do
        let(:rip) { 'class (one, two) {}' }
        let(:expected) do
          {
            :class_block => {
              :class => 'class',
              :arguments => [
                { :reference => 'one' },
                { :reference => 'two' }
              ],
              :body => []
            }
          }
        end
      end

      recognizes_as_expected 'lambda with parameter and default parameter' do
        let(:rip) { '=> (platform, name = :rip) {}' }
        let(:expected) do
          {
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
        end
      end

      recognizes_as_expected 'blocks with block arguments' do
        let(:rip) { 'class (class () {}) {}' }
        let(:expected) do
          {
            :class_block => {
              :class => 'class',
              :arguments => [
                {
                  :class_block => {
                    :class => 'class',
                    :arguments => [],
                    :body => []
                  }
                }
              ],
              :body => []
            }
          }
        end
      end
    end

    context 'block body' do
      recognizes_as_expected 'comments inside block body' do
        let(:rip) do
          <<-RIP
          if (true) {
            # comment
          }
          RIP
        end
        let(:expected) do
          {
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
        end
      end

      recognizes_as_expected 'references inside block body' do
        let(:rip) { 'if (true) { name }' }
        let(:expected) do
          {
            :block_sequence => {
              :if_block => {
                :if => 'if',
                :argument => { :reference => 'true' },
                :body => [
                  { :reference => 'name' }
                ]
              }
            }
          }
        end
      end

      recognizes_as_expected 'assignments inside block body' do
        let(:rip) { 'if (true) { x = :y }' }
        let(:expected) do
          {
            :block_sequence => {
              :if_block => {
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
          }
        end
      end

      recognizes_as_expected 'invocations inside block body' do
        let(:rip) { 'if (true) { run!() }' }
        let(:expected) do
          {
            :block_sequence => {
              :if_block => {
                :if => 'if',
                :argument => { :reference => 'true' },
                :body => [
                  {
                    :invocation => {
                      :callable => { :reference => 'run!' },
                      :arguments => []
                    }
                  }
                ]
              }
            }
          }
        end
      end

      recognizes_as_expected 'operator invocations inside block body' do
        let(:rip) { 'if (true) { steam will :rise }' }
        let(:expected) do
          {
            :block_sequence => {
              :if_block => {
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
          }
        end
      end

      recognizes_as_expected 'literals inside block body' do
        let(:rip) { 'if (true) { `3 }' }
        let(:expected) do
          {
            :block_sequence => {
              :if_block => {
                :if => 'if',
                :argument => { :reference => 'true' },
                :body => [
                  { :character => '3' }
                ]
              }
            }
          }
        end
      end

      recognizes_as_expected 'blocks inside block body' do
        let(:rip) { 'if (true) { unless (false) { } }' }
        let(:expected) do
          {
            :block_sequence => {
              :if_block => {
                :if => 'if',
                :argument => {:reference => 'true'},
                :body => [
                  {
                    :block_sequence => {
                      :unless_block => {
                        :unless => 'unless',
                        :argument => {:reference => 'false'},
                        :body => []
                      }
                    }
                  }
                ]
              }
            }
          }
        end
      end
    end

    recognizes_as_expected 'keyword' do
      let(:rip) { 'return;' }
      let(:expected) do
        {
          :keyword => { :return => 'return' }
        }
      end
    end

    recognizes_as_expected 'keyword followed by phrase' do
      let(:rip) { 'exit 0' }
      let(:expected) do
        {
          :keyword => { :exit => 'exit' },
          :payload => { :integer => '0' }
        }
      end
    end

    recognizes_as_expected 'keyword followed by parenthesis around phrase' do
      let(:rip) { 'exit (0)' }
      let(:expected) do
        {
          :keyword => { :exit => 'exit' },
          :payload => { :integer => '0' }
        }
      end
    end

    context 'invoking lambdas' do
      recognizes_as_expected 'lambda literal invocation' do
        let(:rip) { '-> () {}()' }
        let(:expected) do
          {
            :invocation => {
              :callable => {
                :lambda_block => {
                  :lambda_dash => '->',
                  :parameters => [],
                  :body => []
                },
                :arguments => []
              }
            }
          }
        end
      end

      recognizes_as_expected 'lambda reference invocation' do
        let(:rip) { 'full_name()' }
        let(:expected) do
          {
            :invocation => {
              :callable => { :reference => 'full_name' },
              :arguments => []
            }
          }
        end
      end

      recognizes_as_expected 'lambda reference invocation arguments' do
        let(:rip) { 'full_name(:Thomas, :Ingram)' }
        let(:expected) do
          {
            :invocation => {
              :callable => { :reference => 'full_name' },
              :arguments => [
                { :string => rip_parsed_string('Thomas') },
                { :string => rip_parsed_string('Ingram') }
              ]
            }
          }
        end
      end

      recognizes_as_expected 'operator invocation' do
        let(:rip) { '2 + 2' }
        let(:expected) do
          {
            :operator_invocation => {
              :operand => { :integer => '2' },
              :operator => { :reference => '+' },
              :argument => { :integer => '2' }
            }
          }
        end
      end

      recognizes_as_expected 'assignment as an operator invocation' do
        let(:rip) { 'favorite_language = :rip' }
        let(:expected) do
          {
            :invocation => {
              :operand => { :reference => 'favorite_language' },
              :operator => { :reference => '=' },
              :argument => { :string => rip_parsed_string('rip') }
            }
          }
        end
      end
    end

    context 'nested parenthesis' do
      recognizes_as_expected 'anything surrounded by parenthesis' do
        let(:rip) { '(0)' }
        let(:expected) do
          { :integer => '0' }
        end
      end

      recognizes_as_expected 'anything surrounded by parenthesis with crazy nesting' do
        let(:rip) { '((((((l((1 + (((2 - 3)))))))))))' }
        let(:expected) do
          {
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
        end
      end
    end

    context 'property chaining' do
      recognizes_as_expected 'chaining with properies and invocations' do
        let(:rip) { '0.one().two.three()' }
        let(:expected) do
          {
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
        end
      end

      recognizes_as_expected 'chaining off opererators' do
        let(:rip) { '(1 - 2).zero?()' }
        # let(:expected) do
        #   {
        #     :invocation => {
        #       :callable => {
        #         :property => {
        #           :object => {
        #             :invocation => {
        #               :callable => {
        #                 :property => {
        #                   :object => {
        #                     :integer => '1'
        #                   },
        #                   :reference => '-'
        #                 }
        #               },
        #               :argument => { :integer => '2' }
        #             }
        #           },
        #           :reference => 'zero?'
        #         }
        #       },
        #       :arguments => []
        #     }
        #   }
        # end
        let(:expected) do
          {
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
        end
      end

      recognizes_as_expected 'chaining several opererators' do
        let(:rip) { '1 + 2 + 3 + 4' }
        let(:expected) do
          {
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
        end
      end
    end

    context 'atomic literals' do
      recognizes_as_expected 'integer' do
        let(:rip) { '42' }
        let(:expected) do
          { :integer => '42' }
        end
      end

      recognizes_as_expected 'decimal' do
        let(:rip) { '4.2' }
        let(:expected) do
          { :decimal => '4.2' }
        end
      end

      recognizes_as_expected 'negative number' do
        let(:rip) { '-3' }
        let(:expected) do
          { :sign => '-', :integer => '3' }
        end
      end

      recognizes_as_expected 'large number' do
        let(:rip) { '123_456_789' }
        let(:expected) do
          { :integer => '123_456_789' }
        end
      end

      recognizes_as_expected 'regular character' do
        let(:rip) { '`9' }
        let(:expected) do
          { :character => '9' }
        end
      end

      recognizes_as_expected 'escaped character' do
        let(:rip) { '`\n' }
        let(:expected) do
          { :character => { :escaped_any => 'n' } }
        end
      end

      recognizes_as_expected 'symbol string' do
        let(:rip) { ':0' }
        let(:expected) do
          {
            :string => [{ :raw_string => '0' }]
          }
        end
      end

      recognizes_as_expected 'symbol string with escape' do
        let(:rip) { ':on\e' }
        let(:expected) do
          {
            :string => [
              { :raw_string=>'o' },
              { :raw_string => 'n' },
              { :escaped_any => 'e' }
            ]
          }
        end
      end

      recognizes_as_expected 'single-quoted string' do
        let(:rip) { '\'two\'' }
        let(:expected) do
          {
            :string => [
              { :raw_string => 't' },
              { :raw_string => 'w' },
              { :raw_string => 'o' }
            ]
          }
        end
      end

      recognizes_as_expected 'double-quoted string' do
        let(:rip) { '"three"' }
        let(:expected) do
          {
            :string => [
              { :raw_string => 't' },
              { :raw_string => 'h' },
              { :raw_string => 'r' },
              { :raw_string => 'e' },
              { :raw_string => 'e' }
            ]
          }
        end
      end

      recognizes_as_expected 'double-quoted string with interpolation' do
        let(:rip) { '"hello, #{world}"' }
        let(:expected) do
          {
            :string => rip_parsed_string('hello, ') + [{ :interpolation => [{ :reference => 'world' }] }]
          }
        end
      end

      # recognizes_as_expected 'heredoc' do
      #   let(:rip) do
      #     <<-RIP
      #       <<HERE_DOC
      #       here docs are good for multi-line strings
      #       HERE_DOC
      #     RIP
      #   end
      #   let(:expected) do
      #     {
      #       :here_doc_start => 'HERE_DOC',
      #       :string => rip_parsed_string("here docs are good for multi-line strings\n"),
      #       :here_doc_end => 'HERE_DOC'
      #     }
      #   end
      # end

      # recognizes_as_expected 'heredoc with interpolation' do
      #   let(:rip) do
      #     <<-RIP
      #       <<HERE_DOC
      #       here docs are good for multi-line #{strings}
      #       HERE_DOC
      #     RIP
      #   end
      #   let(:expected) do
      #     {
      #       :here_doc_start => 'HERE_DOC',
      #       :string => rip_parsed_string('here docs are good for multi-line ') + [{ :interpolation => [{ :reference => 'strings' }] }] + rip_parsed_string("\n")
      #       :here_doc_end => 'HERE_DOC'
      #     }
      #   end
      # end

      recognizes_as_expected 'regular expression' do
        let(:rip) { '/hello/' }
        let(:expected) do
          {
            :regex => [
              { :raw_regex => 'h' },
              { :raw_regex => 'e' },
              { :raw_regex => 'l' },
              { :raw_regex => 'l' },
              { :raw_regex => 'o' }
            ]
          }
        end
      end

      recognizes_as_expected 'regular expression with interpolation' do
        let(:rip) { '/he#{ll}o/' }
        let(:expected) do
          {
            :regex => [
              { :raw_regex => 'h' },
              { :raw_regex => 'e' },
              { :interpolation => [{ :reference => 'll' }] },
              { :raw_regex => 'o' }
            ]
          }
        end
      end
    end

    context 'molecular literals' do
      recognizes_as_expected 'key-value pairs' do
        let(:rip) { '5: \'five\'' }
        let(:expected) do
          {
            :key_value_pair => {
              :key => { :integer => '5' },
              :value => { :string => rip_parsed_string('five') }
            }
          }
        end
      end

      recognizes_as_expected 'ranges' do
        let(:rip) { '1..3' }
        let(:expected) do
          {
            :range => {
              :start => { :integer => '1' },
              :end => { :integer => '3' },
              :exclusivity => nil
            }
          }
        end
      end

      recognizes_as_expected 'exclusive ranges' do
        let(:rip) { '1...age' }
        let(:expected) do
          {
            :range => {
              :start => { :integer => '1' },
              :end => { :reference => 'age' },
              :exclusivity => '.'
            }
          }
        end
      end

      recognizes_as_expected 'empty hash' do
        let(:rip) { '{}' }
        let(:expected) do
          { :hash => [] }
        end
      end

      recognizes_as_expected 'hash with content' do
        let(:rip) do
          <<-RIP
            {
              :age: 31,
              :name: :Thomas
            }
          RIP
        end
        let(:expected) do
          {
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
        end
      end

      recognizes_as_expected 'empty list' do
        let(:rip) { '[]' }
        let(:expected) do
          { :list => [] }
        end
      end

      recognizes_as_expected 'list with content' do
        let(:rip) do
          <<-RIP
            [
              31,
              :Thomas
            ]
          RIP
        end
        let(:expected) do
          {
            :list => [
              { :integer => '31' },
              { :string => rip_parsed_string('Thomas') }
            ]
          }
        end
      end
    end
  end
end
