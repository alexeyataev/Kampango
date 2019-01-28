/*ContactUtilities Class: Used to check the Duplicate Contacts.
    **
    * Author        : Ujwal Theja
    * Created Date  : 28-01-2019
    * (c) Copyright by CSS Corp.
    **
*/
public class ContactHelper {
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
                                           Id selectBranch, String recordType,Contact newCont){

        Contact createContact;                                       
        if((contactFieldsList[1] != null && contactFieldsList[1] != '') && (contactFieldsList[2] != null && contactFieldsList[2] != '')){
               
               
        	   createContact = new Contact();
               createContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
               
               createContact.Prefered_First_Name__c = contactFieldsList[0];
               createContact.LastName = contactFieldsList[1];
               createContact.Email = contactFieldsList[2];
               createContact.Gender__c = contactFieldsList[3];
               createContact.Phone = contactFieldsList[4];
               createContact.Salutation = contactFieldsList[5];
            
               createContact.MailingPostalCode = contactFieldListExt[0];
               createContact.Contact_Prefrence__c = contactFieldListExt[1];
               //if(eDate != null){
               //expDate = Date.valueOf(eDate);
               //createContact.Expected_Due_Date__c = expDate; 
               //}
               if(newCont != null){
                   Contact con =[Select AccountId from Contact where id = :newCont.id];
                   createContact.Parent_Contact__c = newCont.id;
                   createContact.AccountId = con.AccountId;
               }
               
               createContact.Branch__c = selectBranch; 

               createContact.MailingStreet = contactFieldListExt[2]+''+contactFieldListExt[3]+''+contactFieldListExt[4];
               createContact.MailingState = contactFieldListExt[5];
               createContact.MailingCity = contactFieldListExt[6];
               Database.upsert(createContact, false);
        
               
        }                                       

        System.debug('contactFieldsList: '+contactFieldsList+'\n'+'contactFieldsList: '+contactFieldListExt+'\n'+'Contact Details: '+createContact);
        return createContact;
       
    }
}