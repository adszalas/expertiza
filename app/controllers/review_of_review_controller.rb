class ReviewOfReviewController < ApplicationController
  helper :review
  
  def new
    @mapping = ReviewOfReviewMapping.find(params[:id])
    @review = Review.find_by_mapping_id(@mapping.review_mapping.id)
    @assignment = @mapping.assignment
    @participant = AssignmentParticipant.find_by_user_id_and_parent_id(session[:user].id,@assignment.id)    
    @questionnaire = Questionnaire.find(@assignment.review_of_review_questionnaire_id)
    @questions = @questionnaire.questions
    @min = @questionnaire.min_question_score
    @max = @questionnaire.max_question_score    
  end
  
  def create
    map = ReviewOfReviewMapping.find(params[:id])
    @response = ReviewOfReview.create(:mapping_id => map.id, :additional_comment => params[:review][:comments])
    @questionnaire = Questionnaire.find(map.assignment.review_of_review_questionnaire_id)
    questions = @questionnaire.questions     
    
    params[:responses].each_pair do |k,v|
      score = Score.create(:instance_id => @response.id, :question_id => questions[k.to_i].id,
                           :questionnaire_type_id => @questionnaire.type_id, :score => v[:score], :comments => v[:comment])
    end      
    
    compare_scores
    flash[:note] = 'Metarevew was successfully saved.'
    redirect_to :controller => 'student_review', :action => 'list', :id => map.reviewer.id
  end


  def view
    @response = ReviewOfReview.find(params[:id])
    @mapping = @response.mapping
    @assignment = @mapping.assignment
    @participant = AssignmentParticipant.find_by_user_id_and_parent_id(session[:user].id,@assignment.id)    
    @review = Review.find_by_mapping_id(@mapping.review_mapping.id)    
  end  

  def edit    
    @response = ReviewOfReview.find(params[:id]) 
    @mapping = @response.mapping
    @review = Review.find_by_mapping_id(@mapping.review_mapping.id)    
    
    @assignment = @mapping.assignment
    @participant = AssignmentParticipant.find_by_user_id_and_parent_id(session[:user].id,@assignment.id)    
        
    @questionnaire = Questionnaire.find(@assignment.review_of_review_questionnaire_id)
    @questions = @questionnaire.questions
    @min = @questionnaire.min_question_score
    @max = @questionnaire.max_question_score     
    @review_scores = Score.find_all_by_instance_id_and_questionnaire_type_id(@response.id, @questionnaire.type_id)   
  end 
 
  def update
    map = ReviewOfReviewMapping.find(params[:id])
    @response = ReviewOfReview.find_by_mapping_id(map.id)
    @response.additional_comment = params[:review][:comments]
    @response.save
    
    @questionnaire = Questionnaire.find(@response.mapping.assignment.review_of_review_questionnaire_id)
    questions = @questionnaire.questions

    params[:responses].each_pair do |k,v|
      score = Score.find_by_instance_id_and_question_id_and_questionnaire_type_id(@response.id, questions[k.to_i].id, @questionnaire.type_id)
      score.score = v[:score]
      score.comments = v[:comment]
      score.save
    end    
    
    #determine if the new review meets the criteria set by the instructor's 
    #notification limits      
    compare_scores
    
    redirect_to :controller => 'student_team', :action => 'view', :id => map.reviewer.id
  end
  
  
  # Compute the currently awarded scores for the reviewee
  # If the new teammate review's score is greater than or less than 
  # the existing scores by a given percentage (defined by
  # the instructor) then notify the instructor.
  # ajbudlon, nov 18, 2008
  def compare_scores      
    participant = @response.mapping.reviewee                    
    total, count = ReviewHelper.get_total_scores(participant.get_metareviews,@response)     
    if count > 0
      ReviewHelper.notify_instructor(@response.mapping.assignment,@response,@questionnaire,total,count)
    end
  end   
   
end