public class OutboundBACSpaymentHelper {
    public static void processPaymentRun (Payment_Run__c paymentRun){
        // Get Ids of purchase invoises
        Set<Id> purchaseInvoiceIds = new Set<Id>();
        for (Payment_Run_Line_Item__c p: paymentRun.Payment_Run_Line_Items__r){
            purchaseInvoiceIds.add(p.Purchase_Invoice__c);
        }

        List<Zumzum__Ledger__c> ledgers = [
            SELECT ID, Name, Zumzum__Customer_Supplier_Account_Name__c,
                Zumzum__Bank_Payment__r.Zumzum__Bank__c, Zumzum__Purchase_Invoice__r.Zumzum__Invoice_Date__c,
                Zumzum__Tax_Code_Link__c, Zumzum__Amount__c
            FROM Zumzum__Ledger__c
               WHERE Zumzum__Purchase_Invoice__c IN :purchaseInvoiceIds
        ];

        for (Zumzum__Ledger__c ledger: ledgers) {
            initiateBankSupplierPayment(ledger);
        }
    }

    private static void initiateBankSupplierPayment(Zumzum__Ledger__c ledger){
        // Initiate A New Bank Supplier Payment
         Zumzum.BankSupplierPaymentService objBankSupplierPaymentService = new Zumzum.BankSupplierPaymentService();
        // Create Bank Supplier Payment Wrapper 
        Zumzum.BankSupplierPaymentService.BankSupplierPaymentWrapper objPaymentWrapper = new Zumzum.BankSupplierPaymentService.BankSupplierPaymentWrapper();
        // Supplier Account ID 
        objPaymentWrapper.AccountId = ledger.Zumzum__Customer_Supplier_Account_Name__c;
        // Bank Account ID 
        objPaymentWrapper.BankAccountId = ledger.Zumzum__Bank_Payment__r.Zumzum__Bank__c;
        // Bank Supplier Payment Posting Date 
        objPaymentWrapper.PostingDate = ledger.Zumzum__Purchase_Invoice__r.Zumzum__Invoice_Date__c;
        // TaxRate
        objPaymentWrapper.TaxRate = ledger.Zumzum__Tax_Code_Link__c;
        //Amount
        objPaymentWrapper.Amount = ledger.Zumzum__Amount__c;
        
        // Create Bank Supplier Payment Line Wrapper 
        List<Zumzum.BankSupplierPaymentService.BankPaymentLine> listBankPaymentLines = new List<Zumzum.BankSupplierPaymentService.BankPaymentLine>();
        
        ZumZum.BankSupplierPaymentService.BankPaymentLine obPBankPaymentLine = new ZumZum.BankSupplierPaymentService.BankPaymentLine();
        // Ledger Record of Purchase Invoice Line To Be Paid 
        obPBankPaymentLine.LedgerName = ledger.Name; // typo in variable name
        // Amount Of Line Item To Be Paid
        obPBankPaymentLine.Amount = ledger.Zumzum__Amount__c;
        // add to overall list
        listBankPaymentLines.add(obPBankPaymentLine);
         
        objPaymentWrapper.BankPaymentLines = listBankPaymentLines;
        // Execute the command to post the Bank Supplier Payment
        ZumZum.BankSupplierPaymentService.Response objResponse = objBankSupplierPaymentService.CreateBankSupplierPayment(objPaymentWrapper);
        // Receive a response of the Bank Payment records created
        System.debug('Response>>' + objResponse.ResponseMessage);
    }
}