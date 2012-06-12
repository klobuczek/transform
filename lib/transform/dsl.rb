module Transform
  class Dsl
    @@graph = Transform::Graph.new
    class << self
      # Database is defined as one or more collections
      # Collection is an array of tuple instances
      # Tuple consists of one or more fields

      # Load a collection from a csv file
      # filename - the name of a csv file
      # collection - name of the newly created collection
      # fields - names of fields
      # e.g.
      # load "sale.csv", :sale, :currentQuantityBUM, :currentSpend, :currentGP, :baselineIUMperBUM, :baselinePriceBUM, :marginCost, :material_id
      def load_collection collection_name, filename, *fields
        @@graph.add(collection_name, filename, operation: :load_collection, fields: fields)
      end

      # perform calculation on a tuple instance returning a single value (or tuple of size one) per tuple instance
      # new_collection - name of the collection created as a result of the calculation
      # collection - name of the collection the calculation should be performed on
      # block - block returning the result per row
      # e.g.
      # calculate(:suggested_discount_price, :sale)  { |sale| sale.baselinePriceBUM.divide(sale.baselineIUMperBUM) }
      def calculate new_collection, collection, &block
        @@graph.add(new_collection, collection, operation: :calculate, &block)
      end

      # combine 2 or more collections into one
      # new_collection - name of the new combined collection
      # collections - names of collections to combine together
      # block - block evaluating to a join condition, default is simple linear composition
      # e.g.
      # compose :scenario1PriceIUM, :suggested_discount_price, :proposed_deliverred_price
      def compose new_collection, *collections, &block
        @@graph.add(new_collection, collections, operation: :compose, &block)
      end

      # restrict the tuple to specified elements
      # new_collection - name of the new combined collection
      # collection - name of collection to be restricted
      # fields - to be taken over to the new collection
      # e.g.
      # slice :mini_sale, :sale, :currentSpend, :currentGP
      def slice new_collection, collection, *fields
        @@graph.add(new_collection, collections, operation: :slice)
      end

      # filter the collection to rows complying with condition
      # new_collection - name of the new combined collection
      # collection - name of the collection to be filtered
      # block - condition that has to evaluate true for the row to be included in the filtered collection
      # e.g.
      # filter(:filtered_tuple, :tuple) {|row| row.amount > 1}
      def filter new_collection, collection, &block
        @@graph.add(new_collection, collections, operation: :filter, &block)
      end

      # aggreagate over all tuple instances
      # new_collection - name of the new combined collection
      # collection - name of the collection to be aggregated over
      # initial_value - the initial value for the aggregation
      # block - inject type block that is called for every row in the collection
      # e.g.
      # aggregate :adjusted_impact, :suggested_discount_price, 0, {|sum, sdp| sum+=sdp }
      def aggregate new_collection, collection, initial_value, &block

      end

      # store a tuple to a csv file
      # collection - name of the collection to be stored
      # filename - name of file to store the collection in
      # e.g.
      # store :tuple1, "tuple1.csv"
      def store collection, filename
        @@graph.add(collection, filename, operation: :store)
      end

      def draw(&block)
        instance_eval &block
      end

      def graph
        @@graph
      end
    end
  end
end