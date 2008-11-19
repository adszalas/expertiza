class Mailer < ActionMailer::Base

  #Creates message content
  #defn - A hash object containing the following items:
  #    subject - message's subject line
  #    recipients - a string or array containing the recipient e-mail 
  #                 address(es)
  #    bcc <optional> - a string or array containing the bcc e-mail
  #                 address(es)
  #    body - a hash containing the following:
  #           partial_name - the name of the partial located in 
  #               /app/views/mailer/partials to use when rendering
  #               this message. Do not include the message type (_html or _plain)
  #           <optional> Other content can be included as needed by the partial
  def message(defn)
     puts "*** in mailer method ***"
     @subject = defn[:subject]
     @recipients = defn[:recipients]
     if defn[:bcc] != nil
       @bcc = defn[:bcc]
     end
     if defn[:from] != nil
       @from = defn[:from]
     else
       @from = "expertiza@ncsu.edu"
     end
     @body = defn[:body]
     @sent_on = Time.now 
  end
end