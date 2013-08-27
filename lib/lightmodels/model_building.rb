require 'lightmodels/serialization'

module LightModels

module ModelBuilding

class << self
	attr_accessor :verbose
end

def self.generate_models_in_dir(src,dest,src_extension,dest_extension,&model_creator)
	puts "== #{src} -> #{dest} ==" if LightModels::ModelBuilding.verbose
	Dir["#{src}/*"].each do |fd|		
		if File.directory? fd
			basename = File.basename(fd)
			generate_models_in_dir("#{src}/#{basename}","#{dest}/#{basename}",src_extension,dest_extension,&model_creator)
		else
			if File.extname(fd)==".#{src_extension}"
				translated_simple_name = "#{File.basename(fd, ".#{src_extension}")}.#{dest_extension}"
				translated_name = "#{dest}/#{translated_simple_name}"
				puts "* #{fd} --> #{translated_name}" if LightModels::ModelBuilding.verbose
				generate_model_per_file(fd,translated_name,&model_creator)
			end
		end
	end
end

def self.generate_model_per_file(src,dest,&models_generator)
	if not File.exist? dest 
		puts "<Model from #{src}>"
	
		m = models_generator.call(src)

		LightModels::Serialization.save_model(m,dest)
	else
		puts "skipping #{src} because #{dest} found" if LightModels::ModelBuilding.verbose 
	end
end

end

end