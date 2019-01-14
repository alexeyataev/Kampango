public with sharing class NCTHelpTicket {
    public List<case> recordList{set;get;}
    public boolean isCaseExist{set;get;}
    public string testString{set;get;}
    public Id contactId;
    public user usr;
    public NCTHelpTicket(){
        isCaseExist = false;// setting defaults to false
        contactId = UserInfo.getUserId();
        usr = [select Id, ContactId from user where Id =: contactId];
        if(usr != null)
        {
            recordList = [SELECT Id, CaseNumber,useremail__c,createddate FROM Case where ContactId=:usr.ContactId];
        }        
        system.debug('recordList======>'+recordList);
        isCaseExist = null != recordList && !recordList.isEmpty();
        
    }
}