# A class for processing an ACH file, and comparing the payees with the OFAC database
#
class DocProcessor
	# grant access to class attributes
	#
	attr_reader :doc, :result_file
	
	# initialize the document processor class
	#
	def initialize(doc, result_location)
		@ach_reader = AchReader.new(doc)
		@doc = doc
		@result_file = File.join(result_location, "#{File.basename(@doc, '.*')}_complete.csv")
		@result_location = result_location
	end
	
	# process the document
	#
	def process
		CSV.open("#{@result_file}", "w") do |csv|
			csv << ['Payee','Score', 'Possible Result','Address']
			payees.each do |payee|
				ofac = Ofac.new({:name => "#{payee}"})
				if ofac.possible_hits.empty?
					csv << ["#{payee}","#{ofac.score}", '','']
				else
					ofac.possible_hits.each do |potential|
						csv << ["#{payee}","#{ofac.score}", "#{potential[:name]}","#{potential[:address]} - #{potential[:city]}"]
					end
				end # if possible hits
			end # each payee
		end # CSV 
		cleanup
	end
	
	# cleanup the process
	#
	def cleanup
		FileUtils.mv("#{@doc}", File.join("#{@result_location}", "#{File.basename(@doc)}"))
	end
	
	# the list of payees
	#
	def payees
		@ach_reader.payees
	end
	
end