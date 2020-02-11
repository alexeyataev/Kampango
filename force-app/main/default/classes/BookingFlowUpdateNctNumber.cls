public with sharing class BookingFlowUpdateNctNumber {
 @InvocableMethod(label='Update NCT Number on Contact ')
    public static void updateContact(List<List<Contact>> contacts) {
        if(contacts != null && !contacts.isEmpty()) {
            try {   
                update contacts[0];
            } catch(DmlException ex) {
                System.debug(
                    Label.ContactUpdateException + ' ' +
                    ex.getTypeName() + ' ' +
                    ex.getStackTraceString() + ' ' +
                    ex.getMessage()
                );
            }
        }
    }
}