public with sharing class BookingFlowUpdateNctNumber {
 @InvocableMethod(label='Update NCT Number on Contact ')
    public static void updateContact(List<List<Contact>> contacts) {
        if(contacts != null && !contacts.isEmpty()) {
            update contacts[0];
        }
    }
}