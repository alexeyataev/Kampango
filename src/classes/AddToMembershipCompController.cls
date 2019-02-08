global without sharing class AddToMembershipCompController {
    //@auraenabled public static String showErrorMsg{set;get;}
    @auraenabled public static list<npe03__Recurring_Donation__c> recurrDonList{set;get;}
	@auraenabled    
    public static void addToMembershipValidation(Id contId){
        //showErrorMsg ='You cant new membership and your existing membership numbers are ';
        system.debug('addToMembershipValidation : contId : '+contId);
       recurrDonList = [select Id, Membership_Number__c,First_Contact__r.Email from npe03__Recurring_Donation__c where First_Contact__c =: contId];
        if(!recurrDonList.isEmpty()) {
            for(npe03__Recurring_Donation__c row : recurrDonList){
                system.debug('row.Membership_Number__c : '+row.Membership_Number__c);
                //showErrorMsg = showErrorMsg +row.Membership_Number__c+' ';
            }
            //system.debug('showErrorMessage ------ '+showErrorMsg);
            throw new AuraHandledException('You Cant Add Membership, hence already membership exists for this contact');
        }
        }
    }