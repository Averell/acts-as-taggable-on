module ActsAsTaggableOn
  class Tagging < ::ActiveRecord::Base #:nodoc:
    attr_accessible :tag,
                    :tag_id,
                    :context,
                    :taggable,
                    :taggable_type,
                    :taggable_id,
                    :tagger,
                    :tagger_type,
                    :tagger_id

    belongs_to :tag, :class_name => 'ActsAsTaggableOn::Tag'
    belongs_to :taggable, :polymorphic => true
    belongs_to :tagger,   :polymorphic => true

    validates_presence_of :context
    validates_presence_of :tag_id

    validates_uniqueness_of :tag_id, :scope => [ :taggable_type, :taggable_id, :context, :tagger_id, :tagger_type ]

    before_save   :set_taggable_context_crc32
    after_destroy :remove_unused_tags

    def self.taggable_context_crc32(taggable_class, taggable_id, context)
      Zlib.crc32("#{taggable_class}-#{taggable_id}-#{context}")
    end
    
    def self.taggable_context_crc32?
      @@has_taggable_context_crc32 ||= column_names.include?("taggable_context_crc32")
    end
    
    private

    def remove_unused_tags
      if Tag.remove_unused
        if tag.taggings.count.zero?
          tag.destroy
        end
      end
    end
    
    def set_taggable_context_crc32
      write_attribute :taggable_context_crc32, self.class.taggable_context_crc32(taggable_type, taggable_id, context)
    end
  end
end