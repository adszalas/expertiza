class RemoveFieldsFromFeedback < ActiveRecord::Migration
  def self.up
    begin
      remove_column :review_feedbacks, :feedback_at
    rescue
    end
   
    begin 
      rename_column :review_feedbacks, :additional_comments, :additional_comment
    rescue      
    end
      
    ReviewFeedback.find(:all).each{
      |feedback|
      if feedback.txt != nil
        feedback.additional_comment = feedback.txt
        feedback.save
      end
    }
    
    begin
      remove_column :review_feedbacks, :txt
    rescue
    end
  end

  def self.down
  end
end
