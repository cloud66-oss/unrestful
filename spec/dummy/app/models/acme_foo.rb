class AcmeFoo
  include ActiveModel::Serializers::JSON

  attr_accessor :from, :to

  def attributes
    instance_values
  end

end