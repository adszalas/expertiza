class ReviewFeedbackController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @review_feedback_pages, @review_feedbacks = paginate :review_feedbacks, :per_page => 10
  end

  def show
    @review_feedback = ReviewFeedback.find(params[:id])
  end

  def new
    @review_feedback = ReviewFeedback.new
  end

  def create
    @review_feedback = ReviewFeedback.new(params[:review_feedback])
    if @review_feedback.save
      flash[:notice] = 'ReviewFeedback was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @review_feedback = ReviewFeedback.find(params[:id])
  end

  def update
    @review_feedback = ReviewFeedback.find(params[:id])
    if @review_feedback.update_attributes(params[:review_feedback])
      flash[:notice] = 'ReviewFeedback was successfully updated.'
      redirect_to :action => 'show', :id => @review_feedback
    else
      render :action => 'edit'
    end
  end

  def destroy
    ReviewFeedback.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  # Action implemented for editing the feedback rubric already entered
  def edit_feedback
  @a = (params[:id3])
    @b = (params[:id2])
    # Find entry in ReviewFeedback table with passed review id and author id
    @reviewfeedback = ReviewFeedback.find(:first, :conditions =>["review_id =? AND author_id = ?", @a, @b])
  
  #@reviewfeedback = ReviewFeedback.find_by_review_id(params[:id3])
    @assgt_id = params[:id1]
    @author_id = params[:id2]
    @review_id = params[:id3]
    @assignment = Assignment.find(@assgt_id)
    @questions = Question.find(:all,:conditions => ["questionnaire_id = ?", @assignment.author_feedback_questionnaire_id]) 
    @rubric = Questionnaire.find(@assignment.author_feedback_questionnaire_id)
    @max = @rubric.max_question_score
    @min = @rubric.min_question_score  
    
  end

  #Action for entering a new feedback
  #Find the questions for particular feedback from Questions table and display those questions
  def new_feedback
    @review_feedback = ReviewFeedback.new
    @assgt_id = params[:id1]
    @author_id = params[:id2]
    @review_id = params[:id3]
    @assignment = Assignment.find(@assgt_id)
    @questions = Question.find(:all,:conditions => ["questionnaire_id = ?", @assignment.author_feedback_questionnaire_id]) 
    @rubric = Questionnaire.find(@assignment.author_feedback_questionnaire_id)
    @max = @rubric.max_question_score
    @min = @rubric.min_question_score  
      
    
  end
  #Action for creating a new feedback record in the ReviewFeedback table.
  #Save the comments of Feedback in review scores table and the additional cooment in ReviewFeedback table
  def create_feedback
    params.each do |elem|
    puts "#{elem[0]}, #{elem[1]}" 
    end
    
    @review_feedback = ReviewFeedback.new
    @assgt_id = params[:assgt_id]
    @author_id = params[:author_id]
    @review_id = params[:review_id]
    
    @review_feedback.additional_comments = params[:new_feedback][:comments]
    @review_feedback.assignment_id = @assgt_id
    @review_feedback.author_id = @author_id
    @review_feedback.review_id = @review_id

    if params[:new_review_score]
        for review_key in params[:new_review_score].keys
        rs = ReviewScore.new(params[:new_review_score][review_key])
        rs.review_id = @review_id
        rs.question_id = params[:new_question][review_key]
        rs.score = params[:new_score][review_key]
        rs.questionnaire_type_id = 4        
        @review_feedback.review_scores<< rs
      end      
    end
    if @review_feedback.save
      flash[:notice] = 'ReviewFeedback was successfully created.'
      redirect_to :action=> 'view_feedback', :id1 =>params[:assgt_id], :id2 =>params[:author_id], :id3=>params[:review_id]
    end
    @review_scores = ReviewScore.find(:all,:conditions =>["review_id = ? and questionnaire_type_id = ?", @review_id, '4'])
    for review_score in @review_scores
    review_score.review_id = @review_feedback.id
    review_score.update
    end
  end
 
  #Action for updating a previous feedback and inserting new values in the ReviewFeedback and ReviewScores table
  def update_feedback
    @a = (params[:review_id])
    @b = (params[:author_id])
    @reviewfeedback = ReviewFeedback.find(:first, :conditions =>["review_id =? AND author_id = ?", @a, @b])
    @reviewfeedback.additional_comments = params[:new_reviewfeedback][:comments]
    @rev_id = @reviewfeedback.id
    @author_id = params[:author_id]
    @assgt_id = params[:assgt_id]
    if params[:new_review_score]
      # The new_question array contains all the new questions
      # that should be saved to the database
      for review_key in params[:new_review_score].keys
        question_id = params[:new_question][review_key]
        rs = ReviewScore.find(:first,:conditions => ["review_id = ? AND question_id = ?", @rev_id, question_id])
        rs.comments = params[:new_review_score][review_key][:comments]
        rs.score = params[:new_score][review_key]
        rs.questionnaire_type_id = "4"
        rs.update
      end      
    end
    if @reviewfeedback.update
      flash[:notice] = 'Review was successfully updated.'
      redirect_to :action=> 'view_feedback', :id1 =>params[:assgt_id], :id2 =>params[:author_id], :id3=>params[:review_id]
    end    
  end
  
  # Action for Viewing the Feedback previously entered.
  def view_feedback
    @a = (params[:id3])
    @b = (params[:id2])
    @reviewfeedback = ReviewFeedback.find(:first, :conditions =>["review_id =? AND author_id = ?", @a, @b])
    #@reviewfeedback = ReviewFeedback.find_by_review_id(params[:id3]) 
    @review_id = @reviewfeedback.id
    puts @review_id
    @review_scores = ReviewScore.find(:all,:conditions =>["review_id =? AND questionnaire_type_id = ?", @review_id, '4'])
    @assgt_id = params[:id1]
    @author_id = params[:id2]
    @assgt = Assignment.find(@assgt_id)
    @questions = Question.find(:all,:conditions => ["questionnaire_id = ?", @assgt.author_feedback_questionnaire_id])
  end
  
  
  # Action for Instructor to view a review given by the reviwer to an author. The author Feedback will also be available through this action
  def view_feedback_instructor 
    @reviewfeedback = ReviewFeedback.find(:all, :conditions =>["review_id =? AND author_id = ?", (params[:id3]), (params[:id2])]) 
    @review_id = @reviewfeedback.id
    @review_scores = ReviewScore.find(:all,:conditions =>["review_id =? AND questionnaire_type_id = ?", @review_id, '4'])
    @assgt_id = params[:id1]
    @author_id = params[:id2]
    @assgt = Assignment.find(@assgt_id)
    @questions = Question.find(:all,:conditions => ["questionnaire_id = ?", @assgt.author_feedback_questionnaire_id])
  end  
  
end