require 'spec_helper'

describe Rip::Compiler::Parser do
  context 'some basics' do
    it 'parses an empty module' do
      expect(parser('')).to parse_as(:module => [])
    end

    it 'parses an empty string module' do
      expect(parser('       ')).to parse_as(:module => '       ')
    end

    it 'ignores comments as whitespace' do
      expect(parser('# this is a comment')).to parse_as(:module => '# this is a comment')
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
        ["\r\n\r\n", "\n\n"]            => :line_breaks,
        ['', "\r\n\r\n", "\n\n"]        => :line_breaks?
      }.each do |whitespaces, method|
        space_parser = parser(nil).send(method)
        whitespaces.each do |space|
          expect(space_parser).to parse(space).as(space)
        end
      end
    end

    context 'comma-separation' do
      let(:csv_parser) { parser(nil).send(:csv, parser(nil).send(:str, 'x').as(:x)).as(:csv) }
      let(:expected_x) { { :x => 'x' } }

      it 'recognizes comma-separated atoms' do
        expect(csv_parser).to parse('').as(:csv => [])
        expect(csv_parser).to parse('x').as(:csv => [expected_x])
        expect(csv_parser).to parse('x,x,x').as(:csv => [expected_x, expected_x, expected_x])
        expect(csv_parser).to_not parse('xx')
        expect(csv_parser).to_not parse('x,xx')
      end
    end
  end

  recognizes_as_expected 'several statements together' do
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
    let(:expected_raw) do
      {
        :module => [
          {
            :if_block => {
              :if => 'if',
              :argument => { :reference => 'true' },
              :location_body => '{',
              :body => [
                {
                  :atom => [
                    { :reference => 'lambda' },
                    {
                      :assignment => {
                        :location => '=',
                        :rhs => {
                          :dash_rocket => '->',
                          :location_body => '{',
                          :body => []
                        }
                      }
                    }
                  ]
                },
                {
                  :atom => [
                    { :reference => 'lambda' },
                    { :regular_invocation => { :location => '(', :arguments => [] } }
                  ]
                }
              ]
            },
            :else_block => {
              :else => 'else',
              :location_body => '{',
              :body => [
                {
                  :atom => [
                    { :integer => '1' },
                    {
                      :operator_invocation => {
                        :operator => '+',
                        :argument => { :integer => '2' }
                      }
                    }
                  ]
                }
              ]
            }
          }
        ]
      }
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
        '*-+&$~%',
        'one_9',
        'É¹ÇÊ‡É¹oÔ€uÉlâˆ€â„¢',
        'nilly',
        'nil',
        'true',
        'false',
        'Kernel',
        'returner'
      ].each do |reference|
        expect(parser(reference)).to parse_raw_as(:module => [ { :reference => reference } ])
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
        expect(parser(non_reference)).to_not parse_raw_as([ { :reference => non_reference } ])
      end
    end
  end

  describe '#property_name' do
    it 'recognizes special-case property names' do
      [
        '/',
        '<=>',
        '<',
        '<<',
        '<=',
        '>',
        '>>',
        '>=',
        '[]'
      ].each do |property_name|
        rip = "@.#{property_name}"
        expected = {
          :module => [
            {
              :object => { :reference => '@' },
              :location => '.',
              :property_name => property_name
            }
          ]
        }
        expect(parser(rip)).to parse_as(expected)
      end
    end
  end

  describe '#expression' do
    context 'block' do
      recognizes_as_expected 'empty block' do
        let(:rip) { 'try {}' }
        let(:expected_raw) do
          {
            :module => [
              {
                :try_block => {
                  :try => 'try',
                  :location_body => '{',
                  :body => []
                },
                :catch_blocks => []
              }
            ]
          }
        end
      end

      recognizes_as_expected 'block with argument' do
        let(:rip) { 'unless (:name) {} else {}' }
        let(:expected_raw) do
          {
            :module => [
              {
                :unless_block => {
                  :unless => 'unless',
                  :argument => {
                    :location => ':',
                    :string => rip_string_raw('name')
                  },
                  :location_body => '{',
                  :body => []
                },
                :else_block => {
                  :else => 'else',
                  :location_body => '{',
                  :body => []
                }
              }
            ]
          }
        end
      end

      recognizes_as_expected 'block with multiple arguments' do
        let(:rip) { 'class (one, two) {}' }
        let(:expected_raw) do
          {
            :module => [
              {
                :class => 'class',
                :arguments => [
                  { :reference => 'one' },
                  { :reference => 'two' }
                ],
                :location_body => '{',
                :body => []
              }
            ]
          }
        end
      end

      recognizes_as_expected 'class with no superclasses' do
        let(:rip) do
          <<-RIP
            class {
              # comment
            }
          RIP
        end
        let(:expected_raw) do
          {
            :module => [
              {
                :class => 'class',
                :location_body => '{',
                :body => []
              }
            ]
          }
        end
        let(:expected) do
          {
            :module => [
              {
                :class => 'class',
                :arguments => [],
                :location_body => '{',
                :body => []
              }
            ]
          }
        end
      end

      recognizes_as_expected 'lambda with no parameters' do
        let(:rip) { '-> {}' }
        let(:expected_raw) do
          {
            :module => [
              {
                :dash_rocket => '->',
                :location_body => '{',
                :body => []
              }
            ]
          }
        end
        let(:expected) do
          {
            :module => [
              {
                :dash_rocket => '->',
                :parameters => [],
                :location_body => '{',
                :body => []
              }
            ]
          }
        end
      end

      recognizes_as_expected 'lambda with multiple required parameters' do
        let(:rip) { '-> (one, two) {}' }
        let(:expected_raw) do
          {
            :module => [
              {
                :dash_rocket => '->',
                :parameters => [
                  { :reference => 'one' },
                  { :reference => 'two' }
                ],
                :location_body => '{',
                :body => []
              }
            ]
          }
        end
      end

      recognizes_as_expected 'lambda with multiple optional parameters' do
        let(:rip) { '-> (one = 1, two = 2) {}' }
        let(:expected_raw) do
          {
            :module => [
              {
                :dash_rocket => '->',
                :parameters => [
                  {
                    :lhs => { :reference => 'one' },
                    :location => '=',
                    :rhs => { :integer => '1' }
                  },
                  {
                    :lhs => { :reference => 'two' },
                    :location => '=',
                    :rhs => { :integer => '2' }
                  }
                ],
                :location_body => '{',
                :body => []
              }
            ]
          }
        end
      end

      recognizes_as_expected 'lambda with required parameter and optional parameter' do
        let(:rip) { '=> (platform, name = :rip) {}' }
        let(:expected_raw) do
          {
            :module => [
              {
                :fat_rocket => '=>',
                :parameters => [
                  { :reference => 'platform' },
                  {
                    :lhs => { :reference => 'name' },
                    :location => '=',
                    :rhs => {
                      :location => ':',
                      :string => rip_string_raw('rip')
                    }
                  }
                ],
                :location_body => '{',
                :body => []
              }
            ]
          }
        end
      end

      recognizes_as_expected 'lambda with multiple required parameter and multiple optional parameter' do
        let(:rip) { '-> (abc, xyz, one = 1, two = 2) {}' }
        let(:expected_raw) do
          {
            :module => [
              {
                :dash_rocket => '->',
                :parameters => [
                  { :reference => 'abc' },
                  { :reference => 'xyz' },
                  {
                    :lhs => { :reference => 'one' },
                    :location => '=',
                    :rhs => { :integer => '1' }
                  },
                  {
                    :lhs => { :reference => 'two' },
                    :location => '=',
                    :rhs => { :integer => '2' }
                  }
                ],
                :location_body => '{',
                :body => []
              }
            ]
          }
        end
      end

      recognizes_as_expected 'blocks with block arguments' do
        let(:rip) { 'class (class () {}) {}' }
        let(:expected_raw) do
          {
            :module => [
              {
                :class => 'class',
                :arguments => [
                  {
                    :class => 'class',
                    :arguments => [],
                    :location_body => '{',
                    :body => []
                  }
                ],
                :location_body => '{',
                :body => []
              }
            ]
          }
        end
      end

      recognizes_as_expected 'try-catch' do
        let(:rip) { 'try {} catch (Exception: e) {}' }
        let(:expected_raw) do
          {
            :module => [
              {
                :try_block => {
                  :try => 'try',
                  :location_body => '{',
                  :body => []
                },
                :catch_blocks => [
                  {
                    :catch => 'catch',
                    :argument => {
                      :atom => [
                        { :reference => 'Exception' },
                        {
                          :key_value_pair => {
                            :location => ':',
                            :value => { :reference => 'e' }
                          }
                        }
                      ]
                    },
                    :location_body => '{',
                    :body => []
                  }
                ]
              }
            ]
          }
        end
        let(:expected) do
          {
            :module => [
              {
                :try_block => {
                  :try => 'try',
                  :location_body => '{',
                  :body => []
                },
                :catch_blocks => [
                  {
                    :catch => 'catch',
                    :argument => {
                      :key => { :reference => 'Exception' },
                      :location => ':',
                      :value => { :reference => 'e' }
                    },
                    :location_body => '{',
                    :body => []
                  }
                ]
              }
            ]
          }
        end
      end

      recognizes_as_expected 'try-finally' do
        let(:rip) { 'try {} finally {}' }
        let(:expected) do
          {
            :module => [
              {
                :try_block => {
                  :try => 'try',
                  :location_body => '{',
                  :body => []
                },
                :catch_blocks => [],
                :finally_block => {
                  :finally => 'finally',
                  :location_body => '{',
                  :body => []
                }
              }
            ]
          }
        end
      end

      recognizes_as_expected 'try-catch-finally' do
        let(:rip) { 'try {} catch (Exception: e) {} finally {}' }
        let(:expected) do
          {
            :module => [
              {
                :try_block => {
                  :try => 'try',
                  :location_body => '{',
                  :body => []
                },
                :catch_blocks => [
                  {
                    :catch => 'catch',
                    :argument => {
                      :key => { :reference => 'Exception' },
                      :location => ':',
                      :value => { :reference => 'e' }
                    },
                    :location_body => '{',
                    :body => []
                  }
                ],
                :finally_block => {
                  :finally => 'finally',
                  :location_body => '{',
                  :body => []
                }
              }
            ]
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
        let(:expected_raw) do
          {
            :module => [
              {
                :if_block => {
                  :if => 'if',
                  :argument => { :reference => 'true' },
                  :location_body => '{',
                  :body => []
                }
              }
            ]
          }
        end
      end

      recognizes_as_expected 'references inside block body' do
        let(:rip) { 'if (true) { name }' }
        let(:expected_raw) do
          {
            :module => [
              {
                :if_block => {
                  :if => 'if',
                  :argument => { :reference => 'true' },
                  :location_body => '{',
                  :body => [
                    { :reference => 'name' }
                  ]
                }
              }
            ]
          }
        end
      end

      recognizes_as_expected 'assignments inside block body' do
        let(:rip) { 'if (true) { x = :y }' }
        let(:expected_raw) do
          {
            :module => [
              {
                :if_block => {
                  :if => 'if',
                  :argument => { :reference => 'true' },
                  :location_body => '{',
                  :body => [
                    {
                      :atom => [
                        { :reference => 'x' },
                        {
                          :assignment => {
                            :location => '=',
                            :rhs => {
                              :location => ':',
                              :string => rip_string_raw('y')
                            }
                          }
                        }
                      ]
                    }
                  ]
                }
              }
            ]
          }
        end
      end

      recognizes_as_expected 'invocations inside block body' do
        let(:rip) { 'if (true) { run!() }' }
        let(:expected_raw) do
          {
            :module => [
              {
                :if_block => {
                  :if => 'if',
                  :argument => { :reference => 'true' },
                  :location_body => '{',
                  :body => [
                    {
                      :atom => [
                        { :reference => 'run!' },
                        { :regular_invocation => { :location => '(', :arguments => [] } }
                      ]
                    }
                  ]
                }
              }
            ]
          }
        end
      end

      recognizes_as_expected 'operator invocations inside block body' do
        let(:rip) { 'if (true) { steam will :rise }' }
        let(:expected_raw) do
          {
            :module => [
              {
                :if_block => {
                  :if => 'if',
                  :argument => { :reference => 'true' },
                  :location_body => '{',
                  :body => [
                    {
                      :atom => [
                        { :reference => 'steam' },
                        {
                          :operator_invocation => {
                            :operator => 'will',
                            :argument => {
                              :location => ':',
                              :string => rip_string_raw('rise')
                            }
                          }
                        }
                      ]
                    }
                  ]
                }
              }
            ]
          }
        end
      end

      recognizes_as_expected 'literals inside block body' do
        let(:rip) { 'if (true) { `3 }' }
        let(:expected_raw) do
          {
            :module => [
              {
                :if_block => {
                  :if => 'if',
                  :argument => { :reference => 'true' },
                  :location_body => '{',
                  :body => [
                    {
                      :location => '`',
                      :character => '3'
                    }
                  ]
                }
              }
            ]
          }
        end
      end

      recognizes_as_expected 'blocks inside block body' do
        let(:rip) { 'if (true) { unless (false) { } }' }
        let(:expected_raw) do
          {
            :module => [
              {
                :if_block => {
                  :if => 'if',
                  :argument => { :reference => 'true' },
                  :location_body => '{',
                  :body => [
                    {
                      :unless_block => {
                        :unless => 'unless',
                        :argument => { :reference => 'false' },
                        :location_body => '{',
                        :body => []
                      }
                    }
                  ]
                }
              }
            ]
          }
        end
      end
    end

    recognizes_as_expected 'keyword' do
      let(:rip) { 'return;' }
      let(:expected_raw) do
        {
          :module => [
            { :return => 'return' }
          ]
        }
      end
    end

    recognizes_as_expected 'keyword followed by phrase' do
      let(:rip) { 'exit 0' }
      let(:expected_raw) do
        {
          :module => [
            {
              :exit => 'exit',
              :payload => { :integer => '0' }
            }
          ]
        }
      end
    end

    recognizes_as_expected 'keyword followed by parenthesis around phrase' do
      let(:rip) { 'throw (e)' }
      let(:expected_raw) do
        {
          :module => [
            {
              :throw => 'throw',
              :payload => { :reference => 'e' }
            }
          ]
        }
      end
    end

    context 'multiple expressions' do
      recognizes_as_expected 'terminates expressions properly' do
        let(:rip) do
          <<-RIP
            one
            two
            three
          RIP
        end
        let(:expected_raw) do
          {
            :module => [
              { :reference => 'one' },
              { :reference => 'two' },
              { :reference => 'three' }
            ]
          }
        end
        let(:expected) do
          {
            :module => [
              { :reference => 'one' },
              { :reference => 'two' },
              { :reference => 'three' }
            ]
          }
        end
      end

      recognizes_as_expected 'allows expressions to take more than one line' do
        let(:rip) do
          <<-RIP
            1 +
              2 -
              3
          RIP
        end
        let(:expected_raw) do
          {
            :module => [
              {
                :atom => [
                  { :integer => '1' },
                  {
                    :operator_invocation => {
                      :operator => '+',
                      :argument => { :integer => '2' }
                    }
                  },
                  {
                    :operator_invocation => {
                      :operator => '-',
                      :argument => { :integer => '3' }
                    }
                  }
                ]
              }
            ]
          }
        end
        let(:expected) do
          {
            :module => [
              {
                :callable => {
                  :object => {
                    :callable => {
                      :object => { :sign => '+', :integer => '1' },
                      :location => '+',
                      :property_name => '+'
                    },
                    :location => '+',
                    :arguments => [
                      { :sign => '+', :integer => '2' }
                    ]
                  },
                  :location => '-',
                  :property_name => '-'
                },
                :location => '-',
                :arguments => [
                  { :sign => '+', :integer => '3' }
                ]
              }
            ]
          }
        end
      end
    end

    context 'invoking lambdas' do
      recognizes_as_expected 'lambda literal invocation' do
        let(:rip) { '-> () {}()' }
        let(:expected_raw) do
          {
            :module => [
              {
                :atom => [
                  {
                    :dash_rocket => '->',
                    :parameters => [],
                    :location_body => '{',
                    :body => []
                  },
                  :regular_invocation => { :location => '(', :arguments => [] }
                ]
              }
            ]
          }
        end
      end

      recognizes_as_expected 'lambda reference invocation' do
        let(:rip) { 'full_name()' }
        let(:expected_raw) do
          {
            :module => [
              {
                :atom => [
                  { :reference => 'full_name' },
                  { :regular_invocation => { :location => '(', :arguments => [] } }
                ]
              }
            ]
          }
        end
      end

      recognizes_as_expected 'lambda reference invocation arguments' do
        let(:rip) { 'full_name(:Thomas, :Ingram)' }
        let(:expected_raw) do
          {
            :module => [
              {
                :atom => [
                  { :reference => 'full_name' },
                  {
                    :regular_invocation => {
                      :location => '(',
                      :arguments => [
                        { :location => ':', :string => rip_string_raw('Thomas') },
                        { :location => ':', :string => rip_string_raw('Ingram') }
                      ]
                    }
                  }
                ]
              }
            ]
          }
        end
      end

      recognizes_as_expected 'index invocation' do
        let(:rip) { 'list[0]' }
        let(:expected_raw) do
          {
            :module => [
              {
                :atom => [
                  { :reference => 'list' },
                  {
                    :index_invocation => {
                      :open => '[',
                      :arguments => [
                        { :integer => '0' }
                      ],
                      :close => ']'
                    }
                  }
                ]
              }
            ]
          }
        end
      end

      recognizes_as_expected 'operator invocation' do
        let(:rip) { '2 + 2' }
        let(:expected_raw) do
          {
            :module => [
              {
                :atom => [
                  { :integer => '2' },
                  {
                    :operator_invocation => {
                      :operator => '+',
                      :argument => { :integer => '2' }
                    }
                  }
                ]
              }
            ]
          }
        end
      end

      recognizes_as_expected 'reference assignment' do
        let(:rip) { 'favorite_language = :rip' }
        let(:expected_raw) do
          {
            :module => [
              {
                :atom => [
                  { :reference => 'favorite_language' },
                  {
                    :assignment => {
                      :location => '=',
                      :rhs => { :location => ':', :string => rip_string_raw('rip') }
                    }
                  }
                ]
              }
            ]
          }
        end
        let(:expected) do
          {
            :module => [
              {
                :lhs => { :reference => 'favorite_language' },
                :location => '=',
                :rhs => { :location => ':', :string => rip_string('rip') }
              }
            ]
          }
        end
      end

      recognizes_as_expected 'property assignment' do
        let(:rip) { 'favorite.language = :rip.lang' }
        let(:expected_raw) do
          {
            :module => [
              {
                :atom => [
                  {
                    :atom => [
                      { :reference => 'favorite' },
                      {
                        :location => '.',
                        :property_name => 'language'
                      }
                    ]
                  },
                  {
                    :assignment => {
                      :location => '=',
                      :rhs => {
                        :atom => [
                          { :location => ':', :string => rip_string_raw('rip') },
                          {
                            :location => '.',
                            :property_name => 'lang'
                          }
                        ]
                      }
                    }
                  }
                ]
              }
            ]
          }
        end
        let(:expected) do
          {
            :module => [
              {
                :lhs => {
                  :object => { :reference => 'favorite' },
                  :location => '.',
                  :property_name => 'language'
                },
                :location => '=',
                :rhs => {
                  :object => { :location => ':', :string => rip_string('rip') },
                  :location => '.',
                  :property_name => 'lang'
                }
              }
            ]
          }
        end
      end
    end

    context 'nested parenthesis' do
      recognizes_as_expected 'anything surrounded by parenthesis' do
        let(:rip) { '(0)' }
        let(:expected_raw) do
          {
            :module => [
              { :integer => '0' }
            ]
          }
        end
      end

      recognizes_as_expected 'anything surrounded by parenthesis with crazy nesting' do
        let(:rip) { '((((((l((1 + (((2 - 3)))))))))))' }
        let(:expected_raw) do
          {
            :module => [
              {
                :atom => [
                  { :reference => 'l' },
                  {
                    :regular_invocation => {
                      :location => '(',
                      :arguments => [
                        {
                          :atom => [
                            { :integer => '1' },
                            {
                              :operator_invocation => {
                                :operator => '+',
                                :argument => {
                                  :atom => [
                                    { :integer => '2' },
                                    {
                                      :operator_invocation => {
                                        :operator => '-',
                                        :argument => { :integer => '3' }
                                      }
                                    }
                                  ]
                                }
                              }
                            }
                          ]
                        }
                      ]
                    }
                  }
                ]
              }
            ]
          }
        end
      end
    end

    context 'property chaining' do
      recognizes_as_expected 'chaining with properies and invocations' do
        let(:rip) { '0.one().two.three()' }
        let(:expected_raw) do
          {
            :module => [
              {
                :atom => [
                  { :integer => '0' },
                  {
                    :location => '.',
                    :property_name => 'one'
                  },
                  { :regular_invocation => { :location => '(', :arguments => [] } },
                  {
                    :location => '.',
                    :property_name => 'two'
                  },
                  {
                    :location => '.',
                    :property_name => 'three'
                  },
                  { :regular_invocation => { :location => '(', :arguments=> [] } }
                ]
              }
            ]
          }
        end
      end

      recognizes_as_expected 'chaining off opererators' do
        let(:rip) { '(1 - 2).zero?()' }
        let(:expected_raw) do
          {
            :module => [
              {
                :atom => [
                  {
                    :atom => [
                      { :integer => '1' },
                      {
                        :operator_invocation => {
                          :operator => '-',
                          :argument => { :integer => '2' }
                        }
                      }
                    ]
                  },
                  {
                    :location => '.',
                    :property_name => 'zero?'
                  },
                  { :regular_invocation => { :location => '(', :arguments => [] } }
                ]
              }
            ]
          }
        end
      end

      recognizes_as_expected 'chaining several opererators' do
        let(:rip) { '1 + 2 + 3 + 4' }
        let(:expected_raw) do
          {
            :module => [
              {
                :atom => [
                  { :integer => '1' },
                  {
                    :operator_invocation => {
                      :operator => '+',
                      :argument => { :integer => '2' }
                    }
                  },
                  {
                    :operator_invocation => {
                      :operator => '+',
                      :argument => { :integer => '3' }
                    }
                  },
                  {
                    :operator_invocation => {
                      :operator => '+',
                      :argument => { :integer => '4' }
                    }
                  }
                ]
              }
            ]
          }
        end
      end
    end

    context 'atomic literals' do
      describe 'numbers' do
        recognizes_as_expected 'integer' do
          let(:rip) { '42' }
          let(:expected_raw) do
            {
              :module => [
                { :integer => '42' }
              ]
            }
          end
          let(:expected) do
            {
              :module => [
                { :sign => '+', :integer => '42' }
              ]
            }
          end
        end

        recognizes_as_expected 'decimal' do
          let(:rip) { '4.2' }
          let(:expected_raw) do
            {
              :module => [
                { :decimal => '4.2' }
              ]
            }
          end
          let(:expected) do
            {
              :module => [
                { :sign => '+', :decimal => '4.2' }
              ]
            }
          end
        end

        recognizes_as_expected 'negative number' do
          let(:rip) { '-3' }
          let(:expected_raw) do
            {
              :module => [
                { :sign => '-', :integer => '3' }
              ]
            }
          end
          let(:expected) do
            {
              :module => [
                { :sign => '-', :integer => '3' }
              ]
            }
          end
        end

        recognizes_as_expected 'large number' do
          let(:rip) { '123_456_789' }
          let(:expected_raw) do
            {
              :module => [
                { :integer => '123_456_789' }
              ]
            }
          end
          let(:expected) do
            {
              :module => [
                { :sign => '+', :integer => '123_456_789' }
              ]
            }
          end
        end
      end

      recognizes_as_expected 'regular character' do
        let(:rip) { '`9' }
        let(:expected_raw) do
          {
            :module => [
              {
                :location => '`',
                :character => '9'
              }
            ]
          }
        end
        let(:expected) do
          {
            :module => [
              {
                :location => '`',
                :character => '9'
              }
            ]
          }
        end
      end

      recognizes_as_expected 'escaped character' do
        let(:rip) { '`\n' }
        let(:expected_raw) do
          {
            :module => [
              {
                :location => '`',
                :character => { :location => '\\', :escaped_token => 'n' }
              }
            ]
          }
        end
        let(:expected) do
          {
            :module => [
              {
                :location => '`',
                :character => "\n"
              }
            ]
          }
        end
      end

      recognizes_as_expected 'symbol string' do
        let(:rip) { ':0' }
        let(:expected_raw) do
          {
            :module => [
              {
                :location => ':',
                :string => [
                  { :character => '0' }
                ]
              }
            ]
          }
        end
      end

      recognizes_as_expected 'symbol string with escape' do
        let(:rip) { ':on\e' }
        let(:expected_raw) do
          {
            :module => [
              {
                :location => ':',
                :string => [
                  { :character => 'o' },
                  { :character => 'n' },
                  { :character => '\\' },
                  { :character => 'e' }
                ]
              }
            ]
          }
        end
        let(:expected) do
          {
            :module => [
              {
                :location => ':',
                :string => [
                  { :location => 'o', :character => 'o' },
                  { :location => 'n', :character => 'n' },
                  { :location => '\\', :character => '\\' },
                  { :location => 'e', :character => 'e' }
                ]
              }
            ]
          }
        end
      end

      recognizes_as_expected 'single-quoted string' do
        let(:rip) { '\'two\'' }
        let(:expected_raw) do
          {
            :module => [
              {
                :location => '\'',
                :string => [
                  { :character => 't' },
                  { :character => 'w' },
                  { :character => 'o' }
                ]
              }
            ]
          }
        end
      end

      recognizes_as_expected 'double-quoted string' do
        let(:rip) { '"a\nb"' }
        let(:expected_raw) do
          {
            :module => [
              {
                :location => '"',
                :string => [
                  { :character => 'a' },
                  { :character => { :location => '\\', :escaped_token => 'n' } },
                  { :character => 'b' }
                ]
              }
            ]
          }
        end
        let(:expected) do
          {
            :module => [
              {
                :location => '"',
                :string => [
                  { :location => 'a', :character => 'a' },
                  { :location => "\n", :character => "\n" },
                  { :location => 'b', :character => 'b' }
                ]
              }
            ]
          }
        end
      end

      recognizes_as_expected 'double-quoted string with interpolation' do
        let(:rip) { '"ab#{cd}ef"' }
        let(:expected_raw) do
          {
            :module => [
              {
                :location => '"',
                :string => rip_string_raw('ab') + [{ :start => '#{', :interpolation => [
                  { :reference => 'cd' }
                ], :end => '}' }] + rip_string_raw('ef')
              }
            ]
          }
        end
        let(:expected) do
          {
            :module => [
              {
                :callable => {
                  :object => {
                    :callable => {
                      :object => {
                        :location => '"',
                        :string => rip_string('ab')
                      },
                      :location => '+',
                      :property_name => '+'
                    },
                    :location => '+',
                    :arguments => [
                      {
                        :start => '#{',
                        :interpolation => [
                          { :reference => 'cd' }
                        ],
                        :end => '}'
                      }
                    ]
                  },
                  :location => '+',
                  :property_name => '+'
                },
                :location => '+',
                :arguments => [
                  {
                    :location => '"',
                    :string => rip_string('ef')
                  }
                ]
              }
            ]
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
      #   let(:expected_raw) do
      #     [
      #       {
      #         :here_doc_start => 'HERE_DOC',
      #         :string => rip_string("here docs are good for multi-line strings\n"),
      #         :here_doc_end => 'HERE_DOC'
      #       }
      #     ]
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
      #   let(:expected_raw) do
      #     [
      #       {
      #         :here_doc_start => 'HERE_DOC',
      #         :string => rip_string('here docs are good for multi-line ') + [{ :start => '#{', :interpolation => [{ :reference => 'strings' }], :end => '}' }] + rip_string("\n")
      #         :here_doc_end => 'HERE_DOC'
      #       }
      #     ]
      #   end
      # end

      recognizes_as_expected 'regular expression' do
        let(:rip) { '/hello/' }
        let(:expected_raw) do
          {
            :module => [
              {
                :location => '/',
                :regex => [
                  { :character => 'h' },
                  { :character => 'e' },
                  { :character => 'l' },
                  { :character => 'l' },
                  { :character => 'o' }
                ]
              }
            ]
          }
        end
      end

      recognizes_as_expected 'regular expression with interpolation' do
        let(:rip) { '/he#{ll}o/' }
        let(:expected_raw) do
          {
            :module => [
              {
                :location => '/',
                :regex => [
                  { :character => 'h' },
                  { :character => 'e' },
                  {
                    :start => '#{',
                    :interpolation => [
                      { :reference => 'll' }
                    ],
                    :end => '}'
                  },
                  { :character => 'o' }
                ]
              }
            ]
          }
        end
        let(:expected) do
          {
            :module => [
              {
                :callable => {
                  :object => {
                    :callable => {
                      :object => {
                        :location => '/',
                        :regex => rip_string('he')
                      },
                      :location => '+',
                      :property_name => '+'
                    },
                    :location => '+',
                    :arguments => [
                      {
                        :start => '#{',
                        :interpolation => [
                          { :reference => 'll' }
                        ],
                        :end => '}'
                      }
                    ]
                  },
                  :location => '+',
                  :property_name => '+'
                },
                :location => '+',
                :arguments => [
                  {
                    :location => '/',
                    :regex => rip_string('o')
                  }
                ]
              }
            ]
          }
        end
      end
    end

    context 'date and time literals' do
      recognizes_as_expected 'date' do
        let(:rip) { '2012-02-12' }
        let(:expected_raw) do
          {
            :module => [
              {
                :year => '2012',
                :month => '02',
                :day => '12'
              }
            ]
          }
        end
        let(:expected) do
          expected_raw
        end
      end

      recognizes_as_expected 'time' do
        let(:rip) { '05:24:00' }
        let(:expected_raw) do
          {
            :module => [
              {
                :hour => '05',
                :minute => '24',
                :second => '00'
              }
            ]
          }
        end
        let(:expected) do
          {
            :module => [
              {
                :hour => '05',
                :minute => '24',
                :second => '00',
                :sub_second => '0',
                :offset => {
                  :sign => '+',
                  :hour => '00',
                  :minute => '00'
                }
              }
            ]
          }
        end
      end

      recognizes_as_expected 'time with optional fractional second' do
        let(:rip) { '05:24:00.14159' }
        let(:expected) do
          {
            :module => [
              {
                :hour => '05',
                :minute => '24',
                :second => '00',
                :sub_second => '14159',
                :offset => {
                  :sign => '+',
                  :hour => '00',
                  :minute => '00'
                }
              }
            ]
          }
        end
      end

      recognizes_as_expected 'time with optional offset' do
        let(:rip) { '00:24:00-0500' }
        let(:expected) do
          {
            :module => [
              {
                :hour => '00',
                :minute => '24',
                :second => '00',
                :sub_second => '0',
                :offset => {
                  :sign => '-',
                  :hour => '05',
                  :minute => '00'
                }
              }
            ]
          }
        end
      end

      recognizes_as_expected 'time with optional fractional second and optional offset' do
        let(:rip) { '00:24:00.14159-0500' }
        let(:expected_raw) do
          {
            :module => [
              {
                :hour => '00',
                :minute => '24',
                :second => '00',
                :sub_second => '14159',
                :offset => {
                  :sign => '-',
                  :hour => '05',
                  :minute => '00'
                }
              }
            ]
          }
        end
        let(:expected) do
          expected_raw
        end
      end

      recognizes_as_expected 'datetime' do
        let(:rip) { '2012-02-12T05:24:00' }
        let(:expected_raw) do
          {
            :module => [
              {
                :date => {
                  :year => '2012',
                  :month => '02',
                  :day => '12'
                },
                :time => {
                  :hour => '05',
                  :minute => '24',
                  :second => '00'
                }
              }
            ]
          }
        end
        let(:expected) do
          {
            :module => [
              {
                :date => {
                  :year => '2012',
                  :month => '02',
                  :day => '12'
                },
                :time => {
                  :hour => '05',
                  :minute => '24',
                  :second => '00',
                  :sub_second => '0',
                  :offset => {
                    :sign => '+',
                    :hour => '00',
                    :minute => '00'
                  }
                }
              }
            ]
          }
        end
      end
    end

    context 'molecular literals' do
      recognizes_as_expected 'key-value pairs' do
        let(:rip) { '5: \'five\'' }
        let(:expected_raw) do
          {
            :module => [
              {
                :atom => [
                  { :integer => '5' },
                  {
                    :key_value_pair => {
                      :location => ':',
                      :value => {
                        :location => '\'',
                        :string => rip_string_raw('five')
                      }
                    }
                  }
                ]
              }
            ]
          }
        end
      end

      recognizes_as_expected 'ranges' do
        let(:rip) { '1..3' }
        let(:expected_raw) do
          {
            :module => [
              {
                :atom => [
                  { :integer => '1' },
                  {
                    :range => {
                      :end => { :integer => '3' },
                      :location => '..',
                      :exclusivity => nil
                    }
                  }
                ]
              }
            ]
          }
        end
      end

      recognizes_as_expected 'exclusive ranges' do
        let(:rip) { '1...age' }
        let(:expected_raw) do
          {
            :module => [
              {
                :atom => [
                  { :integer => '1' },
                  {
                    :range => {
                      :end => { :reference => 'age' },
                      :location => '..',
                      :exclusivity => '.'
                    }
                  }
                ]
              }
            ]
          }
        end
      end

      recognizes_as_expected 'empty map' do
        let(:rip) { '{}' }
        let(:expected_raw) do
          {
            :module => [
              {
                :location => '{',
                :map => []
              }
            ]
          }
        end
      end

      recognizes_as_expected 'map with content' do
        let(:rip) do
          <<-RIP
            {
              :age: 31,
              :name: :Thomas
            }
          RIP
        end
        let(:expected_raw) do
          {
            :module => [
              {
                :location => '{',
                :map => [
                  {
                    :atom => [
                      {
                        :location => ':',
                        :string => rip_string_raw('age')
                      },
                      {
                        :key_value_pair => {
                          :location => ':',
                          :value => { :integer => '31' }
                        }
                      }
                    ]
                  },
                  {
                    :atom => [
                      {
                        :location => ':',
                        :string => rip_string_raw('name')
                      },
                      {
                        :key_value_pair => {
                          :location => ':',
                          :value => {
                            :location => ':',
                            :string => rip_string_raw('Thomas')
                          }
                        }
                      }
                    ]
                  }
                ]
              }
            ]
          }
        end
      end

      recognizes_as_expected 'empty list' do
        let(:rip) { '[]' }
        let(:expected_raw) do
          {
            :module => [
              {
                :location => '[',
                :list => []
              }
            ]
          }
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
        let(:expected_raw) do
          {
            :module => [
              {
                :location => '[',
                :list => [
                  { :integer => '31' },
                  {
                    :location => ':',
                    :string => rip_string_raw('Thomas')
                  }
                ]
              }
            ]
          }
        end
      end
    end
  end
end
