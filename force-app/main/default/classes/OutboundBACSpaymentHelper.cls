public class OutboundBACSpaymentHelper {

    private static final String PAYMENT_RUN_RESULT_SUCCESS = 'Success';
    private static final String PAYMENT_RUN_RESULT_ERROR = 'Error';
    private static final String ZUMZUM_NOMINAL_CODE = '9600';
    private static final string BANK_ACCOUNT_NAME = 'BACS Payments in Transit';

    public static String processPaymentRun (Payment_Run__c paymentRun) {
        Set<Id> purchaseInvoiceIds = new Set<Id>();
        for (Payment_Run_Line_Item__c paymentRunLineItem: paymentRun.Payment_Run_Line_Items__r) {
            purchaseInvoiceIds.add(paymentRunLineItem.Purchase_Invoice__c);
        }

        List<Zumzum__Ledger__c> ledgers = [
            SELECT ID, Name, Zumzum__Customer_Supplier_Account_Name__c,
                Zumzum__Bank_Payment__r.Zumzum__Bank__c,
                Zumzum__Purchase_Invoice__r.Zumzum__Invoice_Date__c,
                Zumzum__Purchase_Invoice__r.Zumzum__Total_Gross__c,
                Zumzum__Tax_Code_Link__c, Zumzum__Amount__c,
                Zumzum__Sub_Account_Nominal_Link__c,
                Zumzum__Net_Amount__c,
                Zumzum__Credit__c
            FROM Zumzum__Ledger__c
            WHERE Zumzum__Purchase_Invoice__c IN :purchaseInvoiceIds
                AND Zumzum__Customer_Supplier_Account_Name__c <> ''
                AND Zumzum__Sub_Account_Nominal_Link__r.Zumzum__Nominal_Code__c = :ZUMZUM_NOMINAL_CODE
                AND Zumzum__Credit__c <> null
        ];

        Map<Id, List<Zumzum__Ledger__c>> purchaseInvoiceToLedgerMap = new Map<Id, List<Zumzum__Ledger__c>>();

        for (Zumzum__Ledger__c ledger: ledgers) {

            if (purchaseInvoiceToLedgerMap.containsKey(ledger.Zumzum__Purchase_Invoice__r.Id)) {
                purchaseInvoiceToLedgerMap.get(ledger.Zumzum__Purchase_Invoice__r.Id).add(ledger);                
            } else {
                List<Zumzum__Ledger__c> currentLegers = new List<Zumzum__Ledger__c>();
                currentLegers.add(ledger);
                purchaseInvoiceToLedgerMap.put(ledger.Zumzum__Purchase_Invoice__r.Id, currentLegers);
            }
        }
        
        String processPaymentRunResult = initiateBankSupplierPayment(purchaseInvoiceToLedgerMap, paymentRun, getBankAccountId());

        return processPaymentRunResult;
    }

    private static Id getBankAccountId() {
        return [
            SELECT Id
            FROM Zumzum__Bank_Account__c
            WHERE Name = :BANK_ACCOUNT_NAME
            LIMIT 1
        ].Id;
    }

    private static String initiateBankSupplierPayment(Map<Id, List<Zumzum__Ledger__c>> purchaseInvoiceToLedgerMap, Payment_Run__c paymentRun, Id bankAccountId) {
        Zumzum.BankSupplierPaymentService bankSupplierPaymentService = new Zumzum.BankSupplierPaymentService();
        List<Zumzum.BankSupplierPaymentService.BankSupplierPaymentWrapper> listPaymentWrapper = new List<Zumzum.BankSupplierPaymentService.BankSupplierPaymentWrapper>();
        for (Id purchaseInvoiceId :purchaseInvoiceToLedgerMap.keySet()) {
            Zumzum.BankSupplierPaymentService.BankSupplierPaymentWrapper paymentWrapper = new Zumzum.BankSupplierPaymentService.BankSupplierPaymentWrapper();
            paymentWrapper.AccountId = purchaseInvoiceToLedgerMap.get(purchaseInvoiceId)[0].Zumzum__Customer_Supplier_Account_Name__c;
            paymentWrapper.BankAccountId = bankAccountId;
            paymentWrapper.PostingDate = Date.Today();
            paymentWrapper.TaxRate = purchaseInvoiceToLedgerMap.get(purchaseInvoiceId)[0].Zumzum__Tax_Code_Link__c;

            List<Zumzum.BankSupplierPaymentService.BankPaymentLine> listBankPaymentLines = new List<Zumzum.BankSupplierPaymentService.BankPaymentLine>();
            for (Zumzum__Ledger__c currentLedger: purchaseInvoiceToLedgerMap.get(purchaseInvoiceId)) {
                ZumZum.BankSupplierPaymentService.BankPaymentLine bankPaymentLine = new ZumZum.BankSupplierPaymentService.BankPaymentLine();
                bankPaymentLine.LedgerName = currentLedger.Name;
                bankPaymentLine.Amount = currentLedger.Zumzum__Amount__c != null ? currentLedger.Zumzum__Credit__c - currentLedger.Zumzum__Amount__c : currentLedger.Zumzum__Credit__c;
                listBankPaymentLines.add(bankPaymentLine);
            }

            paymentWrapper.BankPaymentLines = listBankPaymentLines;
            listPaymentWrapper.add(paymentWrapper);
        }

        ZumZum.BankSupplierPaymentService.Response response = bankSupplierPaymentService.CreateBankSupplierPayment(listPaymentWrapper);

        Set<Id> bankPaymentIds = new Set<Id>();

        for (Zumzum__Bank_Payment__c bankPayment : response.BankPayments.values()) {
            bankPaymentIds.add(bankPayment.Id);
        }

        if (response.ResponseMessage == PAYMENT_RUN_RESULT_SUCCESS) {
            Zumzum__Bank_Payment__c bankPayment = response.BankPayment;
            List<Zumzum__Bank_Payment_Line_Item__c> bankPaymentLineItems = [
                SELECT Id, Zumzum__Bank_Payment__c, Payment_Run__c 
                FROM Zumzum__Bank_Payment_Line_Item__c
                WHERE Zumzum__Bank_Payment__c = :bankPaymentIds
            ];

            for (Zumzum__Bank_Payment_Line_Item__c bankPaymentLineItem: bankPaymentLineItems) {
                bankPaymentLineItem.Payment_Run__c = paymentRun.Id;
            }

            update bankPaymentLineItems;
        }

        return response.ResponseMessage;
    }
}