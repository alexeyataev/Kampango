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
        
        String firstname = contactFieldsList[0];
        String lastname = contactFieldsList[1];
        String email = contactFieldsList[2];
        String genders = contactFieldsList[3];
        String phone = contactFieldsList[4];
       
        String postCode = contactFieldListExt[0];
        String contactPreference = contactFieldListExt[1];
        String selectedPreferences = contactFieldListExt[2];
        String streetValue = contactFieldListExt[3];
        String streetValue1 = contactFieldListExt[4];
        String streetValue2 = contactFieldListExt[5];
        String stateValue = contactFieldListExt[6];
        String cityValue = contactFieldListExt[7];
                                               
        Contact createContact = new Contact();
        
        createContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
        createContact.Prefered_First_Name__c = firstname;
        createContact.LastName = lastname;
        createContact.Email = email;
        createContact.Phone = phone;
        createContact.MailingPostalCode = postCode;
        createContact.Contact_Prefrence__c = contactPreference;
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
        createContact.Salutation = selectedPreferences;
        createContact.Gender__c = genders;
        createContact.MailingStreet = streetValue+''+streetValue2+''+streetValue2;
        createContact.MailingState = stateValue;
        createContact.MailingCity = cityValue;
        Database.upsert(createContact, false);
        
        
        System.debug('contactFieldsList: '+contactFieldsList+'\n'+'contactFieldsList: '+contactFieldListExt+'\n'+'Contact Details: '+createContact);
        return createContact;
       
    }
}