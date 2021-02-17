module PrefixedIds
  class Engine < ::Rails::Engine
    initializer "prefixed_ids.model" do
      ActiveSupport.on_load(:active_record) do
        include PrefixedIds::Attribute
      end
    end
  end
end
