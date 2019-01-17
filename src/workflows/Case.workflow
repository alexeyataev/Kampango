<?xml version="1.0" encoding="UTF-8"?>

<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
  
      <alerts>
     
  	  <fullName>Cancel_Membership</fullName>
   
   	  <description>Cancel Membership</description>
   
   	  <protected>false</protected>
   
     	  <recipients>
         
   	  <field>useremail__c</field>
    
          <type>email</type>
      
   </recipients>
     
   <recipients>
        
    	  <recipient>vemula.ashalatha@csscorp.com</recipient>
     
       	  <type>user</type>
   
   </recipients>
        
	  <senderType>DefaultWorkflowUser</senderType>
     
  	 <template>NCT_Templates/Cancel_Membership</template>
   
  </alerts>
  
  <alerts>
       
 	 <fullName>Case_Parent_Course_Transfers</fullName>
       
 	 <description>Case Parent Course Transfers</description>
        
	 <protected>false</protected>
   
   <recipients>
           
 	 <field>ContactId</field>
     
       	 <type>contactLookup</type>
      
   </recipients>
     
   <recipients>
         
   	<field>useremail__c</field>
      
        <type>email</type>
     
   </recipients>
       
 	<senderType>CurrentUser</senderType>
   
        <template>NCT_Templates/Case_Transfer_of_Courses</template>
  
  </alerts>
 
  <alerts>
       
 	<fullName>Case_Status_is_Approved</fullName>
   
        <description>Case Status is Approved</description>
      
  	<protected>false</protected>
       
 <recipients>
         
   	<recipient>ranjithkumar.sareeswaran@csscorp.com</recipient>
        
 	<type>user</type>
       
 </recipients>
       
 <recipients>
           
 	<recipient>veera.pallerla@csscorp.com</recipient>
           
 <type>user</type>
       
 </recipients>
        
	<senderType>CurrentUser</senderType>
       
 	<template>NCT_Templates/Course_booking_status_Confirmed</template>
   
 </alerts>
    
 <alerts>
       
 	<fullName>New_course_created</fullName>
      
  	<description>New case created</description>
      
  	<protected>false</protected>
       
 <recipients>
           
 	<recipient>anjineyulu.valasa@csscorp.com</recipient>
          
 	 <type>user</type>
       
  </recipients>
        
  <recipients>
         
  	 <recipient>ranjithkumar.sareeswaran@csscorp.com</recipient>
          
 	 <type>user</type>
        
  </recipients>
       
 	 <senderType>CurrentUser</senderType>
       
 	<template>NCT_Templates/Case</template>
    
 </alerts>
   
 <alerts>
      
  	<fullName>Parent_Course_Transfer</fullName>
       
 	<description>Parent Course Transfer</description>
        
	<protected>false</protected>
        
	<recipients>
            
	<field>ContactId</field>
    
        <type>contactLookup</type>
       
 </recipients>
       
 <recipients>
          
  	<field>useremail__c</field>
            
	<type>email</type>
   
 </recipients>
      
 	<senderType>CurrentUser</senderType>
    
        <template>NCT_Templates/Parent_Course_Transfer</template>
   
 </alerts>
   
 <alerts>
       
 	<fullName>Request_to_be_a_volunteer</fullName>
     
   	<description>Request to be a volunteer</description>
     
   	<protected>false</protected>
        
<recipients>
            
	<recipient>swathi.kota@csscorp.com</recipient>
      
        <type>user</type>
      
</recipients>
      
  	<senderType>CurrentUser</senderType>
     
   	<template>NCT_Templates/Request_to_be_Volunteer</template>
   
 </alerts>
   
 <alerts>
    
   	 <fullName>Update_Bank_Detail</fullName>
      
 	 <description>Update Bank Detail</description>
  
         <protected>false</protected>
      
