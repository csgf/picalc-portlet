<%
/**
 * Copyright (c) 2000-2011 Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */
%>

<%@ page import="com.liferay.portal.kernel.util.WebKeys" %>
<%@ page import="com.liferay.portal.util.PortalUtil" %>
<%@ page import="com.liferay.portal.model.Company" %>
<%@ page import="javax.portlet.*" %>
<%@ taglib uri="http://java.sun.com/portlet_2_0" prefix="portlet" %>
<%@ taglib uri="http://liferay.com/tld/theme" prefix="liferay-theme" %>
<%@ taglib uri="http://liferay.com/tld/ui" prefix="liferay-ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<portlet:defineObjects />
<liferay-theme:defineObjects />
<%//
  // mi-hostname Submission Form
  //
  // The form has 1 input textareas or an upload file button
  // Text area and file upload works in a mutual exclusive fashion
  // The message will be the input for the test job that executes 
  // on the distributed infrastructure
  // 
  // The other inputs are related to:
  //   Job description  - A human readable job description
  //   Start/Stop Flags - If selected a mail will be sent upon job' start/stop 
  //   Email address    - The email address to be used for notification                 
  //
  // The ohter three buttons of the form are used for:
  //    o Demo:          Used to fill with demo values the text areas
  //    o SUBMIT:        Used to execute the job on the eInfrastructure
  //    o Reset values:  Used to reset input fields
  //  
%>

<%
// Below the descriptive area of the mi-hostname web form 
%>
<table>
<tr>
<td valign="top">
<img align="left" style="padding:10px 10px;" src="<%=renderRequest.getContextPath()%>/images/AppLogo.png" />
</td>
<td>
The parallel "Hello World !" application is MPI-enabled.
<p>
<!--
    <h4>Usage:</h4>
    <ul>
        <li><b>Submit</b> button an hostanem job will be executed<br></li>
        <li><b>About</b> button information about the application will be shown</li>
        <li><b>Reset</b> button to set default submission values</li>
    </ul> 
-->
</p>
</td>
</tr>
<%
// Below the application submission web form 
//
// The <form> tag contains a portlet parameter value called 'PortletStatus' the value of this item
// will be read by the processAction portlet method which then assigns a proper view mode before
// the call to the doView method.
// PortletStatus values can range accordingly to values defined into Enum type: Actions
// The processAction method will assign a view mode accordingly to the values defined into
// the Enum type: Views. This value will be assigned calling the function: setRenderParameter
//
%>
    <!-- There's no need to use the multipart/form-data 
    <form enctype="multipart/form-data" action="<portlet:actionURL portletMode="view"><portlet:param name="PortletStatus" value="ACTION_SUBMIT"/></portlet:actionURL>" method="post">
    -->
    <form action="<portlet:actionURL portletMode="view"><portlet:param name="PortletStatus" value="ACTION_SUBMIT"/></portlet:actionURL>" method="post">
<tr>
    <td></td>
    <td align="left">
    <dl>	
        <!-- This block contains the number of CPUs (fixed to 4 for this demo)
	<dd>
		<p>Insert below the <b>number of CPUs</b></p>
		<textarea id="cpuNumber" rows="1" cols="10%" name="CpuNumber">4</textarea>
	</dd>    
        -->
        <input type="hidden" id="cpuNumber" name="CpuNumber" value="4">
	<!-- This block contains the experiment name -->
	<dd>
		<p>Insert below your <b>job identifier</b></p>
		<textarea id="jobIdentifierId" rows="1" cols="60%" name="JobIdentifier">Hello World Parallel job ...</textarea>
	</dd>        
        <!-- This block contains notification flags
        <dd>            
            <p><b>Notification flags</b></br>
               Please check following flags in case you wish to be notified about the application execution.            
            <ul>
                <li><input type="checkbox" id="notifyStart" name="notifyStart" /> I would like to be notified for application execution START        
                <li><input type="checkbox" id="notifyStop"  name="notifyStop"  /> I would like to be notified when the application has COMPLETEd its execution        
                <li><textarea id="notifyEmail" rows="1" cols="40%" name="notifyEmail"><%= user.getEmailAddress() %></textarea>
            </ul>
	</dd>
        -->
    </td>
</tr>
<tr>
    <td></td>
    <td align="center">       
	<!-- This block contains form buttons: Demo, SUBMIT and Reset values -->
  	<dd>  		
  		<input type="button" value="Submit" onClick="preSubmit()">
                <!--
		<input type="reset" value="Reset" onClick="resetForm()">
		</form>
                <form action="<portlet:actionURL portletMode="HELP"> /></portlet:actionURL>" method="post">
                <input type="submit" value="About">
                -->
                </form>
  	</dd>          
    </dl>
    </td>
</tr>
</table>
</form>         
                
<%
// Below the javascript functions used by the web form 
%>
<script type="text/javascript">
//
// preSubmit
//
function preSubmit() {  
    var jobIdentifier=document.getElementById('jobIdentifierId');
    var cpuNumber    =document.getElementById('cpuNumber');
    var state_jobIdentifier=false;
    var state_cpuNumber    =false;    
    var wrongFields="";
    var missingFields="";     
    
    // check job identifier
    if(jobIdentifier.value=="") state_jobIdentifier=true;
    // check cpu number and its value validity
    if(cpuNumber.value=="") 
       state_cpuNumber=true;
    else {
      var cpuNum = parseInt(""+cpuNumber.value); 
      cpuNumber.value = ""+cpuNum;      
      if(   cpuNum <= 0 
         || isNaN(cpuNum)
         || cpuNum > 10 ) {        
        wrongFields+="  CPU Number value must be in the range: [1,10]"
      }
    }
    
    if(state_cpuNumber    ) missingFields+="  CPU Number\n";
    if(state_jobIdentifier) missingFields+="  Job identifier\n";
    
    if(   missingFields == ""
       && wrongFields   == "") {
      document.forms[0].submit();
    }           
    else {
      var message="";
      if(missingFields != "")
        message += "Missing fields:\n" + missingFields;
      if(wrongFields != "")
        message += "Wrong fields:\n" + wrongFields;   
      // Notify the problem
      alert("You cannot send an inconsisten job submission!\n\n"+message);           
    }           
}   


//
//  resetForm
//  
// This function is responsible to enable all textareas
// when the user press the 'reset' form button
function resetForm() { 
        var jobIdentifier = document.getElementById('jobIdentifierId');
        var cpuNumber     = document.getElementById('cpuNumber'      );
        //var notifyStart   = document.getElementById('notifyStart'    );
        //var notifyStop    = document.getElementById('notifyStop'     );
        //var notifyEmail   = document.getElementById('notifyEmail'    );

        // Assign a default CPU Number (4 as best value)
        cpuNumber.value   = "4";
        // Reset checkboxes and email address
        //notifyStart.checked = "false";
        //notifyStop.checked  = "false";
        //notifyEmail.value   = "<%= user.getEmailAddress() %>";

        // Reset the job identifier
        jobIdentifier.value = "Hello World Parallel job ...";
}
</script>
