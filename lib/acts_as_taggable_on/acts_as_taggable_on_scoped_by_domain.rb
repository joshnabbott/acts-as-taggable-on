module ActsAsTaggableOnScopedByDomain
  ActiveRecord::Acts::TaggableOn::SingletonMethods.module_eval do
    RAILS_DEFAULT_LOGGER.info "** Extended acts_as_taggable_on for domain scoping."

    def find_options_for_find_tagged_with_with_domain_id(tags, options = {})
      options = options.reverse_merge!(:conditions => ['domain_id = ?', Domain.current_domain_id])
      find_options_for_find_tagged_with_without_domain_id(tags, options)
    end
    alias_method_chain :find_options_for_find_tagged_with, :domain_id

    def find_options_for_tag_counts_with_domain_id(options = {})
      options = options.reverse_merge!(:conditions => "domain_id = #{Domain.current_domain_id}")
      find_options_for_tag_counts_without_domain_id(options)
    end
    alias_method_chain :find_options_for_tag_counts, :domain_id
  end

  Tagging.instance_eval <<-EOV
    before_validation :set_domain_id
    validates_presence_of :domain_id
  EOV

  Tagging.class_eval <<-EOV
    def set_domain_id
      self.domain_id = Domain.current_domain_id if self.domain_id.nil?
    end
  EOV
end