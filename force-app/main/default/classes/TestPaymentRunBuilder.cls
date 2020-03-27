public with sharing class TestPaymentRunBuilder {
    
    private List<Payment_Run_Line_Item__c> lineItems {get; private set;}
    private Boolean insertRecord = true;

    public TestPaymentRunBuilder() {
        this.lineItems = new List<Payment_Run_Line_Item__c>();
    }

    
    public TestPaymentRunBuilder insertLineItem(Id purchaseInvoiceId, Boolean isEmailSent) {
        lineItems.add(new Payment_Run_Line_Item__c(
            Purchase_Invoice__c = purchaseInvoiceId,
            Is_Email_Sent__c = isEmailSent
        ));
        return this;
    }

    public TestPaymentRunBuilder insertLineItem(Id purchaseInvoiceId) {
        return insertLineItem(purchaseInvoiceId, false);
    }

    public Payment_Run__c build() {
        Payment_Run__c pr = new Payment_Run__c();
        insert pr;
        
        this.linkLineItems(pr);
        insert lineItems;

        lineItems.clear();
        return pr;
    }

    private void linkLineItems(Payment_Run__c pr) {
        for (Payment_Run_Line_Item__c item : lineItems) {
            item.Payment_Run__c = pr.Id;
        }
    }
}
