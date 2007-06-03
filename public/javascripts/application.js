// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function checkForm()
{
	return checkDeadlines();
}
function checkDeadlines()
{
	var numReviews = document.getElementById('assignment_helper_no_of_reviews');
	var limit=numReviews.value;
	var dates = new Array()
	dates[0]= document.getElementById('submit_deadline_due_at').value
	dates[1]= document.getElementById('review_deadline_due_at').value
	var datesCounter=2;
	for (i=1;i<limit;i++)
	{
		var j = i+1;
		var resubmitFieldName = "additional_submit_deadline_"+j+"_due_at"
		var rereviewFieldName = "additional_review_deadline_"+j+"_due_at"
		dates[datesCounter]= document.getElementById(resubmitFieldName).value
		datesCounter++
		dates[datesCounter]= document.getElementById(rereviewFieldName).value
		datesCounter++
	}
	dates[datesCounter] = document.getElementById('reviewofreview_deadline_due_at').value
	 
	for (i=0;i<datesCounter;i++)
	{
		var check = 0
		var iplsvn = i+1 
		
		if(getYear(dates[i])<= getYear(dates[iplsvn]))
		{
			if(getMonth(dates[i])<= getMonth(dates[iplsvn]))
			{
				if(getDay(dates[i])<= getDay(dates[iplsvn]))
				{
					if(i == datesCounter-1)
					{
						return true
					}
				}
				else
				{
					alert ("Deadlines incorrect- Make sure each date in a deadline is greater than or equal to the date its preceeding deadline.")
					return false
				}
			}
			else
			{
				alert ("Month greater for "+i)
				return false
			}	
		}
		else
		{
			alert ("Year greater for "+i)
			return false
		}
	}
	
}

function getDay(date)
{
	var day = date.substring(8,10)
	return day
}

function getMonth(date)
{
	var month = date.substring(5,7)
	return month
}

function getYear(date)
{
	var year = date.substring(0,4)
	return year
}

function addElement() {
  
  var ni = document.getElementById('extra_deadlines');
  var numReviews = document.getElementById('assignment_helper_no_of_reviews');
  if (numReviews.value>10 ||numReviews.value<=0 ||!numReviews.value.toString().match(/^[-]?\d*\.?\d*$/))
  {
  	alert("Please enter a value between 1 to 10")
	numReviews.value=2
	addElement()
	return
  }
  var authHTML = "";
   //alert (numi.value);
  var limit=numReviews.value;
  var i;
  ni.innerHTML = "";
  var submission_var='';
  var rereview_var='';
  if(limit==2)
  {
	submission_var="Final submission deadline";
	rereview_var="Final review deadline";
  }
  //alert(limit)
  for(i=1;i<limit;i++)
  {
  	//alert (ni.innerHTML);
  	var j = i+1;

	if(limit>2)
	{
		submission_var= 'Re-submission-'+j+' deadline'
		rereview_var = 'Re-review-'+j+' deadline'
	}
  	ni.innerHTML = ni.innerHTML + 
  	                    '<TR><TD ALIGN=LEFT WIDTH=20%>'+submission_var+'</TD>'+
  	                    '<TD ALIGN=CENTER WIDTH=5%><input type="text" id="additional_submit_deadline_'+j+'_due_at" name ="additional_submit_deadline['+j+'][due_at]"  onClick=\"NewCal(\'additional_submit_deadline_'+j+'_due_at\',\'YYYYMMDD\',true,24); return false;"/></TD>'+
  	                    
						'<TD ALIGN=CENTER WIDTH=10%><select id="additional_submit_deadline_'+j+'_submission_allowed_id" name ="additional_submit_deadline['+j+'][submission_allowed_id]">'+
						'<option value=2 SELECTED>Late</option<option value=1>No</option>'+
                        '<option value=3>OK</option>'+
						'</select></TD>'+
						
						'<TD ALIGN=CENTER WIDTH=10%><select id="additional_submit_deadline_'+j+'_review_allowed_id" name ="additional_submit_deadline['+j+'][review_allowed_id]">'+
						'<option value=2 SELECTED>Late</option><option value=1>No</option><option value=3>OK</option>'+
						'</select></TD>'+
						
						'<TD ALIGN=CENTER WIDTH=10%><select id="additional_submit_deadline_'+j+'_resubmission_allowed_id" name ="additional_submit_deadline['+j+'][resubmission_allowed_id]"><option value=2>Late</option>'+
						'<option value=1>No</option><option value=3 SELECTED>OK</option>'+
						'</select></TD>'+
						
						'<TD ALIGN=CENTER WIDTH=10%><select id="additional_submit_deadline_'+j+'_rereview_allowed_id" name ="additional_submit_deadline['+j+'][rereview_allowed_id]">'+
						'<option value=2>Late</option><option value=1 SELECTED >No</option>'+
						'<option value=3>OK</option>'+
						'</select></TD>'+
						
						'<TD ALIGN=CENTER WIDTH=10%><select id="additional_submit_deadline_'+j+'_review_of_review_allowed_id" name ="additional_submit_deadline['+j+'][review_of_review_allowed_id]">'+
						'<option value=2>Late</option><option value=1 SELECTED>No</option><option value=3>OK</option>'+
						'</select></TD>'+
						'</TR>'+
						
						'<TR><TD ALIGN=LEFT WIDTH=20%>'+rereview_var+'</TD>'+
						
						'<TD ALIGN=CENTER WIDTH=5%><input type="text" id="additional_review_deadline_'+j+'_due_at" name ="additional_review_deadline['+j+'][due_at]" onClick="NewCal(\'additional_review_deadline_'+j+'_due_at\',\'YYYYMMDD\',true,24); return false;"/></TD>'+
						
						'<TD ALIGN=CENTER WIDTH=10%><select id="additional_review_deadline_'+j+'_submission_allowed_id" name ="additional_review_deadline['+j+'][submission_allowed_id]">'+
						'<option value=2 SELECTED >Late</option<option value=1>No</option>'+
                        '<option value=3>OK</option>'+
						'</select></TD>'+
						
						'<TD ALIGN=CENTER WIDTH=10%><select id="additional_review_deadline_'+j+'_review_allowed_id" name ="additional_review_deadline['+j+'][review_allowed_id]">'+
						'<option value=2 SELECTED	>Late</option><option value=1>No</option><option value=3 	>OK</option>'+
						'</select></TD>'+
						
						'<TD ALIGN=CENTER WIDTH=10%><select id="additional_review_deadline_'+j+'_resubmission_allowed_id" name ="additional_review_deadline['+j+'][resubmission_allowed_id]"><option value=2 SELECTED>Late</option>'+
						'<option value=1>No</option><option value=3>OK</option>'+
						'</select></TD>'+
						
						'<TD ALIGN=CENTER WIDTH=10%><select id="additional_review_deadline_'+j+'_rereview_allowed_id" name ="additional_review_deadline['+j+'][rereview_allowed_id]">'+
						'<option value=2 >Late</option><option value=1 >No</option>'+
						'<option value=3 SELECTED>OK</option>'+
						'</select></TD>'+
						
						'<TD ALIGN=CENTER WIDTH=10%>'+
						'<select id="additional_review_deadline_'+j+'_review_of_review_allowed_id" name ="additional_review_deadline['+j+'][review_of_review_allowed_id]">'+
						'<option value=2>Late</option><option value=1 SELECTED>No</option><option value=3>OK</option>'+
						'</select></TD>'+
						'</TR>';
  }
}