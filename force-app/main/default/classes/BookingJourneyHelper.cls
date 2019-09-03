public without sharing class BookingJourneyHelper {

    @InvocableMethod(label='Update Contact')
    public static void updateContact(List<Contact> contacts){
        for(Contact contact: contacts){
            contact.npe01__PreferredPhone__c = String.valueOf(contact.npe01__PreferredPhone__c);
        }
        if(contacts != null && !contacts.isEmpty()){
            upsert contacts Id;
        }
    }

}
