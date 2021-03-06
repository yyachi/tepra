require 'spec_helper'
require 'tepra/commands/print_command'
module Tepra::Commands
	describe PrintCommand do
	  let(:cmd){ PrintCommand.new }
	  before do
		allow(Tepra).to receive(:find_spc_path).and_return(Pathname.new('/path/to/SPC9.exe'))
		#allow(Tepra).to receive(:template_path).and_return('/path/to/template.spc')
	  end

      describe "#show_help", :show_help => true do
        it {
          puts "===================================="
          expect{ cmd.show_help }.not_to raise_error
          puts "===================================="
        }
      end
      
		describe "#handle_options" do
			#subject { cmd.handle_options args}
			let(:cmd){ PrintCommand.new }
			let(:args){ ["-h", "--no-skip-header", "-n", "--printer", printer_name, "--template", template_path, "example/example-data-in.csv"] }
			let(:printer_name){ 'Example Printer' }
			let(:template_path){ 'example/template.tpc'}
			before do
				cmd.handle_options args
			end
			it { expect(cmd.options).to include(:printer_name => printer_name) }
			it { expect(cmd.options).to include(:dry_run => true) }
			it { expect(cmd.options).to include(:template_path => template_path) }			
		end



		describe "#execute" do
			subject { cmd.execute }
			let(:cmd) { PrintCommand.new }
			before do
				cmd.stub(:options).and_return(options)
			end

			context "without printer option", :current => true do
				let(:options) { {:args => [csvfile_path] } }
				let(:csvfile_path) { 'aaa,bbb' }
				let(:printer){ 'Example Printer' }
				before do
				  Tepra.config = { printer: printer }
				  p Tepra.find_spc_path
                  #p Tepra.config
				end
				it { expect(Tepra).to receive(:print).with(csvfile_path,{:printer_name => printer}).and_return('expect') }
				after { subject }
				#it { expect{subject}.not_to raise_error }
			end


			context "with printer option", :current => false do
				let(:options) { {:args => [csvfile_path], :printer_name => printer} }
				let(:csvfile_path) { 'example/example-data.csv' }
				let(:printer){ 'Example Printer' }
				before do
					Tepra.config = { printer: printer }
				end
				it { expect(Tepra).to receive(:print).with(csvfile_path,{:printer_name => printer}).and_return('expect') }
				after { subject }
				#it { expect{subject}.not_to raise_error }
			end

			context "with valid csvfile_path" do
				let(:options) { {:args => [csvfile_path], :dry_run => true } }
				let(:csvfile_path) { 'example/example-data.csv' }
				it { expect{subject}.not_to raise_error }
			end

			context "with invalid csvfile_path" do
				let(:options) { {:args => [csvfile_path], :dry_run => true } }
				let(:csvfile_path) { 'example/example-data-.csv' }
				it { expect{subject}.not_to raise_error }
			end
            after do
              Tepra.config = nil
            end
		end
	end
end
