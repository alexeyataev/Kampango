public with sharing class AddToMembershipCompController {
    public static list<npe03__Recurring_Donation__c> recurrDonList{set;get;}
	@auraenabled    
    public static void addToMembershipValidation(Id contId){  
        system.debug('addToMembershipValidation : contId : '+contId);
        if (!Schema.sObjectType.npe03__Recurring_Donation__c.fields.Membership_Number__c.isAccessible()){
         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Insufficient Access'));
        }
       recurrDonList = [select Id, Membership_Number__c,First_Contact__r.Email from npe03__Recurring_Donation__c where First_Contact__c =: contId];
        if(!recurrDonList.isEmpty()) {
            for(npe03__Recurring_Donation__c row : recurrDonList){
                system.debug('row.Membership_Number__c : '+row.Membership_Number__c);
            }
            AuraHandledException e = new AuraHandledException('You Cant Add Membership, hence already membership exists for this contact');
            e.setMessage('You Cant Add Membership, hence already membership exists for this contact');
            system.debug(e);
            throw e;
        }
      }
    }