<recipients>
     
         <field>useremail__c</field>
       
    	 <type>email</type>
     
   </recipients>
     
   <recipients>
           
 	<recipient>vemula.ashalatha@csscorp.com</recipient>
    
        <type>user</type>
       
 </recipients>
      
  	<senderType>DefaultWorkflowUser</senderType>
  
        <template>NCT_Templates/Update_Bank_Detail</template>
  
 </alerts>
   
 <alerts>
       
 	<fullName>Volunteer_De_Registration</fullName>
      
  	<description>Volunteer De-Registration</description>
    
    	<protected>false</protected>
       
 <recipients>
        
    	<recipient>anjineyulu.valasa@csscorp.com</recipient>
     
        <type>user</type>
       
 </recipients>
       
 <recipients>
            
	<recipient>sukumar.rajashekaran@csscorp.com</recipient>
        
    	<type>user</type>
     
 </recipients>
       
 <senderType>CurrentUser</senderType>
     
   	<template>GW_Volunteers__Volunteers_Email_Templates/Volunteer_de_register</template>
  
  </alerts>
  
  <fieldUpdates>
        
	<fullName>Approved</fullName>
       
 	<field>Status</field>
   
     	<literalValue>Approved</literalValue>
      
 	 <name>Approved</name>
      
 	 <notifyAssignee>false</notifyAssignee>
     
   	<operation>Literal</operation>
        
	<protected>false</protected>
       
 	<reevaluateOnChange>true</reevaluateOnChange>
 
 </fieldUpdates>
   
 <fieldUpdates>
      
  	<fullName>Parent_Course_Transfer</fullName>
      
 	 <field>OwnerId</field>
       
 	<lookupValue>Course_Booking_Queue</lookupValue>
      
  	<lookupValueType>Queue</lookupValueType>
   
        <name>Parent Course Transfer</name>
     
   	<notifyAssignee>true</notifyAssignee>
 
        <operation>LookupValue</operation>
    
   	 <protected>false</protected>
   
 </fieldUpdates>
   
 <fieldUpdates>
 
       <fullName>Parent_Course_Transfer1</fullName>
    
       <field>OwnerId</field>
      
  	<lookupValue>Course_Booking_Queue</lookupValue>
    
    	<lookupValueType>Queue</lookupValueType>
  
       <name>Parent Course Transfer1</name>
   
      <notifyAssignee>true</notifyAssignee>
     
       <operation>LookupValue</operation>
        
	<protected>false</protected>
    
</fieldUpdates>
  
<fieldUpdates>
  
      <fullName>Status_is_Rejected</fullName>
   
      <field>Status</field>
    
     <literalValue>Rejected</literalValue>
   
     <name>Status is Rejected</name>
   
     <notifyAssignee>false</notifyAssignee>
    
     <operation>Literal</operation>
       
     <protected>false</protected>
       
     <reevaluateOnChange>true</reevaluateOnChange>
 
</fieldUpdates>
    
<fieldUpdates>
       
      <fullName>case_owner_assignee_to_enquiries_team</fullName>
  
      <field>OwnerId</field>
      
      <lookupValue>Enquiries_Team</lookupValue>
        
      <lookupValueType>Queue</lookupValueType>
     
       <name>case owner assignee to enquiries team</name>

       <notifyAssignee>true</notifyAssignee>
    
       <operation>LookupValue</operation>
     
      <protected>false</protected>
 
</fieldUpdates>
    
<fieldUpdates>
      
  	<fullName>case_owner_field_update</fullName>
     
   	<field>OwnerId</field>
     
   	<lookupValue>Course_Booking_Queue</lookupValue>
    
    	<lookupValueType>Queue</lookupValueType>
    
    	<name>case owner field update</name>
    
    	<notifyAssignee>true</notifyAssignee>
   
     	<operation>LookupValue</operation>
       
 	<protected>false</protected>
  
</fieldUpdates>
  
<fieldUpdates>
   
        <fullName>case_owner_field_update_Course_Booking_Q</fullName>
  
        <field>OwnerId</field>
      
 	 <lookupValue>Course_Booking_Queue</lookupValue>
    
    	<lookupValueType>Queue</lookupValueType>
    
   	 <name>case owner field update Course Booking Q</name>
     
   	<notifyAssignee>true</notifyAssignee>
      
  	<operation>LookupValue</operation>
     
   	<protected>false</protected>
  
</fieldUpdates>
  
<fieldUpdates>
      
  	<fullName>case_owner_field_update_as_a_BranchQueue</fullName>
   
        <field>OwnerId</field>
       
	 <lookupValue>Branch_Queue</lookupValue>
        
	<lookupValueType>Queue</lookupValueType>
      
	  <name>case owner field update as a BranchQueue</name>
       
	 <notifyAssignee>false</notifyAssignee>
       
	 <operation>LookupValue</operation>
    
         <protected>false</protected>
   
</fieldUpdates>
   
<fieldUpdates>
        
	<fullName>update_case_owner</fullName>
    
        <field>OwnerId</field>
        
        <lookupValue>Enquiries_Team</lookupValue>
   
        <lookupValueType>Queue</lookupValueType>
        
        <name>update case owner</name>
       
        <notifyAssignee>false</notifyAssignee>
       
        <operation>LookupValue</operation>
       
        <protected>false</protected>
    
</fieldUpdates>
   
 <rules>
        
	<fullName>All emails assigned to the case queue enquiries team</fullName>
     
        <active>true</active>
        
	<formula>OwnerId  =  Owner:Queue.Id</formula>
        
	<triggerType>onCreateOrTriggeringUpdate</triggerType>
   
 </rules>
    
 <rules>
       <fullName>Cancel Membership</fullName>
    
	       <actions>
            
		<name>update_case_owner</name>
       
	        <type>FieldUpdate</type>
    
