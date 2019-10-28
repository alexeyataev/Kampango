@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class BookingStatusFlowHelper {
    
    @InvocableMethod(Label='Update Bookings (Database)')
    global static void updateBookings(List<List<Booking__c>> bookingsToUpdate){
        String errorMessage;
        Database.SaveResult[] results;
        for (Booking__c booking : bookingsToUpdate[0]){
            booking.Status__c = String.valueOf(booking.Status__c);
        }
        results = Database.update(bookingsToUpdate[0], false);
        for(Database.saveResult sr :results){
            if(!sr.isSuccess()){
                for(Database.Error error : sr.getErrors()){
                    errorMessage = 'The following error has occurred. ' +
                        error.getStatusCode() + ': ' + error.getMessage() +
                        'Booking fields that affected this error: ' + error.getFields();
                    System.debug(errorMessage);
                }
            }
        }

    } 
}
//NOPMD
//Incident #15 - https://confluence.nct.org.uk:8443/x/EoSO
