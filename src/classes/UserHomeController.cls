public with sharing class UserHomeController {
    public Integer noOfRecords{get; set;}
    public Id userId {get; set;}
    public User user {get; set;}
    public list<npe03__Recurring_Donation__c> recDon {get; set;}
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
        userId = UserInfo.getUserId();
        Date date1 = Date.Today();
        hierarchy = new List<cNodes>();
        List<Course__c> tempparent = [SELECT Id, Name,Session_Count__c, Course_Type__c, Course_Name__c, Venue__c, Status__c,Venue__r.Name, Start_Date__c, End_Date__c, Venue__r.MailingStreet__c, Venue__r.MailingState__c, Venue__r.MailingCity__c, Venue__r.MailingCountry__c, Venue__r.MailingPostalCode__c FROM Course__c where (Session_Count__c >0) and (Start_Date__c > :date1 OR End_Date__c> :date1) limit 5];//CreatedById = :id1 and
        System.debug('Test'+tempparent);
		Map<ID,Session__c> tempchildren = new Map<ID,Session__c>([SELECT id,Start__c, End__c FROM Session__c where Course__c= :tempparent[i].Id]);
        for (Integer i =0; i< tempparent.size() ; i++)
        {
            
            tempchildren.values();
            hierarchy.add(new cNodes(tempparent[i],tempchildren));
             
        }
        return hierarchy;  

    }
    public PageReference memberInfo(){
        user =[Select ContactId  from user where id = :userId ];
        
        recDon =[SELECT Id, npe03__Contact__c FROM npe03__Recurring_Donation__c where npe03__Contact__c = :user.ContactId limit 1];
        
        if(recDon.size()>0 ){
            PageReference pageRef = new PageReference('/Membership_Parent_Page');
            
            return pageRef;
            
        }
        else{
           	PageReference pageRef = new PageReference('https://preuat-mynct.cs102.force.com/nctMembershipPaymentPage?id='+user.ContactId);
            return pageRef;
        }
       
    }
   
}