/*ContactUtilities Class: Used to check the Duplicate Contacts.
    **
    * Author        : Ujwal Theja
    * Created Date  : 28-01-2019
    * (c) Copyright by CSS Corp.
    **
*/
public without sharing class ContactHelper {
	/* This method uses to create a contact based on input values. 
     **
	 * contactFieldsList:- Get the list of Primary Contact input field values.
	 * contactFieldListExt:- Get the list of Secondary Contact input field values.
	 * selectBranch:- Get the Branch Account Id from "Branch" selected picklist value.
	 * recordType:- Get the string value like "Parent/Companion" value from controller.
	 * newCont:- Get the Contact  values based on the existing contact.
	 * 
	 **
	*/
    public static Contact getCreateContact(list<String> contactFieldsList, list<String> contactFieldListExt, 
                                           Id selectBranch, String recordType,Contact newCont, list<Boolean> contactBooleanList){

        Contact createContact;                                       
        
        Contact con;
        createContact = new Contact();
        createContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
                                               
        createContact.FirstName = contactFieldsList[0];
        createContact.LastName = contactFieldsList[1];
        createContact.Email = contactFieldsList[2];
        createContact.Gender__c = contactFieldsList[3];
        createContact.Phone = contactFieldsList[4];
        createContact.Salutation = contactFieldsList[5];
                                               
        createContact.MailingPostalCode = contactFieldListExt[0];
        if(contactFieldListExt[1] != null && contactFieldListExt[1] != ''){
            Date expDate = Date.valueOf(contactFieldListExt[1]);
            createContact.Expected_Due_Date__c = expDate; 
        }
        if(newCont != null){
            if (!Schema.sObjectType.Contact.fields.AccountId.isCreateable()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
                return null;
            }
            con =[Select AccountId from Contact where id = :newCont.id];
            if (!Schema.sObjectType.Contact.fields.AccountId.isCreateable()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
                return null;
            }
            createContact.Parent_Contact__c = newCont.id;
            createContact.AccountId = con.AccountId;
        }
                                               
        createContact.Branch__c = selectBranch; 
                                               
        createContact.MailingStreet = contactFieldListExt[2]+''+contactFieldListExt[3]+''+contactFieldListExt[4];
        createContact.MailingState = contactFieldListExt[5];
        createContact.MailingCity = contactFieldListExt[6];
        createContact.Data_Source__c = 'Salesforce';  
        createContact.SMS_Opt_Out__c = contactBooleanList[0];
        createContact.Post_Opt_Out__c = contactBooleanList[1];
        createContact.HasOptedOutOfEmail = contactBooleanList[2];
        createContact.DoNotCall = contactBooleanList[3];                                      
        if(contactBooleanList[0] == false){
           createContact.SMS_Opt_Out__c = true;                                        
        }
        else{
             createContact.SMS_Opt_Out__c = false;                                        
        }
        if(contactBooleanList[1] == false){
             createContact.Post_Opt_Out__c = true;                                        
        }
        else{
             createContact.Post_Opt_Out__c = false;                                       
        }
        if(contactBooleanList[2] == false){
             createContact.HasOptedOutOfEmail = true;                                      
        }
        else{
             createContact.HasOptedOutOfEmail = false;                                      
        }
        if(contactBooleanList[3] == false){
             createContact.DoNotCall = true;                                     
        }
        else{
             createContact.DoNotCall = false;                                      
        }                                   
        Database.upsert(createContact, false);
                                               
        System.debug('contactFieldsList: '+contactFieldsList+'\n'+'contactFieldsList: '+contactFieldListExt+'\n'+'Contact Details: '+createContact);
        return createContact;
       
    }
}