module Searchable

	def where(params)
		keys = params.keys.map {|key| "#{key} = ?"}.join("AND")

		results = DBConnection.execute(<<-SQL, *params.values)
			SELECT *
				FROM #{self.table_name}
			 WHERE #{keys}
			 LIMIT 1
		SQL

		results.map {|row| self.new(row)}
	end
end