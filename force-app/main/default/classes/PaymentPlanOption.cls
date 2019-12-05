public with sharing class PaymentPlanOption {
    @AuraEnabled @InvocableVariable public Decimal amountFirst;
    @AuraEnabled @InvocableVariable public Decimal amountRecurring;
    @AuraEnabled @InvocableVariable public String bookingId;
    @AuraEnabled @InvocableVariable public String contactId;
    @AuraEnabled @InvocableVariable public String startDate;
    @AuraEnabled @InvocableVariable public String endDate;
    @AuraEnabled @InvocableVariable public String label;
    @AuraEnabled @InvocableVariable public String value;
}