</actions>
        
	       <active>true</active>
   
	      <booleanFilter>1 AND 2 AND 3</booleanFilter>
        
<criteriaItems>
            
		<field>Case.Reason</field>
           
		 <operation>equals</operation>
          
		  <value>Cancel Membership</value>
        
</criteriaItems>
        
<criteriaItems>
           
		 <field>Case.Type</field>
          
	         <operation>equals</operation>
            
		 <value>Request</value>
      
 </criteriaItems>
       
 <criteriaItems>
         
		   <field>Case.RecordTypeId</field>
            
		   <operation>equals</operation>
            
		   <value>Cancel Membership</value>
       
 </criteriaItems>
       	
		<description>Parent need to create a case on cancellation of Membership</description>
       
 		<triggerType>onCreateOnly</triggerType>
    
</rules>
    
<rules>
       
		 <fullName>Volunteer De-Registration</fullName>
   
     <actions>
         
	         <name>Volunteer_De_Registration</name>
           
 		<type>Alert</type>
       
 </actions>
        
		<active>true</active>
        
<criteriaItems>
           
		 <field>Case.Reason</field>
          
	  	 <operation>equals</operation>
        
	         <value>Volunteer De-Registration</value>
      
 </criteriaItems>
      
		  <description>Branch Volunteering Profile going to de-register from volunteer click the case reason  of Volunteer De-Registration Value</description>
       		 <triggerType>onCreateOrTriggeringUpdate</triggerType>
  
 </rules>
    
 <rules>
        
		<fullName>When Case created always mails will send</fullName>
       
 <actions>
          
	        <name>New_course_created</name>
            
		<type>Alert</type>
       
 </actions>
        
 <active>true</active>
     
 <criteriaItems>
           
		<field>Case.CreatedById</field>
            
		<operation>equals</operation>
            
		<value>True</value>
        
</criteriaItems>
       
		 <triggerType>onCreateOnly</triggerType>
   
 </rules>
    
 <rules>
       
		 <fullName>update owner for Enquiries Team</fullName>
       
<actions>
            
		 <name>Update_Bank_Detail</name>
            
		 <type>Alert</type>
        
</actions>
        
<actions>
            
		 <name>case_owner_assignee_to_enquiries_team</name>
            
		 <type>FieldUpdate</type>
       
</actions>
        
<active>true</active>
        
<criteriaItems>
           
		 <field>Case.Reason</field>
            
		 <operation>equals</operation>
            
		 <value>bank details change</value>
        
</criteriaItems>
       
 <criteriaItems>
            
		<field>Case.Type</field>
            
		<operation>equals</operation>
           
		<value>Update</value>
       
</criteriaItems>
        
		<triggerType>onCreateOnly</triggerType>
   
</rules>
    
<rules>
        
		<fullName>update owner for case CourseBooking Queue</fullName>
        
<actions>
            
		<name>Case_Parent_Course_Transfers</name>
            
<type>Alert</type>
        
</actions>
        
<actions>
            
		<name>Parent_Course_Transfer</name>
            
<type>Alert</type>
        
</actions>
        
<actions>
            
		<name>Parent_Course_Transfer1</name>
            
		<type>FieldUpdate</type>
        
</actions>
        
<actions>
            
		<name>case_owner_field_update_Course_Booking_Q</name>
            
		<type>FieldUpdate</type>
        
</actions>
        
<active>true</active>
        
<criteriaItems>
            
		<field>Case.Reason</field>
            
		<operation>equals</operation>
           
		 <value>Course Transfer</value>
        
</criteriaItems>
        
<criteriaItems>
            
		<field>Case.Type</field>
            
		<operation>equals</operation>
            
		<value>Request</value>
        
</criteriaItems>
        
		<triggerType>onCreateOnly</triggerType>
    
</rules>
    
<rules>
        
		<fullName>update owner for case branch queue</fullName>
        
<actions>
            
		<name>Parent_Course_Transfer</name>
            
		<type>Alert</type>
        
</actions>
        
<actions>
            
		<name>case_owner_field_update_as_a_BranchQueue</name>
            
		<type>FieldUpdate</type>
        
</actions>
        
<active>true</active>
        
<criteriaItems>
            
		<field>Case.Reason</field>
            
		<operation>equals</operation>
            
		<value>Course Transfer</value>
        
</criteriaItems>
        
<criteriaItems>
            
		<field>Case.Type</field>
            
		<operation>equals</operation>
            
		<value>Feature Request</value>
        
</criteriaItems>
        
		<triggerType>onAllChanges</triggerType>
    
</rules>
</Workflow>
