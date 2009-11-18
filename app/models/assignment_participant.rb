class AssignmentParticipant < Participant  
  require 'wiki_helper'
  belongs_to :assignment, :class_name => 'Assignment', :foreign_key => 'parent_id'
  has_many :review_mappings, :class_name => 'ParticipantReviewMapping', :foreign_key => 'reviewee_id'
  validates_presence_of :handle

  #Copy this participant to a course
  def copy(course_id)
    part = CourseParticipant.find_by_user_id_and_parent_id(self.user_id,course_id)
    if part.nil?
       CourseParticipant.create(:user_id => self.user_id, :parent_id => course_id)       
    end
  end  
  
  def get_course_string
    # if no course is associated with this assignment, or if there is a course with an empty title, or a course with a title that has no printing characters ...
    if self.assignment.course == nil or self.assignment.course.name == nil or self.assignment.course.name.strip == ""
      return "<center>&#8212;</center>"
    end
    return self.assignment.course.name
  end
  
  def get_feedbacks
    maps = FeedbackMapping.find_all_by_reviewee_id(self.id)
    feedbacks = Array.new
    maps.each{
      | map | 
      feedback = ReviewFeedback.find_by_mapping_id(map.id)
      if feedback
        feedbacks << feedback
      end
    }
    return feedbacks.sort {|a,b| a.mapping.reviewer.name <=> b.mapping.reviewer.name}    
  end
  
  def get_reviews
    if self.assignment.team_assignment
      return self.team.get_reviews
    else
      reviews = Review.find(:all, :include => :mapping, :conditions => ['reviewee_id = ? and reviewed_object_id = ?',self.id, self.assignment.id])
      return reviews.sort {|a,b| a.mapping.reviewer.fullname <=> b.mapping.reviewer.fullname }
    end
  end
  
  def get_reviews_by_me
    if Assignment.find(self.parent_id).team_assignment
      author_id = get_team().id
      query = "team_id = ? and assignment_id = ?"
    else
      author_id = self.user_id
      query = "author_id = ? and assignment_id = ?"
    end
    
    return ReviewMapping.find(:all, :conditions => [query,author_id,self.parent_id])
  end
  
  def get_metareviews
    reviews = ReviewOfReview.find(:all, :include => :mapping, :conditions => ['reviewee_id = ?',self.id])
    return reviews.sort {|a,b| a.mapping.reviewer.fullname <=> b.mapping.reviewer.fullname }      
  end
  
  def get_teammate_reviews   
    maps = TeammateReviewMapping.find(:all, :conditions => ['reviewee_id = ?',self.id])
    reviews = Array.new
    maps.each{    
      | map |
      review = TeammateReview.find_by_mapping_id(map.id)  
      if review
        reviews << review
      end
    }
    return reviews.sort {|a,b| a.mapping.reviewer.fullname <=> b.mapping.reviewer.fullname}     
  end
  
  def has_submissions    
    if (self.submitted_hyperlink and self.submitted_hyperlink.strip.length > 0)
      hplink = true
    else
      hplink = false
    end
    return ((get_submitted_files.length > 0) or 
            (get_wiki_submissions.length > 0) or 
            (hplink)) 
  end
 
  def get_submitted_files()
    files = Array.new
    if(self.directory_num)      
      files = get_files(self.get_path)
    end
    return files
  end  
  
  def get_files(directory)
      files_list = Dir[directory + "/*"]
      files = Array.new
      for file in files_list
        if not File.directory?(Dir.pwd + "/" + file) then
          files << file
        else
          dir_files = get_files(file)
          dir_files.each{|f| files << f}
        end
      end
      return files
  end
  
  def get_wiki_submissions
    currenttime = Time.now.month.to_s + "/" + Time.now.day.to_s + "/" + Time.now.year.to_s
 
    if self.assignment.team_assignment and self.assignment.wiki_type.name == "MediaWiki"
       submissions = Array.new
       self.team.get_participants.each {
         | user |
         val = WikiType.review_mediawiki_group(self.assignment.directory_path, currenttime, user.handle)
         puts val
         if val != nil
            submissions << val
         end                 
       }
       return submissions
    elsif self.assignment.wiki_type.name == "MediaWiki"
       return WikiType.review_mediawiki(self.assignment.directory_path, currenttime, self.handle)       
    elsif self.assignment.wiki_type.name == "DocuWiki"
       return WikiType.review_docuwiki(self.assignment.directory_path, currenttime, self.handle)             
    else
       return Array.new
    end
  end    
  
  def name
    self.user.name
  end
    
  def team
       AssignmentTeam.get_team(self)  
  end
    
  #computes this participant's current teammate review scores:
  def compute_teammate_review_scores(questionnaire, questions)
    assignment = Assignment.find(self.parent_id) 
    if assignment.team_assignment 
      teammate_reviews = self.get_teammate_reviews      
      if teammate_reviews.length > 0
        avg_review_score, max_score, min_score = AssignmentParticipant.compute_scores(teammate_reviews, questionnaire)
        return avg_review_score, max_score, min_score
      else
        return nil, nil, nil
    end
   end
  end 
  
  #computes this participants current metareview score
  #metareview = review_of_review
  def compute_metareview_scores(questionnaire, questions)
    metareviews = self.get_metareviews
    if metareviews.length > 0
      avg_metareview_score, max_score,min_score = AssignmentParticipant.compute_scores(metareviews, questionnaire)
      return avg_metareview_score, max_score, min_score
    else
      return nil, nil, nil
    end
  end
 
  #computes this participants current author feedback score
  def compute_author_feedback_scores(questionnaire, questions)    
    feedbacks = self.get_feedbacks
    if feedbacks.length > 0
      avg_feedback_score, max_score,min_score = AssignmentParticipant.compute_scores(feedbacks, questionnaire)
      return avg_feedback_score, max_score, min_score
    else
      return nil, nil, nil
    end
  end  
  
  #computes this participants current review score  
  def compute_review_scores(questionnaire, questions)
    assignment = Assignment.find(parent_id)
    if assignment.team_assignment
      return self.team.compute_review_scores(questionnaire, questions)
    else
      reviews = self.get_reviews
      if reviews.length > 0
        avg_review_score, max_score,min_score = AssignmentParticipant.compute_scores(reviews, questionnaire)
        return avg_review_score.to_f, max_score, min_score
      else
        return nil, nil, nil
    end
   end    
 end 
  
  def compute_total_score(review_score, metareview_score, authorfeedback_score, teammate_review_score) 
    r_score = 0;
    m_score = 0;
    a_score = 0;
    t_score = 0;
    if review_score            
      r_score = review_score.to_f * (self.assignment.review_weight / 100).to_f      
    end    
    if metareview_score
      m_score = metareview_score.to_f * (self.assignment.metareview_weight / 100).to_f      
    end
    if authorfeedback_score
      a_score = authorfeedback_score.to_f * (self.assignment.author_feedback_weight / 100).to_f
    end    
    if self.assignment.team_assignment && teammate_review_score
      t_score = teammate_review_score.to_f * (self.assignment.teammate_review_weight / 100).to_f
    end    
    total = r_score + m_score + a_score + t_score
    return total;
  end  
  
  # Computes the total score for a list of assessments
  # parameters
  #  list - a list of assessments of some type (e.g., author feedback, teammate review)
  #  questionnaire - the questionnaire that was filled out in the process of doing those assessments
  #  questionnaire_type - an integer value representing REVIEW, AUTHOR_FEEDBACK, etc.
  def self.compute_scores(list, questionnaire)
    max_score = -999999999
    min_score = 999999999
    total_score = 0
    list.each {
      | item | 
       curr_score = Score.get_total_score(item.id, questionnaire)       
       if curr_score > max_score
         max_score = curr_score
       end
       if curr_score < min_score
         min_score = curr_score
       end        
       total_score += curr_score       
    }
    average_score = total_score.to_f / list.length.to_f
    return average_score, max_score, min_score
  end
  

  
  # provide import functionality for Assignment Participants
  # if user does not exist, it will be created and added to this assignment
  def self.import(row,session,id)    
    if row.length < 1
       raise ArgumentError, "No user id has been specified." 
    end
    user = User.find_by_name(row[0])        
    if (user == nil)
      if row.length < 4
        raise ArgumentError, "The record containing #{row[0]} does not have enough items."
      end
      attributes = ImportFileHelper::define_attributes(row)
      user = ImportFileHelper::create_new_user(attributes,session)
    end                  
    if Assignment.find(id) == nil
       raise ImportError, "The assignment with id \""+id.to_s+"\" was not found."
    end
    if (find(:all, {:conditions => ['user_id=? AND parent_id=?', user.id, id]}).size == 0)
          newpart = AssignmentParticipant.create(:user_id => user.id, :parent_id => id)
          newpart.set_handle()
    end             
  end  
  
  # provide export functionality for Assignment Participants
  def self.export(csv,parent_id)
     find_all_by_parent_id(parent_id).each{
          |part|
          user = User.find(part.user_id)
          csv << [
            user.name,
            user.fullname,          
            user.email,
            user.role.name,
            user.parent.name,
            user.email_on_submission,
            user.email_on_review,
            user.email_on_review_of_review,
            part.handle
          ]
      } 
  end
  
  def self.get_export_fields
    fields = ["name","full name","email","role","parent","email on submission","email on review","email on metareview","handle"]
    return fields            
  end
  
  #define a handle for a new participant
  def set_handle()
    if self.user.handle == nil or self.user.handle == ""
      self.handle = self.user.name
    else
      if AssignmentParticipant.find_all_by_parent_id_and_handle(self.assignment.id, self.user.handle).length > 0
        self.handle = self.user.name
      else
        self.handle = self.user.handle
      end
    end  
    self.save!
  end  
  
  def get_path
     path = self.assignment.get_path + "/"+ self.directory_num.to_s
     if self.id == 1117
        puts path
     end
     return path
  end
  
  def set_student_directory_num
    if self.directory_num.nil? or self.directory_num < 0           
      maxnum = AssignmentParticipant.find(:first, :conditions=>['parent_id = ?',self.parent_id], :order => 'directory_num desc').directory_num
      if maxnum
        self.directory_num = maxnum + 1
      else
        self.directory_num = 0
      end
      self.save
      self.team.get_participants.each{
          | member |
          if member.directory_num == nil or member.directory_num < 0
            member.directory_num = self.directory_num
            member.save
          end
      }
    end
  end   
end
