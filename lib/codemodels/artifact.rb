# encoding: utf-8
require 'codemodels/position'

module CodeModels

# An artifact is everything that
# can contain code
class Artifact

	def initialize
		raise "You should not use Artifact directly" if self.class==Artifact
	end

	# @param point a point relative to this artifact
	# @return the same point specified in respect to the absolute artifact
	def point_to_absolute(point)
		offset = absolute_start
		p = SourcePoint.new
		p.line   = point.line  + offset.line - 1
		p.column = point.column
		p.column  += offset.column-1 if point.line==1
		p
	end

	# @param position a position relative to this artifact
	# @return the same position specified in respect to the absolute artifact
	def position_to_absolute(position)
		pos = SourcePosition.new
		pos.begin_point = point_to_absolute(position.begin_point)
		pos.end_point = point_to_absolute(position.end_point)
		pos
	end

end

# Represent a snippet embedded in something else
class EmbeddedArtifact < Artifact
	attr_accessor :host_artifact
	attr_accessor :position_in_host

	def absolute_start
		p = host_artifact.absolute_start
		p.line += position_in_host.begin_point.line-1
		if position_in_host.begin_point.line==1			
			# if I am on the first line of my "host", its column
			# matters because there are not newlines to reset the column
			# counter
			p.column += position_in_host.begin_point.column-1 
		else
			p.column = position_in_host.begin_point.column
		end
		p
	end

	def to_s
		"Embedded in (#{@host_artifact.to_s}) at #{position_in_host}"
	end

	def final_host
		host_artifact.final_host
	end

	def code
		position_in_host.get_string(host_artifact.code)
	end

	def embedded?
		true
	end

	def embedding_level
		@host_artifact.embedding_level+1
	end	

	def name
		'<embedded>'
	end

end

class FileArtifact < Artifact
	attr_reader :filename
	attr_reader :code

	def initialize(filename,code)
		@filename = filename
		@code = code
	end

	def absolute_start
		sp = SourcePoint.new
		sp.line   = 1
		sp.column = 1
		sp
	end

	def to_s
		"File #{filename}"
	end

	def final_host
		self
	end

	def embedded?
		false
	end

	def embedding_level
		0
	end

	def eql?(other)
		return false unless other.is_a?(FileArtifact)
		self.filename==other.filename && self.code==other.code
	end

	def ==(other)
		self.eql?(other)
	end

	def name
		filename
	end
	
end

class StringArtifact < Artifact
	attr_reader :code

	def initialize(code)
		@code = code
	end

	def absolute_start
		sp = SourcePoint.new
		sp.line   = 1
		sp.column = 1
		sp
	end

	def to_s
		"<StringArtifact>"
	end

	def final_host
		self
	end

	def embedded?
		false
	end

	def embedding_level
		0
	end

	def eql?(other)
		return false unless other.is_a?(StringArtifact)
		self.code==other.code
	end

	def ==(other)
		self.eql?(other)
	end

	def name
		'<string>'
	end
	
end

end