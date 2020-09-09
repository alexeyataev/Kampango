public with sharing class BookingFlowContactDetailsParams {
    @AuraEnabled @InvocableVariable public Booking__c bookingRecord;
    @AuraEnabled @InvocableVariable public Contact primaryContact;
    @AuraEnabled @InvocableVariable public Contact partnerContact;
    @AuraEnabled @InvocableVariable public Individual individualRecord;
    @AuraEnabled @InvocableVariable public Boolean doNeedToUpdate;
    @AuraEnabled @InvocableVariable public Boolean isQuickBooking;
    @AuraEnabled @InvocableVariable public Boolean isWithPartner;
}