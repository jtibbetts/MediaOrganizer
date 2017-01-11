class Registry < ActiveRecord::Base
  attr_accessible :name, :value

  # def initialize()
  #   @registry_hash = {}
  # end
  #
  # def [](key)
  #   unless @registry_hash.include? key
  #     registry_obj = Registry.where(:name => key).first
  #     @registry_hash[key] = registry_obj.value unless registry_obj.blank?
  #   end
  #   @registry_hash[key]
  # end
end
