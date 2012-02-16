class ActsAsTaggableOnMigration < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.string :name
    end

    create_table :taggings do |t|
      t.references :tag

      # You should make sure that the column created is
      # long enough to store the required class names.
      t.references :taggable, :polymorphic => true
      t.references :tagger, :polymorphic => true

      # limit is created to prevent mysql error o index lenght for myisam table type.
      # http://bit.ly/vgW2Ql
      t.string :context, :limit => 128

      t.column :taggable_context_crc32, "INT(4) UNSIGNED", :null => false

      t.datetime :created_at
    end

    add_index :taggings, :tag_id
    add_index :taggings, [:taggable_context_crc32, :taggable_id, :taggable_type, :context, :tagger_id, :tagger_type, :tag_id], :name=>"taggable_crc32_context_tagger_tag_index"
    add_index :taggings, [:taggable_id, :taggable_type, :context, :tagger_id, :tagger_type, :tag_id], :name=>"taggable_context_tagger_tag_index", :unique=>true
  end

  def self.down
    drop_table :taggings
    drop_table :tags
  end
end
