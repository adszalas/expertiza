class CreateReviews < ActiveRecord::Migration
  # This table should have essentially the same format as review_of_reviews
  def self.up
    create_table :reviews do |t|
      t.column :reviewed_at, :datetime  # time that the review was saved
      t.column :review_mapping_id, :integer  # the entry in the review_mappings table identifies reviewer and reviewee
    end
    execute "alter table reviews
             add constraint fk_review_mappings
             foreign key (review_mapping_id) references review_mappings(id)"
  end

  def self.down
    drop_table :reviews
  end
end
