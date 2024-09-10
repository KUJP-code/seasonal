PaperTrail.serializer = PaperTrail::Serializers::JSON

PaperTrail::Version.class_eval do
  acts_as_copy_target
end
