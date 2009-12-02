class ReviewFeedbackController < ApplicationController
    # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }
         
  def new
    @review = Review.find(params[:id]) 
    reviewer = AssignmentParticipant.find_by_user_id_and_parent_id(session[:user].id, @review.mapping.assignment.id)
    reviewee = @review.mapping.reviewer
    @mapping = FeedbackMapping.create(:reviewed_object_id => @review.id, :reviewer_id => reviewer.id, :reviewee_id => reviewee.id)
    @questionnaire = @mapping.assignment.questionnaires.find_by_type('AuthorFeedbackQuestionnaire')
    @questions = @questionnaire.questions
    @min = @questionnaire.min_question_score
    @max = @questionnaire.max_question_score
  end
  
  def create
    map = FeedbackMapping.find(params[:id])
    @response = ReviewFeedback.create(:mapping_id => map.id, :additional_comment => params[:review][:comments])
    @questionnaire = map.assignment.questionnaires.find_by_type('AuthorFeedbackQuestionnaire')
    questions = @questionnaire.questions     
    
    params[:responses].each_pair do |k,v|
      score = Score.create(:instance_id => @response.id, :question_id => questions[k.to_i].id, :score => v[:score], :comments => v[:comment])
    end      
    
    compare_scores
    flash[:note] = 'Feedback was successfully saved.'
    redirect_to :controller => 'grades', :action => 'view_my_scores', :id => map.reviewer.id
  end
  
  def view    
    @response = ReviewFeedback.find(params[:id])
    @review = @response.mapping.review
  end
  
  def edit
    @response = ReviewFeedback.find(params[:id]) 
    @review = @response.mapping.review
    @mapping = @response.mapping
    @questionnaire = @response.mapping.assignment.questionnaires.find_by_type('AuthorFeedbackQuestionnaire')
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
    map = FeedbackMapping.find(params[:id])
    @response = ReviewFeedback.find_by_mapping_id(map.id)
    @response.additional_comment = params[:review][:comments]
    @response.save
    
    @questionnaire = @response.mapping.assignment.questionnaires.find_by_type('AuthorFeedbackQuestionnaire')
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
    
    redirect_to :controller => 'student_task', :action => 'view_scores', :id => map.reviewer.id
  end
  
  # Compute the currently awarded scores for the reviewee
  # If the new feedback's score is greater than or less than 
  # the existing scores by a given percentage (defined by
  # the instructor) then notify the instructor.
  def compare_scores      
    participant = @response.mapping.reviewee                    
    total, count = ReviewHelper.get_total_scores(participant.get_feedback,@response)     
    if count > 0
      ReviewHelper.notify_instructor(@response.mapping.assignment,@response,@questionnaire,total,count)
    end
  end
  
end
