public virtual class CardPaymentParameters {
    @AuraEnabled @InvocableVariable public Decimal amount;
    @AuraEnabled @InvocableVariable public Decimal amountRecurring;
    @AuraEnabled @InvocableVariable public String contactId;
    @AuraEnabled @InvocableVariable public String errorPage;
    @AuraEnabled @InvocableVariable public Decimal giftAidableAmount;
    @AuraEnabled @InvocableVariable public String membershipType;
    @AuraEnabled @InvocableVariable public Date paymentPlanStartDate;
    @AuraEnabled @InvocableVariable public Date paymentPlanEndDate;
    @AuraEnabled @InvocableVariable public String salesInvoiceId;
    @AuraEnabled @InvocableVariable public String successPage;
}