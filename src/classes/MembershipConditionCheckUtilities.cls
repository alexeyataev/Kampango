public without sharing class MembershipConditionCheckUtilities {
        
    public static Boolean receiveInputPermissionCheck(){
        return !Schema.sObjectType.Contact.fields.Data_Source__c.isCreateable() && !Schema.sObjectType.Contact.fields.Data_Source__c.isAccessible();
    }
    public static Boolean receiveInputSecondContactPermissionCheck(Boolean twomems,Id primaryContactId,String secondContactFirstName){
        return twomems == true && primaryContactId != null && (secondContactFirstName != null || secondContactFirstName != '');      
    }
	public static boolean isNotExistingContactCheck(Boolean isContactExisting, Contact primaryContact){
    	return isContactExisting == false && primaryContact == null;
    }
    public static boolean isExistingContactCheck(Id contId, Boolean isContactExisting){
    	return contId != null || isContactExisting == true;
    }
    public static boolean dateFormatCheck(String eDate){
    	return eDate != null && eDate != '';
    }
   	public static boolean secondContactRequiredCheck(Boolean twomems,Id primaryContactId,String secondContactFirstName){
        if(receiveInputPermissionCheck()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,MembershipConstants.INSUFFICIENT_ACCESS));
        }
        List<Contact> contactList =[SELECT Id,Salutation,Gender__c,Parent_Contact__c,Branch__c, LastName, FirstName, Email,MailingStreet,MailingState,MailingCity, Phone,MailingPostalCode,Prefered_First_Name__c,AccountId FROM Contact WHERE Parent_Contact__c = :primaryContactId];
        if(!contactList.isEmpty()){
    	    return receiveInputSecondContactPermissionCheck(twomems,primaryContactId,secondContactFirstName) && contactList.isEmpty();
        }else{
            return receiveInputSecondContactPermissionCheck(twomems,primaryContactId,secondContactFirstName);
        }
    }
}