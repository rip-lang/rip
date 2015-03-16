require 'spec_helper'

describe Rip::Nodes::Import do
  let(:location) { location_for }

  let(:context) { Rip::Compiler::Scope.new }

  let(:module_name) { 'foo' }
  let(:import_node) do
    module_name_string = Rip::Nodes::String.new(location, rip_string_nodes(module_name))
    Rip::Nodes::Import.new(location, module_name_string)
  end

  describe '#interpret' do
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
          import '#{project_dir + 'library.rip'}'
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
          import './library.rip'
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
          import './not_exist'
        RIP

        in_current_dir do
          expect { final_result }.to raise_error(Rip::Exceptions::LoadException)
        end
      end
    end
  end
end
