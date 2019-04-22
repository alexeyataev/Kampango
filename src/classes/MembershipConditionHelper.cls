public without sharing class MembershipConditionHelper {

    public static String companionCheck(Boolean twomems){
        String contactType;
        if(twomems == true){
            contactType = MembershipConstants.JOINT;
        }
        else{
            contactType = MembershipConstants.INDIVIDUAL;
        }
        return contactType;
    }
    public static Contact contactFinder( Id contId, String email){
        Contact primaryContact;
         if(!Schema.sObjectType.Contact.fields.Data_Source__c.isAccessible()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,MembershipConstants.INSUFFICIENT_ACCESS));
        }
        if(contId != null){
             primaryContact =[SELECT Id,Salutation,Gender__c, LastName, FirstName, Email, Phone,MailingStreet,MailingState,MailingCity,MailingPostalCode,Prefered_First_Name__c,AccountId FROM Contact WHERE Id =:contId limit 1];
        }
        else{
            primaryContact =[SELECT Id,Salutation,Gender__c, LastName, FirstName, Email, Phone,MailingStreet,MailingState,MailingCity,MailingPostalCode,Prefered_First_Name__c,AccountId FROM Contact WHERE Email = :email AND Email != '' limit 1];
        }
        return primaryContact;
    }
    public static void duplicateFinder(Database.Error duplicateError){
        if(duplicateError instanceof Database.DuplicateError) {
            Datacloud.DuplicateResult duplicateResult = 
                ((Database.DuplicateError)duplicateError).getDuplicateResult();
            System.debug('Duplicate records have been detected by ' + 
                         duplicateResult.getDuplicateRule());
            System.debug(duplicateResult.getErrorMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,MembershipConstants.DUPLICATE_RECORDS_FOUND));
        }
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,''+duplicateError));
        }
    }
    public static void saveResultCheck(Database.SaveResult sr){
        if (!sr.isSuccess()) {
            
            // Insertion failed due to duplicate detected
            for(Database.Error duplicateError : sr.getErrors()){
                DuplicateFinder(duplicateError);
            }
        }
    }
    public static map<string, list<sObject>> assignBranchValues(Id branch){
        List<Account> acc;
        Map<String, list<sObject>> nearestBranchs;
        if(branch!= null){
            acc = Database.Query('SELECT id,name,Data_Source__c FROM account WHERE ID =\''+branch+'\' LIMIT 1');
            String strs = '';
            map<string, list<account>> accmap = new map<string, list<account>>();
            accmap.put(strs,acc);
            nearestBranchs = accmap; 
        }    
        return nearestBranchs;
    }
}