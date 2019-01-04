public class Coursebookingcontroller {
    public list<Course__c> upcomingcourse {get;set;}
    public Id selectedcourseId{get;set;}   
    
    public Coursebookingcontroller()
    { 
        if(userInfo.getUserId()!= null)
        {
            User usr = [select Id, ContactId from User where Id =: userInfo.getUserId()];
            selectedcourseId = usr.ContactId;
            //selectedcourseId = '0031j000002MxpVAAS';
        }
        if(selectedcourseId != null){
            Contact con = [SELECT Id, Expected_Due_Date__c FROM Contact where id= :selectedcourseId];
            DateTime duedate = con.Expected_Due_Date__c;
            System.debug('dueDate: '+duedate);
            upcomingcourse = [select Id, Course_Type__c,Venue__c,Venue_Address__c,Venue__r.MailingPostalCode__c,Practitioner__r.Name,Start_Date__c,End_Date__c from Course__c where (Start_Date__c >=:duedate AND Start_Date__c <=:duedate) OR (End_Date__c >=:duedate AND End_Date__c <=:duedate) OR (Start_Date__c <=:duedate AND End_Date__c >=:duedate) limit 5];
            System.debug('Test: '+upcomingcourse);
            if(upcomingcourse.isEmpty()){
                upcomingcourse = new list<Course__c>();
            }
        }
        else{
            System.debug('Contact id is null');
        }
        
    }

}