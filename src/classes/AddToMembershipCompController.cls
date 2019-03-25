public with sharing class AddToMembershipCompController {
    private static Contact contact;
	@auraenabled    
    public static void addToMembershipValidation(Id contId){  
        system.debug('addToMembershipValidation : contId : '+contId);
        if (!Schema.sObjectType.Contact.fields.Email.isAccessible()){
         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Insufficient Access'));
        }
        contact = [SELECT 
                  		Id,
                  		Email
                   FROM
                  		Contact
                   WHERE
                  		Id = :contId];
       Id contactId;
       Boolean isMembershipExists = ContactUtilities.isMembershipExists(contactId, contact.Email);
        if(isMembershipExists == true) {
            AuraHandledException e = new AuraHandledException('You Cant Add Membership, hence already membership exists for this contact');
            e.setMessage('You Cant Add Membership, hence already membership exists for this contact');
            system.debug(e);
            throw e;
        }
      }
    }