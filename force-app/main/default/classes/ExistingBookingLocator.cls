public without sharing class ExistingBookingLocator {
    private static final List<String> LIVE_BOOKING_STATUSES = new List<String>{'Enquiry', 'Reserved', 'Confirmed'};
    private static final String BOOKING_SOURCE_QUICK_BOOK = 'Quick Book';
    
    @InvocableMethod(label='Find Existing Booking')
    public static List<Response> findExistingBooking(List<Request> requestList){
        Id contactId = requestList[0].contactId;
        Id courseId = requestList[0].courseId;

        @SuppressWarnings('PMD.ApexCRUDViolation')
        //Incident #118 - https://confluence.nct.org.uk:8443/x/EoSO
        List<Booking__c> existingBookings = [
            SELECT Id, Source__c
            FROM Booking__c
            WHERE Status__c IN :LIVE_BOOKING_STATUSES
                AND Course__c = :courseId 
                AND Primary_Contact__c = :contactId
            WITH SECURITY_ENFORCED
        ];

        Response response = new Response();

        if (existingBookings.size() == 1) {
            response.bookingId = existingBookings[0].Id;
        } else if (existingBookings.size() > 1) {
            setBookingId(existingBookings, response);
        }

        List<Response> responseWrapper= new List<Response>();
        responseWrapper.add(response);
        return responseWrapper;  
    }

    private static void setBookingId(List<Booking__c> bookings, Response response) {
        Integer quickBookCounter = 0;
        for (Booking__c booking : bookings) {
            if (booking.Source__c == BOOKING_SOURCE_QUICK_BOOK) {
                response.bookingId = booking.Id;
                quickBookCounter++;
            }
        }
        if (quickBookCounter > 1) {
            response.bookingId = null;
        }
    }

    public class Request {
        @invocableVariable (label='Contact Id' required=true)
        public Id contactId;

        @invocableVariable (label='Course Id' required=true)
        public Id courseId;
    }

    public class Response {
        @invocableVariable (label='Booking Id')
        public Id bookingId; 
    }
}
