public with sharing class PaymentPlanParameters {
    public Decimal amountFirst;
    public Decimal amountRecurring;
    @AuraEnabled @InvocableVariable public String bookingId;
    @AuraEnabled @InvocableVariable public String contactId;
    @AuraEnabled @InvocableVariable public Decimal courseFee;
    @AuraEnabled @InvocableVariable public Date courseStartDate;
    public Date firstRecurringPaymentDate;
    public Integer monthCount;
}