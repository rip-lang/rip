require 'spec_helper'

describe Rip::Core::System do
  let(:type_instance) { Rip::Core::System.type_instance }

  describe 'debug methods' do
    specify { expect(type_instance.to_s).to eq('#< System >') }
  end

  describe '.type_instance' do
    specify { expect(type_instance).to_not be_nil }
    specify { expect(type_instance['type']).to eq(Rip::Core::Type.type_instance) }
    specify { expect(type_instance.symbols).to match_array(['@', 'Boolean', 'Character', 'IO', 'List', 'Rational', 'String', 'type', 'self', 'require', 'to_string']) }
  end

  describe '.require' do
    specify { expect(type_instance['require']).to be_a(Rip::Core::Lambda) }

    let(:project_name) { 'such_project' }
    let(:project_dir) { Pathname.pwd + current_dir + project_name }
    let(:syntax_tree) { Rip::Compiler::Parser.new(main_file, main_file.read).syntax_tree }
    let(:context) { Rip::Compiler::Scope.new(Rip::Compiler::Scope.global_context, project_dir) }
    let(:final_result) { syntax_tree.interpret(context) }

    before(:each) do
      project_dir.mkdir unless project_dir.directory?

      cd project_name

      write_file('library.rip', <<-RIP)
        'hello, world'
      RIP
    end

    context 'an absolute file' do
      let(:main_file) { project_dir + 'absolute.rip' }

      specify do
        write_file('absolute.rip', <<-RIP)
          System.require('#{project_dir + 'library.rip'}')
        RIP

        in_current_dir do
          expect(final_result).to eq(Rip::Core::String.from_native('hello, world'))
        end
      end
    end

    context 'a relative file' do
      let(:main_file) { project_dir + 'relative.rip' }

      specify do
        write_file('relative.rip', <<-RIP)
          System.require('./library.rip')
        RIP

        in_current_dir do
          expect(final_result).to eq(Rip::Core::String.from_native('hello, world'))
        end
      end
    end

    context 'a non-existent file' do
      let(:main_file) { project_dir + 'broken.rip' }

      specify do
        write_file('broken.rip', <<-RIP)
          System.require('./not_exist')
        RIP

        in_current_dir do
          expect { final_result }.to raise_error(Rip::Exceptions::LoadException)
        end
      end
    end
  end
end
