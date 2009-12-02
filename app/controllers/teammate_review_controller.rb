class TeammateReviewController < ApplicationController
  helper :review
  
  def new
    @mapping = TeammateReviewMapping.find(params[:id])
    @questionnaire = @mapping.assignment.questionnaires.find_by_type('TeammateReviewQuestionnaire')
    @questions = @questionnaire.questions
    @max = @questionnaire.max_question_score
    @min = @questionnaire.min_question_score
  end
  
  def create
    map = TeammateReviewMapping.find(params[:id])
    @response = TeammateReview.create(:mapping_id => map.id, :additional_comment => params[:review][:comments])
    @questionnaire = map.assignment.questionnaires.find_by_type('TeammateReviewQuestionnaire')
    questions = @questionnaire.questions     
    
    params[:responses].each_pair do |k,v|
      score = Score.create(:instance_id => @response.id, :question_id => questions[k.to_i].id,
                           :score => v[:score], :comments => v[:comment])
    end      
    
    compare_scores
    flash[:note] = 'Teammate review was successfully saved.'
    redirect_to :controller => 'student_team', :action => 'view', :id => map.reviewer.id
  end


  def view
    @response = TeammateReview.find(params[:id])
  end  

  def edit
    @response = TeammateReview.find(params[:id]) 
    @mapping = @response.mapping
    @questionnaire = @response.mapping.assignment.questionnaires.find_by_type('TeammateReviewQuestionnaire')
    @questions = @questionnaire.questions    
    @review_scores = Array.new
    @questions.each{
      | question |
      @review_scores << Score.find_by_instance_id_and_question_id(@response.id, question.id)
    }
    @min = @questionnaire.min_question_score
    @max = @questionnaire.max_question_score    
  end 
 
  def update
    map = TeammateReviewMapping.find(params[:id])
    @response = TeammateReview.find_by_mapping_id(map.id)
    @response.additional_comment = params[:review][:comments]
    @response.save
    
    @questionnaire = @response.mapping.assignment.questionnaires.find_by_type('TeammateReviewQuestionnaire')
    questions = @questionnaire.questions

    params[:responses].each_pair do |k,v|
      score = Score.find_by_instance_id_and_question_id(@response.id, questions[k.to_i].id)
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
    total, count = ReviewHelper.get_total_scores(participant.get_teammate_reviews,@response)     
    if count > 0
      ReviewHelper.notify_instructor(@response.mapping.assignment,@response,@questionnaire,total,count)
    end
  end   
  
end