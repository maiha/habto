module Habto
  def self.append_features(base)
    base.extend ClassMethods
  end

  module ClassMethods
    protected
      def validate_find_options(options)
        readonly = set_readonly_option!(options)
        validate_find_options_for_habto!(options)
        super(options)
        options[:_readonly] = readonly
      end

      def set_readonly_option!(options)
        options.include?(:_readonly) ? options.delete(:_readonly) : super
      end

    private
      def define_habto(name, options)
        habtm = name.to_s.pluralize
        if habtm == name
          raise ActiveRecord::ConfigurationError, "Habto named '#{ name }' loops back to me; use '#{name.singularize}' instead"
        end

        has_and_belongs_to_many(habtm.intern, options)
        define_method(name){ send(habtm).first }
        define_method("#{name}="){|*records| send "#{habtm}=", records.compact}
        define_habto_count_method(name)
      end

      def validate_find_options_for_habto!(options)
        case (ref = options.delete(:count))
        when true
          refs  = reflect_on_all_associations(:has_and_belongs_to_many)
          refs.map{|ref| construct_habto_count_query_for!(ref, options)}
        when Array
          ref.each{|r| construct_habto_count_query_for!(r, options)}
        when String, Symbol
          construct_habto_count_query_for!(ref, options)
        else
          return
        end
        # for Rails2.1
        options[:select] ||= '*'
      end

      def construct_habto_count_query_for!(ref, options)
        ref   = ref.is_a?(ActiveRecord::Reflection::AssociationReflection) ? ref :
          reflections[ref.to_s.intern] or raise ActiveRecord::ConfigurationError, "unknown macro: #{ref}(#{ref.class})"
        construct_habto_count_query_by_single_subquery!(ref, options)
#        construct_habto_count_query_by_double_subquery!(ref, options)
      end

      def construct_habto_count_query_by_single_subquery!(ref, options)
        jt = ref.options[:join_table]
        fk = ref.primary_key_name
        an = "_habtm_%s_%s" % [name.to_s.demodulize.underscore, ref.name]
        cn = "%s_count" % [ref.name.to_s.singularize]

        select = "SELECT %s, COUNT(*) AS %s FROM %s GROUP BY %s" % [fk, cn, jt, fk]
        query  = "LEFT JOIN (%s) AS %s ON %s.%s = %s.%s" % [select, an, an, fk, table_name, primary_key]

        cols = options[:select] || "#{table_name}.*"
        options[:select] = "#{cols}, COALESCE(#{cn},0) AS #{cn}"
        options[:joins]  = "%s %s" % [options[:joins], query]
      end

      def construct_habto_count_query_by_double_subquery!(ref, options)
        ref   = ref.is_a?(ActiveRecord::Reflection::AssociationReflection) ? ref :
          reflections[ref.to_s.intern] or raise ActiveRecord::ConfigurationError, "unknown macro: #{ref}(#{ref.class})"
        jt  = ref.options[:join_table]
        fk  = ref.primary_key_name
        an  = "_habtm_%s_%s" % [name.to_s.demodulize.underscore, ref.name]
        cn  = "%s_count" % [ref.name.to_s.singularize]
        ucn = "#{cn}"

        query = <<-SQL
LEFT JOIN (
  SELECT #{primary_key}, COALESCE(#{ucn}, 0) AS #{cn}
  FROM #{table_name}
  LEFT JOIN (
    SELECT #{fk}, COUNT(*) AS #{ucn} FROM #{jt} GROUP BY #{fk}
  ) AS #{an} ON #{an}.#{fk} = #{table_name}.#{primary_key}
) AS #{an}_0 USING(#{primary_key})
        SQL

        options[:joins]  = "%s %s" % [options[:joins], query]
      end

      def define_habto_count_method(name)
        column_name = "#{name}_count"
        define_method(column_name) {self[column_name].to_i}
      end
  end
end
