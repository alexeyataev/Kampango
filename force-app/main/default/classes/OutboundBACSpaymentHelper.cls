public class OutboundBACSpaymentHelper {
    public static void processPaymentRun (Payment_Run__c paymentRun){
        final String ZUMZUM_NOMINAL_CODE = '9600';
        // Get Ids of purchase invoises
        Set<Id> purchaseInvoiceIds = new Set<Id>();
        for (Payment_Run_Line_Item__c p: paymentRun.Payment_Run_Line_Items__r){
            purchaseInvoiceIds.add(p.Purchase_Invoice__c);
        }

        List<Zumzum__Ledger__c> ledgers = [
            SELECT ID, Name, Zumzum__Customer_Supplier_Account_Name__c,
                Zumzum__Bank_Payment__r.Zumzum__Bank__c, Zumzum__Purchase_Invoice__r.Zumzum__Invoice_Date__c,
                Zumzum__Tax_Code_Link__c, Zumzum__Amount__c,
                Zumzum__Sub_Account_Nominal_Link__c,
                Zumzum__Net_Amount__c,
                Zumzum__Credit__c
            FROM Zumzum__Ledger__c
               WHERE Zumzum__Purchase_Invoice__c IN :purchaseInvoiceIds
                   AND Zumzum__Customer_Supplier_Account_Name__c <> ''
                   AND Zumzum__Sub_Account_Nominal_Link__r.Zumzum__Nominal_Code__c = :ZUMZUM_NOMINAL_CODE
        ];

        System.debug('Code temporarily deleted to unblock deployment');
    }
}