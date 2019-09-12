public without sharing class BookingJourneyHelper {

    @InvocableMethod(label='Update Contact')
    public static List<Contact> updateContact(List<Contact> contacts){
        for(Contact contact: contacts){
            contact.npe01__PreferredPhone__c = String.valueOf(contact.npe01__PreferredPhone__c);
            contact.Salutation = String.valueOf(contact.Salutation);
        }
        if(contacts != null && !contacts.isEmpty()){
            try{
                upsert contacts Id;
            } catch(DmlException ex){
                System.debug(
                    Label.ContactUpdateException + ' ' +
                    ex.getTypeName() + ' ' +
                    ex.getStackTraceString() + ' ' +
                    ex.getMessage() + ' ' +
                    ex.getStackTraceString()
                );
            }
        }
        return contacts;
    }

}