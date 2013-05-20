class SQLObject < MassObject
	extend Searchable
	extend Associatable

	def self.set_table_name(name)
		@table_name = name
	end

	def self.table_name
		@table_name
	end

	def self.all
		rows = DBConnection.execute(<<-SQL)
			SELECT *
				FROM #{self.table_name}
		SQL

		rows.each {|row| self.new(row)}
	end

	def self.find(id)
		result = DBConnection.execute(<<-SQL, id)
			SELECT *
				FROM #{self.table_name}
			 WHERE id = ?
			 LIMIT 1
		SQL

		self.new(*result)
	end

	def self.create(params)
		obj = self.new(params)
		cols = self.attributes
		values = cols.map {|col| obj.send(col)}

		DBConnection.execute(<<-SQL, *values)
			INSERT INTO #{self.table_name} #{cols.join(",")}
			     VALUES #{(values.count * ["?"]).join(",")}
		SQL

		obj.id = DBConnection.last_insert_row_id
	end

	def save
		@id ? self.update : self.create
	end


	private

	def attribute_values(attr_names)
		attr_names.map {|attr| obj.send(attr)}
	end

	def create
		cols = self.class.attributes
		values = attribute_values(cols)

		DBConnection.execute(<<-SQL, *values)
			INSERT INTO #{self.class.table_name} (#{cols.join(",")})
			     VALUES (#{(["?"] * values.count).join(",")})
		SQL

		@id = DBConnection.last_insert_row_id
	end

	def update
		cols = self.class.attributes
		set_line = cols.map {|attr_name| "#{attr_name} = ?"}.join(",")
		values = attribute_values(cols)

		attrs = DBConnection.execute(<<-SQL, *values, self.id)
			UPDATE #{self.class.table_name}
			   SET #{set_line}
			 WHERE id = ?
		SQL
	end

end