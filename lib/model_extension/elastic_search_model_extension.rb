################################
###Extension to the Tire model##
################################

#This for making Elastics Search based model to have
#ActiveRecord like methords to find and filter records

module Tire::Model
  module Extension

    @_setup_range_filters = Proc.new do |context, ranges|
        ranges.each do |field, range_parts|
          ranges_array = (range_parts.first.kind_of? Array) ? range_parts : [range_parts]
          or_filter_parts = []
          ranges_array.each do |range|
            if range[0].to_s.match(/\d+/)
              from, to = range
              or_filter_parts << { range: {field => {from: from, to: to}} }
            else
              inequality = range[0]
              or_filter_parts << { range: {field => {inequality => range[1]}} }
            end
          end
          context.filter :or, or_filter_parts
        end
    end

    def self.extended(base)
      instance_variables.each do |ins_var_name|
        base.instance_variable_set(ins_var_name, instance_variable_get(ins_var_name))
        base.extend(ClassMethods)
      end
    end

    def self.included(base)
      instance_variables.each do |ins_var_name|
        base.instance_variable_set(ins_var_name, instance_variable_get(ins_var_name))
        base.extend(ClassMethods)
      end
    end

    module ClassMethods
      def find_all_with_limit(limit = nil)
        s = Tire::Search::Search.new(index.name, :type => document_type,
                                     :wrapper => self).query { all }
        s = s.size(limit) if limit
        s.version(true).results
      end

      #This method will do the exact string match of field values
      #fields need to have the setting of ":index => 'not_analyzed'",
      #otherwise it won't return any result.
      #it filters the result using ES's terms filter, the same as
      #using "IN" condition on a list of values for a field in SQL.
      #the condition between different feilds is "AND"
      #Params:
      #   field_hash: a hash composing of hashes of fields names and an array
      #      of filterd values or a single value
      #   range_filter <hash>: the key is the field to be filtered on, the value is an
      #     array of the following forms: [<lower>, <upper>], ['gt|gte|lt|lte', <a number>]
      #     e.g. [1, 3], ['gt', 0] (greater than zero);
      #     multiple ranges is now supported: e.g. [ [1,2] , [3,4] ], it is chained by OR
      #   offset: offset of the entire results, default 0
      #   limit: the number of result returned, defailt is 100
      #Return: the ES result collection
      #Note: the default size of the return result is 100.
      def filter_by_fields(field_hash, options = {})
        options.reverse_merge!({
          limit: 100,
          offset: 0,
          sort: {}
        })
        sort = options[:sort]

        search do
          field_hash.each do  |k, v|
            array_of_values = v.kind_of?(Array) ? v : [v]
            send(:filter, :terms, { k.to_sym => array_of_values})
          end
          setup_range_filters.call(self, options[:range_filter]) unless options[:range_filter].blank?
          sort {by sort[:by], sort[:order] || 'desc'} unless sort.blank?
          from options[:offset]
          size options[:limit]
        end
      end

      #this method is simliar to the filter_by_fields method, except that it allows to score the
      #result by evaluate the "mvel" score_expression, look at ES's custom_score query for
      #more detail.
      #Params:
      #   score_expression: refere to the script expression in ES's custom_score query
      #   field_hash: a hash composing of hashes of fields names and an array
      #      of filterd values or a single value
      #   options: other options for the query
      #     offset: offset of the entire results, default 0
      #     limit: the number of result returned, defailt is 100
      #     script_params <hash>: the parameters used in the 'score_expressiona‘
      #     range_filter <hash>: the key is the field to be filtered on, the value is an
      #       array of the following forms: [<lower>, <upper>], ['gt|gte|lt|lte', <a number>]
      #       e.g. [1, 3], ['gt', 0] (greater than zero);
      #     multiple ranges is now supported: e.g. [ [1,2] , [3,4] ], it is chained by OR
      #Return: the ES result collection
      def filter_by_fields_with_custom_score(score_expression, field_hash, options = {})
        setup_range_filters = @_setup_range_filters
        options.reverse_merge!(
          limit: 100,
          offset: 0
        )
        search do
          query do
            custom_score script: score_expression, params: options[:script_params] do
              all
            end
          end
          field_hash.each do  |k, v|
            array_of_values = v.kind_of?(Array) ? v : [v]
            filter :terms, { k.to_sym => array_of_values}
          end
          setup_range_filters.call(self, options[:range_filter]) unless options[:range_filter].blank?
          from options[:offset]
          size options[:limit]
        end
      end


      #TODO: this is using query, the performence will be better if we can use
      #nested filter instead.
      #
      #For nested type object.
      #This method will do the exact string match of field values
      #fields need to have the setting of ":index => 'not_analyzed'",
      #otherwise it won't return any result
      #params:
      #  field_hash <hash>: equality conditions of the fields in top level
      #  nested_field_hash <hash>: equality conditions of the fields in the nested object level
      #    only one nested object query is supported for now
      #    e.g.
      #    {
      #       models: { name: 'LX', line: 4 },
      #    }
      #  offsets <number>: optional, default to 0
      #  limit <number>: optional, default to 100
      #Note: the default size of the return result is 100.
      def nested_filter_by_fields(opts = {})
        opts.reverse_merge!({
          field_hash: {},
          nested_field_hash: {},
          offset: 0,
          limit: 100
        })

        r = search do
          opts[:field_hash].each do  |k, v|
            send(:filter, :term, { k.to_sym => v})
          end
          query do
            filtered do
              query do
                all if opts[:nested_field_hash].empty?
                opts[:nested_field_hash].each do |nested_object_name, obj_feild_hash|
                  nested :path => nested_object_name do
                    query do
                      obj_feild_hash.each do |k, v|
                        send(:match, "#{nested_object_name}.#{k}", v )
                      end
                    end
                  end #of nested
                end #of opts[:nested_field_hash] loop
              end #of query
            end #of filtered
          end #of query
          from opts[:offset]
          size opts[:limit]
        end #of serach
      end

      def mapping_url
        "#{index.url}/#{index.name}/_mapping"
      end

      #this will do a merge update of the new index mapping with the old one
      #for more detail see:
      #http://www.elasticsearch.org/guide/reference/api/admin-indices-put-mapping.html
      def update_mapping
        mapping_config = {
          index.name => {
            "properties" => mapping
          }
        }
        Tire::Configuration.client.put mapping_url, MultiJson.encode(mapping_config)
      end

      #rebuild an index with a new name, apply existing mapping and settings defined in model
      #usually uses when there is a conflit mapping changes
      def rebuild_index(new_name)
        index.reindex(new_name, :mappings => mapping_to_hash, :settings => settings)
      end

      #save the ElasticsSerach index to a user specified dir
      #two files will be created:
      #  * index_options.yml #the file that stored index configuration
      #  * index.dat #serlized ruby array of document objects
      #params:
      #  dir_path<string>: the directory which the index will be saved to
      #return:
      #  none
      def export_index_to_dir(dir_path = File.join(Rails.root,"db", "assets",
          "index_export", ActiveModel::Naming.plural(self)))

        puts "Exporting index to \"#{dir_path}\""
        Dir.mkdir(dir_path) unless Dir.exist?(dir_path)

        export_dir = Dir.new(dir_path)

        marker = "\010".encode(Encoding::ASCII_8BIT)
        record_seperator = marker * 3

        index_options = {
          mappings: mapping_to_hash,
          settings: settings
        }

        File.open(File.join(export_dir, 'index_options.yml'), "wb") do |f|
          f.write(index_options.to_yaml)
        end

        File.open(File.join(export_dir, "index.dat"), "wb") do |f|
          Tire::Search::Scan.new(self.index.name).each do |results|
            documents = results.map do |document|
              document  = document.to_hash.except(:type, :_index, :_explanation,
                :_score, :_version, :highlight, :sort)
              document
            end

            binary_data = Marshal.dump(documents)
            f.write(binary_data)
            f.write(record_seperator)
          end
        end #of file writing
      end

      #giving the path of the exported index's dir, it will re-create
      #the index with a new name
      #params:
      #  new_index_name <string>: the new index name
      #  import_dir_path <string>: the dir path of the index data
      #return: none
      def import_index_from_dir(new_index_name, import_dir_path)
        reach_end_of_record = false
        consecutive_seperator_count = 0
        last_byte = nil
        marker = 8 #integer representation of "\010".encode(Encoding::ASCII_8BIT)
        documents = nil

        index_options_file_name = 'index_options.yml'
        index_data_file_name = 'index.dat'
        import_dir = Dir.new(import_dir_path)
        index_data_file_path = File.join(import_dir, index_data_file_name)

        index_options = YAML::load_file(File.join(import_dir, index_options_file_name))

        record = []

        new_index = Tire::Index.new(new_index_name)

        if new_index.exists?
          STDERR.puts("Index \"#{new_index_name}\" already exsits.")
          return
        else
          new_index.create(index_options)
        end

        File.open(index_data_file_path, "rb").each_byte do |byte|
          if consecutive_seperator_count == 0 and byte != marker
            record << byte
          else
            if byte == marker
              consecutive_seperator_count += 1
            else
              consecutive_seperator_count.times { |i| record << marker }
              record << byte
              consecutive_seperator_count = 0
            end

            if consecutive_seperator_count == 3
              consecutive_seperator_count = 0
              documents = Marshal.load(record.pack('C*'))
              #load the documents in the new index
              new_index.bulk_store(documents)
              record = []
            end
          end
          last_byte = byte
        end
      end

      #setup the model's index name to be an alias of new_index_name
      #if the model is pointing to a actuall index instead of the alias, this
      #method will fail. the resolution is to delete the index and rerun the
      #method.
      #parmas:
      #  new_index_name <string>: the existing index name
      #return: none
      def setup_index_alias(new_index_name)

        existing_alias = Tire::index(index.name).aliases.
          find { |a| a.name == index.name }

        if existing_alias
          ali = existing_alias
          ali.indices.each { |index_name|  ali.indices.delete(index_name) }
        else
          #note:
          #  Never used the model name as the name of a real index, used alias only
          Tire::index(index.name).delete #delete the real index that has the name
          ali = Tire::Alias.new(name: index.name)
        end

        #clean up all indcies which has the model's name as alias
        ali.indices.add(new_index_name)
        ali.save
      end

      #a fast way to load rebuild the index for a model from exported files
      #the data files are at <Rails Root>/db/assets/index_export/<model>
      def import_index_data_for_dev
        today = Time.now.strftime('%Y-%m-%d')
        new_index_name = "#{index.name}-#{today}"
        import_index_from_dir(new_index_name,
          File.join(Rails.root,"db", "assets", "index_export", index.name))
        setup_index_alias(new_index_name)
      end

      #it uses facet serach to get the all the different values of a field.
      #simliar to SQL's DISTINCT key word
      #params:
      #  field<symbol>: the field name of the model
      #  size<int>: the size of the return array, default to 9999
      #  filters<hash>: filter that will be apply on the set. the key is the
      #    the fields of the model, and the value is the value the records need
      #    to match to
      #return
      #  an array of distinct values of the giving field
      def all_selections(field, filters = {}, size = 9999)
        result = search do
          setup_filter = lambda do |arg|
            filter_array = filters.map { |k, v| {term: {k => v}} }
            send(:facet_filter, :bool, { must: filter_array })
          end

          facet field, :global => true  do
            terms [field], size: size
            instance_eval(&setup_filter)
          end
        end
        result.facets[field.to_s]["terms"].map { |t| t['term']}
      end

      #run the Elastics Serach facet query on a list of fields, and constrained the facets
      #by filters.
      #params:
      #  field <symbol>: the field name of the model, or array of field names
      #  size <int>: the size of the return array, default to 9999
      #  filters <hash>: filter that will be apply on the set. the key is the
      #    the field of the model, and the value is the value the records need
      #    to match to. multiple key, value will be chained by AND logic
      #return:
      #  an hash of factes, with key is the field name, and value is the facets
      #  result hash
      def filterd_facets(fields, filters = {}, size = 9999)
        unless fields.kind_of? Array
          fields = [fields]
        end

        result = search do
          setup_facets_filter = lambda do |arg|
            filter_query =
              filters.map do |f_key, f_val|
                if f_val.kind_of? Array
                  f_val.each_with_object({bool: {should: []}}) do |val, bool_query_hash|
                    bool_query_hash[:bool][:should] << {term: {f_key => val}}
                  end
                else
                  {term: {f_key => f_val}}
                end
              end
            send(:facet_filter, :bool, { must: filter_query })
          end
          setup_facets = lambda do |arg|
            fields.each do|field_name|
              facet(field_name.to_s, global: true) do
                terms field_name, size: size
                instance_eval(&setup_facets_filter)
              end
            end
          end

          instance_eval(&setup_facets)
          size 0 #serach result set size, we don't care them here
        end

        result.facets
      end

      def update_all(&block)
         Tire::Search::Scan.new(self.index.name).each do |results|
           json_collections = results.map(&:as_json)
           block.call(json_collections)
           self.index.bulk_store(json_collections)
         end
      end

      #loop through all records in the index and do something with each record
      #or a batch of records
      #params:
      #   options: {
      #     current_page <integer>: #default to 1
      #     per_page <integer>: #default to 100, each elastics query will return
      #       <per_page> records
      #     batch_mode <boolean>: #default to false, if it is true the block argument
      #       will be an array of records
      #   },
      #   &block: takes one param <record>, or an array of record if batch_mode = true
      #return: none
      def loop_all(options = {}, &block)
        options.reverse_merge!(
          current_page: 1,
          per_page: 100,
          batch_mode: false
        )
        current_page = options[:current_page]
        while (result = search(page: current_page,
            per_page: options[:per_page]) {query {all}}).size > 0
          if options[:batch_mode]
            block.call(result)
          else
            result.each do |obj|
              block.call(obj)
            end
          end
          current_page += 1
        end
      end
    end

  end #of ClassMethods
end
