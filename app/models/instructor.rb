
class Instructor < User
  
  RUBRIC = [['My rubrics','list_mine'],
            ['All public rubrics','list_all']]
  
  ASSIGNMENT = [['My assignments','list_mine'],
                ['All public assignments','list_all']]

  def list_all(object_type, user_id)
    object_type.find(:all, 
                     :conditions => ["instructor_id = ? OR private = 0", user_id])
  end
  
  def list_mine(object_type, user_id)
    object_type.find(:all, :conditions => ["instructor_id = ?", user_id])
  end
  
  def get(object_type, id, user_id)
    object_type.find(:first, 
                     :conditions => ["id = ? AND (instructor_id = ? OR private = 0)", 
                                     id, user_id])
  end
end