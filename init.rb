# Include hook code here

ActiveRecord::Base.instance_eval do
  def habto(*args)
    has_and_belongs_to_one(*args)
  end

  def has_and_belongs_to_one(name, options = {})
    include Habto
    define_habto(name.to_s, options)
  end
end

