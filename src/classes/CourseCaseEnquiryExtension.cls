public with sharing class CourseCaseEnquiryExtension {
    Course__c cou;
    public string firstname {get; set;}
    public string lastname {get; set;}
    public Boolean female {get; set;}
    public Boolean male {get; set;}
    public string radioHidden {get; set;}
    public string email {get; set;}
    public string mobile {get; set;}
    public Date expirydate {get; set;}
    public user us{get; set;} 
    public Case cs{get; set;}    
    
    public CourseCaseEnquiryExtension(ApexPages.StandardController controller){
        list<User> us1 = [SELECT Id, LastName, FirstName, Email,Phone FROM User where username = :UserInfo.getUsername()];
        cou = (Course__c)controller.getRecord();
        System.debug('cou==>'+this.cou);
        System.debug('cou==>'+cou);
        cs = new Case();
        String fname =us1[0].FirstName;
        String lname =us1[0].LastName;
        String mail = us1[0].Email;
        system.debug('@@@@@@'+mail);
        String phone = us1[0].Phone;
        Id uid = us1[0].Id;
        setfirstname(fname);
        setlastname(lname);
        setemail(mail);
        setmobile(Phone);
        
        /*this.us =(User)controller.getRecord();
us.firstname =us1[0].FirstName;
us.lastname =us1[0].LastName;
us.Email = us1[0].Email;*/
    }
    public string setfirstname(String fname){
        //list<User> us1 = [SELECT Id, LastName, FirstName, Email FROM User where username = :UserInfo.getUsername()];
        // return firstname=us1[0].FirstName;
        return firstname = fname;
    }
    public string setlastname(String lname){
        return lastname = lname;
    }
    public string setemail(String mail){
        return email = mail;
    }
    public string setmobile(String Phone){
        return mobile = Phone;
    }
    public class cNodes
    {
        public List<Session__c> parent {get; set;}
        Public Course__c gparent {get;set;}
        public cNodes(Course__c  gp, List<Session__c> p)
        {       
            parent = p;       
            gparent = gp;   
        }  
    }
    /* end of Wrapper class */
    Public List<cNodes> hierarchy;
    Public List<cNodes> getmainnodes()
    {
        //Id id1 = UserInfo.getUserId();
        Id id1 = cou.id;
        System.debug('id1'+id1);
        Date date1 = Date.Today();
        hierarchy = new List<cNodes>();
        List<Course__c> tempparent = [SELECT Id, Name,Session_Count__c, Course_Type__c, Course_Name__c, Venue__c, Status__c,Venue__r.Name, Start_Date__c, End_Date__c, Venue__r.MailingStreet__c, Venue__r.MailingState__c, Venue__r.MailingCity__c, Venue__r.MailingCountry__c, Venue__r.MailingPostalCode__c FROM Course__c where id = :id1];//CreatedById = :id1 and
        System.debug('Test========>'+tempparent);
        for (Integer i =0; i< tempparent.size() ; i++)
        {
            list<Session__c> tempchildren = [SELECT id,Start__c, End__c FROM Session__c where Course__c= :tempparent[i].Id];
            System.debug('tempchildren========');
            
            //List<Contact> tempchildren = [Select Id,FirstName,LastName,(Select Id,CaseNumber,Subject from Cases) from Contact where AccountId = :tempparent[i].Id];
            hierarchy.add(new cNodes(tempparent[i],tempchildren));
            
        }
        return hierarchy;  
        
    }
    public pageReference save(){
        //Fetching the assignment rules on case
        try{
            //AssignmentRule AR = new AssignmentRule();
            
            // AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
            //AR = AssignmentRuleQuery.getAssignmentRule();
            
            //Creating the DMLOptions for "Assign using active assignment rules" checkbox
            
            Database.DMLOptions dmlOpts = new Database.DMLOptions();
            
            if(null!=AssignmentRuleQuery.getAssignmentRule()){
            	dmlOpts.assignmentRuleHeader.assignmentRuleId= AssignmentRuleQuery.getAssignmentRule().id;
            }
            dmlOpts.EmailHeader.TriggerUserEmail = true;
            // Case newCase = new Case(Status = 'New') ;
            list<User> us = [SELECT Contact.id FROM User where username = :UserInfo.getUsername()];
            //Setting the DMLOption on Case instance
            
            cs.setOptions(dmlOpts);
            //cs = new Case();
            cs.Status= 'New';
            cs.Subject =cou.Course_Type__c;
            cs.Reason = 'Enquiry';
            cs.dummy_CourseId__c= cou.id;
            cs.dummy_Email__c = email;
            //cs.dummy_name__c = lastname;//
            cs.dummy_name__c = firstname;
            cs.ContactId = us[0].Contact.id;
            //cs.ContactId ='0030E00000Owx30';
            if(radioHidden == 'female'){
                cs.Description ='Course ID: '+cou.id+'\n'+'Course Number: '+cou.Name+'\n'+'first Name:'+firstname+'\n'+'LastName: '+lastname+'\n'+'Female: FEMALE'+'\n'+'Email: '+email+'\n'+'Mobile: '+mobile+'\n'+'Expiry Date :'+expirydate+'\n';
                insert cs;
            }
            else{
                cs.Description ='Course ID: '+cou.id+'\n'+'Course Number: '+cou.Name+'\n'+'First Name: '+firstname+'\n'+'LastName: '+lastname+'\n'+'Male: MALE'+'\n'+'Email: '+email+'\n'+'Mobile: '+mobile+'\n'+'Expiry Date :'+expirydate+'\n';
                insert cs;
                
            }
            id id1 = cou.id;
            //old code : list<course__c> css =[Select Course_Type__c, Course_Name__c, Start_Date__c, End_Date__c from Course__c where id = :id1 limit 1];
            // new code : 
            
            list<course__c> css =[Select Course_Type__c, Course_Name__c, course_start_date__c, End_Date__c from Course__c where id = :id1 limit 1]; //
            //list<course__c> css =[Select Course_Type__c, Course_Name__c, course_start_date__c, End_Date__c from Course__c limit 1];
            system.debug('courses are.........'+css);
            //old code:Datetime startdt = css[0].Start_Date__c;
            // new code : 
            // if(css.size()>0){
            string coursestartdate = css[0].course_start_date__c;
            Datetime enddt = css[0].End_Date__c;
            String address = email;
            String subject = 'Thank You For Contacting US';
            String body ='Test';
            //old code : String coursetype = cou.Course_Type__c; 
            // new code
            String coursename = cou.Course_Name__c;
            
            //old code : String startdate = string.valueOfGmt(startdt);
            //String coursestartdate = string.valueOfGmt(startdt);
            
            String enddate = string.valueOfGmt(enddt);
            //id id1 = cs.id;
            //sendMail(address,subject,body);        		
            //old code :sendSingleMail(address, firstname, coursetype, startdate, enddate); 
            
            //new code 
            sendSingleMail(address, firstname, coursename,coursestartdate, enddate); 
            //}
            PageReference pref= new PageReference('/apex/ThankyouPage'); 
            pref.setRedirect(true);
            return pref;
        } catch (Exception ex){
            system.debug('Exception at CourseCaseEnquiryExtension.save : '+ex.getStackTraceString());
            return null;
        }
        
    }
    
    /* public static void sendMail(String address, String subject, String body) {
// Create an email message object
Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
String[] toAddresses = new String[] {address};
mail.setToAddresses(toAddresses);
mail.setSubject(subject);
mail.setPlainTextBody(body);
// Pass this email message to the built-in sendEmail method 
// of the Messaging class
Messaging.SendEmailResult[] results = Messaging.sendEmail(
new Messaging.SingleEmailMessage[] { mail });

// Call a helper method to inspect the returned results
inspectResults(results);
}

// Helper method
private static Boolean inspectResults(Messaging.SendEmailResult[] results) {
Boolean sendResult = true;

// sendEmail returns an array of result objects.
// Iterate through the list to inspect results. 
// In this class, the methods send only one email, 
// so we should have only one result.
for (Messaging.SendEmailResult res : results) {
if (res.isSuccess()) {
System.debug('Email sent successfully');
}
else {
sendResult = false;
System.debug('The following errors occurred: ' + res.getErrors());                 
}
}

return sendResult;
}*/
    //old code: public static void sendSingleMail(String address, String  firstname, String coursetype, String startdate, String enddate){
    
    // new code : 
    public static void sendSingleMail(String address, String  firstname, String coursename, String coursestartdate, String enddate){
        
        String[] toAddresses = new String[] {address};
            // grab the email template
            EmailTemplate emailTemplate = [select Id, Subject, HtmlValue, Body from EmailTemplate where name ='Booking Enquire Case Confirmation'];
        // grab the contact fields we need. This assumes we are emailing a contact.
        // Contact c = [Select Id, FirstName FROM Contact WHERE Id=: contactId];
        //list<string> em = new list<string>;
        //em.add(address);
        // process the merge fields
        String subject = emailTemplate.Subject;
        //subject = subject.replace('{!Contact.FirstName}', c.FirstName);
        
        String htmlBody = emailTemplate.HtmlValue;
        //htmlBody = htmlBody.replace('{!Contact.FirstName}', c.FirstName);
        htmlBody = htmlBody.replace('{!name}', firstname);
        //old code : htmlBody = htmlBody.replace('{!coursetype}', coursetype);
        // new code : 
        htmlBody = htmlBody.replace('{!coursename}', coursename);
        htmlBody = htmlBody.replace('{!enddate}', enddate);
        htmlBody = htmlBody.replace('{!coursestartdate}', coursestartdate);
        
        String plainBody = emailTemplate.Body;
        //plainBody = plainBody.replace('{!Contact.FirstName}', c.FirstName);
        //plainBody = plainBody.replace('{!name}', lastname);
        
        //build the email message
        Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();
        //email.setToAddresses(address);
        //email.setCcAddresses(address)
        //email.setInReplyTo(address);
        //email.setReplyTo(address);
        email.setToAddresses(toAddresses);
        //email.ccaddresses(em[0]);
        // email.setSenderDisplayName(address); //It displays SenderDisplayName//
        email.setTargetObjectId(UserInfo.getUserId());
        //email.setTargetObjectId(id1);
        email.setSaveAsActivity(false);
        
        
        email.setSubject(subject);
        email.setHtmlBody(htmlBody);
        email.setPlainTextBody(plainBody);
        system.debug('@email   '+email);
        Messaging.sendEmail(new Messaging.SingleEmailmessage[] {email});
    }
    
}