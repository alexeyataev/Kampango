public class UserHomeController {
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
        for (Integer i =0; i< tempparent.size() ; i++)
        {
            list<Session__c> tempchildren = [SELECT id,Start__c, End__c FROM Session__c where Course__c= :tempparent[i].Id];
         
            //List<Contact> tempchildren = [Select Id,FirstName,LastName,(Select Id,CaseNumber,Subject from Cases) from Contact where AccountId = :tempparent[i].Id];
            hierarchy.add(new cNodes(tempparent[i],tempchildren));
             
        }
        return hierarchy;  

    }
    public PageReference MemberInfo(){
        user =[Select ContactId  from user where id = :userId ];
        
        recDon =[SELECT Id, npe03__Contact__c FROM npe03__Recurring_Donation__c where npe03__Contact__c = :user.ContactId limit 1];
        
        if(recDon.size()>0 ){
            PageReference pageRef = new PageReference('/Membership_Parent_Page');
            //pageRef.getRedirect(true);
            return pageRef;
            
        }
        else{
            
            PageReference pageRef = new PageReference(System.Label.PAYMENT_SITE_URL+'?id='+user.ContactId);
           	//PageReference pageRef = new PageReference('https://preuat-mynct.cs102.force.com/nctMembershipPaymentPage?id='+user.ContactId);
            //pageRef.getRedirect(true);
            return pageRef;
        }
       
    }
    /*public Boolean showResult{get;set;}
  public ApexPages.StandardSetController setCon{get;set;}
    //public ApexPages.StandardSetController setCon1{get;set;}
    public void listCourse(){
          //String id2;
          Id id1 = UserInfo.getUserId();
            Date date1 = Date.Today();
            String query='SELECT Id, Name, Course_Type__c, Course_Name__c, Venue__c, Status__c,Venue__r.Name, Start_Date__c, End_Date__c, Venue__r.MailingStreet__c, Venue__r.MailingState__c, Venue__r.MailingCity__c, Venue__r.MailingCountry__c, Venue__r.MailingPostalCode__c FROM Course__c where CreatedById = :id1 and (Start_Date__c > :date1 OR End_Date__c> :date1)';
          //String query='SELECT Course__r.Id, Course__r.Name, Course__r.Course_Type__c, Course__r.Course_Name__c, Course__r.Venue__c, Course__r.Status__c,Course__r.Venue__r.Name, Course__r.Start_Date__c, Course__r.End_Date__c, Course__r.Venue__r.MailingStreet__c, Course__r.Venue__r.MailingState__c, Course__r.Venue__r.MailingCity__c, Course__r.Venue__r.MailingCountry__c, Course__r.Venue__r.MailingPostalCode__c,Start__c,End__c FROM Session__c where Course__r.CreatedById = :id1 and (Course__r.Start_Date__c > :date1 OR Course__r.End_Date__c> :date1)';
      
          
               //return querylocator to an instance of StandardSetController
                setCon = new ApexPages.StandardSetController(Database.getQueryLocator(query));            
                if(setCon.getResultSize() >0)
                {
                    showResult = true;
                }else{
                    showResult = false;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'No Records Found.'));
                }   
                //listSession();
    }
    /*public void listSession(){
          //Id id2 = UserInfo.getUserId();
            Date date2 = Date.Today();
        
          String query1='SELECT Start__c,End__c FROM Session__c where Course__r.CreatedById = :id1 and (Course__r.Start_Date__c > :date2 OR Course__r.End_Date__c> :date2)';
      
          
               //return querylocator to an instance of StandardSetController
                setCon1 = new ApexPages.StandardSetController(Database.getQueryLocator(query1));            
                if(setCon1.getResultSize() >0)
                {
                    showResult = true;
                }else{
                    showResult = false;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'No Records Found.'));
                }        
    }
    public list<Session__c> getSessions(){
        if(setCon1.getResultSize() >0)
        {
          
          return (List<Session__c>)setCon1.getRecords();
        }else
        {
          return null;
        }
        //return null;
    }*/
    /*public List<Course__c> getCourses() 
    {
        if(setCon.getResultSize() >0)
        {
          
          return (List<Course__c>)setCon.getRecords();
        }else
        {
          return null;
        }
        //return null;
    }*/
}