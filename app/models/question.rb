class Question < ActiveRecord::Base
    belongs_to :questionnaire
    belongs_to :review_score  # each review_score pertains to a particular question
    belongs_to :review_of_review_score  # ditto
    has_many :question_advices # for each question, there is separate advice about each possible score
    has_many :signup_choices
    
    validates_presence_of :txt
    validates_presence_of :weight
    validates_numericality_of :weight
    
    NUMERIC = 'Numeric'
    TRUE_FALSE = 'True/False'

    GRADING_TYPES = [[NUMERIC,false],[TRUE_FALSE,true]]
    WEIGHTS = [['1',1],['2',2],['3',3],['4',4],['5',5]]
    
    attr_accessor :checked
end
