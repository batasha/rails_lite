require 'active_support/core_ext/object/try'
require 'active_support/inflector'


class BelongsToAssocParams
	attr_reader :primary_key, :foreign_key

	def initialize(name, params={})
		@class_name = params[:class_name] || name.to_s.camelize
		@primary_key = params[:primary_key] || :id
		@foreign_key = params[:foreign_key] || "#{name}_id"
	end

	def other_class
		@class_name.constantize
	end

	def other_table
		self.other_class.table_name
	end
end


class HasManyAssocParams
	attr_reader :primary_key, :foreign_key

	def initialize(name, params)
		@class_name = params[:class_name] || name.to_s.singularize
		@primary_key = params[:primary_key] || :id
		@foreign_key = params[:foreign_key] || "#{self}_id"
	end

	def other_class
		@class_name.camelize.constantize
	end

	def other_table
		self.other_class.table_name
	end
end



module Associatable

	def assoc_params
		@assoc_params ||= {}
	end


	def belongs_to(name, params={})

		define_method(name) do
			self.class.assoc_params[name] = BelongsToAssocParams.new(name, params)
			aps = self.class.assoc_params[name]

			results = DBConnection.execute(<<-SQL, self.send(aps.foreign_key))
				SELECT *
				  FROM #{aps.other_table}
				 WHERE #{aps.other_table}.#{aps.primary_key} = ?
			SQL

			aps.other_class.parse_all(results).first
	  end
	end


	def has_many(name, params={})

		define_method(name) do
			aps = HasManyAssocParams.new(name, params)

			results = DBConnection.execute(<<-SQL, self.send(aps.primary_key))
				SELECT *
				  FROM #{aps.other_table}
				 WHERE #{aps.other_table}.#{aps.foreign_key} = ?
			SQL

			aps.other_class.parse_all(results)
		end
	end

	def has_one_through(name, assoc1, assoc2)

		define_method(name) do
			params1 = self.class.assoc_params[assoc1]
			params2 = params1.other_class.assoc_params[assoc2]

			query = <<-SQL
				SELECT #{params2.other_table}.*
				  FROM #{params2.other_table}
				  JOIN #{params1.other_table}
					  ON #{params2.other_table}.#{params2.primary_key} = 						   							  #{params1.other_table}.#{params2.foreign_key}
				 WHERE #{params1.other_table}.#{params1.primary_key} = ?
				 LIMIT 1
			SQL

			result = DBConnection.execute(query, self.send(params1.foreign_key))

			params2.other_class.parse_all(result)
		end
	end
end


