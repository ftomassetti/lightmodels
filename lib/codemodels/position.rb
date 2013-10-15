module CodeModels

class SourcePoint
	include Comparable
	
	attr_accessor :line, :column

	def self.from_code_index(code,index)
		l = line(code,index)
		c = column(code,index)
		SourcePoint.new(l,c)
	end

	def initialize(line=nil,column=nil)
		self.line= line
		self.column= column
	end

	def line=(v)
		raise "Unvalid line #{v}" if v && v<1
		@line   = v
	end

	def column=(v)
		# is valid only for newlines
		raise "Unvalid column #{v}" if v && v<0
		@column = v
	end

	def eql?(other)
		other.line==line && other.column==column
	end

	def ==(other)
		self.eql?(other)
	end

	def to_s
		"Line #{@line}, Col #{@column}"
	end

	def to_absolute_index(s)
		index = 0
		lines = s.lines
		(@line-1).times do
			index+=lines.next.length
		end
		index+=@column
		index-=1
		index
		
		# current_line = lines.next
		# i=0
		# c=0
		# while c<@column
		# 	c += current_line[i]=='\t' ? COLUMNS_FOR_TAB : 1
		# 	i += 1
		# end

		# index+=c
		# index-=1
		# index		
	end

	def <=>(other)
		lc = self.line<=>other.line
		if lc==0
			self.column<=>other.column
		else
			lc
		end
	end

	private

	def self.line(code,index)
		piece = code[0..index]		
		return piece.lines.count+1 if code[index]=="\n"
		piece.lines.count
	end

	def self.column(code,index)
		piece = code[0..index]
		last_line = nil
		piece.lines.each{|l| last_line=l}
		return 0 if code[index]=="\n"
		last_line.length
	end
end

class SourcePosition
	attr_accessor :begin_point, :end_point

	def self.from_code_indexes(code,begin_index,end_index)
		SourcePosition.new(SourcePoint.from_code_index(code,begin_index),SourcePoint.from_code_index(code,end_index))
	end

	def initialize(begin_point=nil,end_point=nil)
		@begin_point = begin_point
		@end_point = end_point
	end

	def begin_line=(line)
		@begin_point=SourcePoint.new unless @begin_point
		@begin_point.line = line
	end

	def begin_column=(column)
		@begin_point=SourcePoint.new unless @begin_point
		@begin_point.column = column
	end

	def eql?(other)
		return false unless other.respond_to?(:begin_point)
		return false unless other.respond_to?(:end_point)
		other.begin_point==begin_point && other.end_point==end_point
	end

	def ==(other)
		self.eql?(other)
	end

	def to_s
		"from #{@begin_point} to #{@end_point}"
	end

	def get_string(s)
		as = @begin_point.to_absolute_index(s)
		ae = @end_point.to_absolute_index(s)
		s[as..ae]
	end

	def begin_line
		@begin_point.line
	end

	def end_line
		@end_point.line
	end

	def begin_column
		@begin_point.column
	end

	def end_column
		@end_point.column
	end	

	def include?(other)
		(self.begin_point <= other.begin_point) && (self.end_point >= other.end_point)
	end

end


end