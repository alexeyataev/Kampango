public with sharing class MembershipStatusController {
	
    public String contId {get; set;}
    public npe03__Recurring_Donation__c recDonList {get; set;}
    
    public MembershipStatusController(){
        
        contId = ApexPages.currentPage().getParameters().get('Id');
	    System.debug('Contact Id: '+contId);  
        if(contId != '' || contId != null)
        {
            recDonList = [SELECT 
                              Id, 
                              Name,
                              npe03__Contact__c,
                      		  npe03__Contact__r.Email,
                       	      Membership_Number__c 
                      FROM 
                              npe03__Recurring_Donation__c
                      WHERE
                              npe03__Contact__c = :contId limit 1];
        	System.debug('recDonList: '+recDonList);
        }        
    }
}