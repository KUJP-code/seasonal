PaperTrail.serializer = PaperTrail::Serializers::JSON

Rails.application.config.after_initialize do
  PaperTrail::Version.class_eval do
    acts_as_copy_target
  end
end
