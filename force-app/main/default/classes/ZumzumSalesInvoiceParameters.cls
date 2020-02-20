public class ZumzumSalesInvoiceParameters {
    @AuraEnabled @InvocableVariable public String bookingId;
    @AuraEnabled @InvocableVariable public String customerId;
    @AuraEnabled @InvocableVariable public String dimension1Id;
    @AuraEnabled @InvocableVariable public String dimension2Id;
    @AuraEnabled @InvocableVariable public Integer foreignNetAmount;
    @AuraEnabled @InvocableVariable public String nominalAccountId;
    @AuraEnabled @InvocableVariable public Integer quantity;
    @AuraEnabled @InvocableVariable public String productId;
    @AuraEnabled @InvocableVariable public String taxRateId;
    @AuraEnabled @InvocableVariable public String transactionCurrencyId;
}