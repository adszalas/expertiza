class ReviewMapping < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :author, :class_name => "User", :foreign_key => "author_id"
  belongs_to :reviewer, :class_name => "User", :foreign_key => "reviewer_id"
  has_many :reviews
  has_many :review_of_review_mappings
  
  ##feedback added
  def self.assign_reviewers(assignment_id, num_reviews, num_review_of_reviews, mapping_strategy)
    @authors = Participant.find(:all, :conditions => ['assignment_id = ? and submit_allowed=1', assignment_id])
    @assignments = Assignment.find_by_id(assignment_id)
    @reviewers = Participant.find(:all, :conditions => ['assignment_id = ? and review_allowed=1', assignment_id])  
    
    due_date = DueDate.find(:all,:conditions => ["assignment_id = ?",assignment_id], :order => "round DESC", :limit =>1)
    @round = 1
    if (due_date[0] && !due_date[0].round.nil?)
      @round = due_date[0].round - 1
    end
    puts "rounds = ",@round
    for round_num in 1..@round
      puts "round# ",round_num
      stride = 1 # get_rel_prime(num_reviews, @reviewers.size)
      for i in 0 .. @reviewers.size - 1
        current_reviewer_candidate = i
        current_author_candidate = current_reviewer_candidate
        for j in 0 .. (@reviewers.size * num_reviews / @authors.size) - 1  # This method potentially assigns authors different #s of reviews, if limit is non-integer
          current_author_candidate = (current_author_candidate + stride) % @authors.size
          if (@assignments.team_assignment != true)
            ReviewMapping.create(:author_id => @authors[current_author_candidate].user_id, :reviewer_id => @reviewers[i].user_id, :assignment_id => assignment_id, :round => round_num)
          else
            team = TeamsUser.find(:first,:conditions=>["user_id =? and team_id in (select id from teams where assignment_id=?)", @authors[current_author_candidate].user_id, assignment_id])
            if team != nil
              team_id = team.team_id
              count = check_for_team(@reviewers[i].user_id, team_id)
              if count != nil
                ReviewMapping.create(:author_id => @authors[current_author_candidate].user_id, :reviewer_id => @reviewers[i].user_id, :assignment_id => assignment_id, :round => round_num, :team_id=>team_id)
              else
               val = get_next_reviewer(i, @reviewers, team_id) 
               ReviewMapping.create(:author_id => @authors[current_author_candidate].user_id, :reviewer_id => @reviewers[val].user_id, :assignment_id => assignment_id, :round => round_num, :team_id=>team_id)
              end
            end  
          end  
          ##
          puts 'Review Mapping created'
          ##
        end
      end
    end
  end
  ##
  
  def self.check_for_team(user_id, team_id)
    count = TeamsUser.find(:first, :conditions=>["user_id=? and team_id=?", user_id, team_id])
  end
  
  def self.get_next_reviewer(id, object, team_id)
    for count in id .. object.size - 1
      team = TeamsUser.find(:first, :conditions=>["team_id!=?",team_id])
      return count
    end  
  end
    
  def self.import_reviewers(file,assignment)
    File.open(file, "r") do |infile|
        while (rline = infile.gets)
          line_split = rline.split(",")
          author = User.find_by_name(line_split[0].strip)
          if (Participant.find(:all,{:conditions => ['user_id=? AND assignment_id=?', author.id, assignment.id]}).size > 0)
            for i in 1 .. line_split.size - 1              
              reviewer = User.find_by_name(line_split[i].strip)
              if (Participant.find(:all,{:conditions => ['user_id=? AND assignment_id=?', reviewer.id, assignment.id]}).size > 0)
                ReviewMapping.create(:author_id => author.id, :reviewer_id => reviewer.id, :assignment_id => assignment.id)
              end
            end
          end
        end
    end
  end
  
  def self.import(row,session)
    if row.length < 2
       raise ArgumentError, "Not enough items" 
    end
    
    author = User.find_by_name(row[0].to_s.strip)
    logger.info("*** Author: #{author} ***")
    
    index = 1
    while index < row.length
      reviewer = User.find_by_name(row[index].to_s.strip)
      logger.info("*** Reviewer: #{reviewer} *** Index: #{index} ***")
      if(reviewer != nil)
        mapping = ReviewMapping.new
        mapping.author_id = author.id
        mapping.reviewer_id = reviewer.id
        mapping.assignment_id = session[:assignment_id]
        mapping.save
      end
      
      index += 1
    end 
  end  
  
  #return an array of authors for this mapping
  #ajbudlon, sept 07, 2007  
  def get_author_ids
    author_ids = Array.new
    if (self.team_id)
      team_users = TeamsUser.find_by_sql("select * from teams_users where team_id = " + self.team_id.to_s)
      for member in team_users
        author_id << member.user_id
      end
    else
      author_ids << self.author_id
    end
    return author_ids
  end
end