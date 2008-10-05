class ReviewFeedback < ActiveRecord::Base
    has_many :review_scores
    belongs_to :review
    belongs_to :assignment
    
  def display_as_html(prefix) 
    code = "<B>Author:</B> "+self.review.review_mapping.reviewee.name+'&nbsp;&nbsp;&nbsp;<a href="#" name= "feedback_'+prefix+"_"+self.id.to_s+'Link" onClick="toggleElement('+"'feedback_"+prefix+"_"+self.id.to_s+"','feedback'"+');return false;">hide feedback'
    code = code + '<div id="feedback_'+prefix+"_"+self.id.to_s+'" style="">'   
    code = code + '<BR/><BR/>'
    questions_query = "select id from questions where questionnaire_id = "+self.assignment.author_feedback_questionnaire_id.to_s    
    scores = ReviewScore.find_by_sql("select * from review_scores where review_id = "+self.id.to_s+" and question_id in ("+questions_query+")")
    
    scores.each{
      | reviewScore |      
      code = code + "<I>"+reviewScore.question.txt+"</I><BR/><BR/>"
      code = code + '(<FONT style="BACKGROUND-COLOR:gold">'+reviewScore.score.to_s+"</FONT> out of <B>"+reviewScore.question.questionnaire.max_question_score.to_s+"</B>): "+reviewScore.comments+"<BR/><BR/>"
    }          
    if self.additional_comment != nil
      comment = self.additional_comment.gsub('^p','').gsub(/\n/,'<BR/>&nbsp;&nbsp;&nbsp;')
    elsif self.txt != nil
      comment = self.txt.gsub('^p','').gsub(/\n/,'<BR/>&nbsp;&nbsp;&nbsp;')
    else
      comment = ""
    end
    code = code + "<B>Additional Comment:</B><BR/>"+comment+""
    code = code + "</div>"
    return code
  end     
    
    def reviewer
      self.review.review_mapping.reviewee      
    end
  
    def reviewee
      self.review.review_mapping.reviewer
    end
  
 # Computes the total score awarded for a feedback
  def get_total_score
    questions_query = "select id from questions where questionnaire_id = "+self.assignment.author_feedback_questionnaire_id.to_s
    
    scores = ReviewScore.find_by_sql("select * from review_scores where review_id = "+self.id.to_s+" and question_id in ("+questions_query+")")
    total_score = 0
    scores.each{
      |item|
      total_score += item.score
    }   
    return total_score
  end
end
