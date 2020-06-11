public class OutboundBACSpaymentHelper {

    private static final String PAYMENT_RUN_RESULT_SUCCESS = 'Success';
    private static final String PAYMENT_RUN_RESULT_ERROR = 'Error';
    private static String processPaymentRunResult;

    public static Map<String, List<String>> processPaymentRun (Payment_Run__c paymentRun) {

        final String ZUMZUM_NOMINAL_CODE = '9600';
        Map<String, List<String>> paymentRunResultMap = new Map<String, List<String>>();

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

            List<Zumzum__Ledger__c> currentLegers = purchaseInvoiceToLedgerMap.get(ledger.Zumzum__Purchase_Invoice__r.Id);
            if (currentLegers == null) {
                currentLegers = new List<Zumzum__Ledger__c>();
            }

            currentLegers.add(ledger);
            purchaseInvoiceToLedgerMap.put(ledger.Zumzum__Purchase_Invoice__r.Id, currentLegers);
        }

        Id bankAccountId = getBankAccountId();
        for (Id purchaseInvoiceId :purchaseInvoiceToLedgerMap.keySet()) {
            processPaymentRunResult = initiateBankSupplierPayment(purchaseInvoiceToLedgerMap.get(purchaseInvoiceId), paymentRun, bankAccountId);

            if (processPaymentRunResult != PAYMENT_RUN_RESULT_SUCCESS) {
                if (!paymentRunResultMap.containsKey(PAYMENT_RUN_RESULT_ERROR)) {
                    paymentRunResultMap.put(PAYMENT_RUN_RESULT_ERROR, new List<String>());
                }

                 paymentRunResultMap.get(PAYMENT_RUN_RESULT_ERROR).add(processPaymentRunResult);
            }

        }

        return paymentRunResultMap;
    }

    private static Id getBankAccountId() {
        final string BANK_ACCOUNT_NAME = 'BACS Payments in Transit';
        return [
            SELECT Id
            FROM Zumzum__Bank_Account__c
            WHERE Name = :BANK_ACCOUNT_NAME
            LIMIT 1
        ].Id;
    }

    private static String initiateBankSupplierPayment(List<Zumzum__Ledger__c> ledgers, Payment_Run__c paymentRun, Id bankAccountId) {
        Zumzum__Ledger__c ledger0 = ledgers[0];

        Zumzum.BankSupplierPaymentService objBankSupplierPaymentService = new Zumzum.BankSupplierPaymentService();
        Zumzum.BankSupplierPaymentService.BankSupplierPaymentWrapper objPaymentWrapper = new Zumzum.BankSupplierPaymentService.BankSupplierPaymentWrapper();
        
        objPaymentWrapper.AccountId = ledger0.Zumzum__Customer_Supplier_Account_Name__c;
        objPaymentWrapper.BankAccountId = bankAccountId;
        objPaymentWrapper.PostingDate = Date.Today();
        objPaymentWrapper.TaxRate = ledger0.Zumzum__Tax_Code_Link__c;
        objPaymentWrapper.Amount = ledger0.Zumzum__Purchase_Invoice__r.Zumzum__Total_Gross__c;
        List<Zumzum.BankSupplierPaymentService.BankPaymentLine> listBankPaymentLines = new List<Zumzum.BankSupplierPaymentService.BankPaymentLine>();

        for (Zumzum__Ledger__c currentLedger: ledgers) {

            ZumZum.BankSupplierPaymentService.BankPaymentLine obPBankPaymentLine = new ZumZum.BankSupplierPaymentService.BankPaymentLine();
            obPBankPaymentLine.LedgerName = currentLedger.Name;

            obPBankPaymentLine.Amount = currentLedger.Zumzum__Amount__c != null ?
                 currentLedger.Zumzum__Credit__c - currentLedger.Zumzum__Amount__c :
                 currentLedger.Zumzum__Credit__c;

            listBankPaymentLines.add(obPBankPaymentLine);
        }

        objPaymentWrapper.BankPaymentLines = listBankPaymentLines;
        ZumZum.BankSupplierPaymentService.Response objResponse = objBankSupplierPaymentService.CreateBankSupplierPayment(objPaymentWrapper);

        if (objResponse.ResponseMessage != PAYMENT_RUN_RESULT_SUCCESS) {
            return objResponse.ResponseMessage;
        }

        Zumzum__Bank_Payment__c bankPayment = objResponse.BankPayment;

        List<Zumzum__Bank_Payment_Line_Item__c> bankPaymentLineItems = [
            SELECT Id, Zumzum__Bank_Payment__c, Payment_Run__c 
            FROM Zumzum__Bank_Payment_Line_Item__c
            WHERE Zumzum__Bank_Payment__c = :bankPayment.Id
        ];

        for (Zumzum__Bank_Payment_Line_Item__c bankPaymentLineItem: bankPaymentLineItems) {
            bankPaymentLineItem.Payment_Run__c = paymentRun.Id;
        }

        update bankPaymentLineItems;

        return objResponse.ResponseMessage;
    }
}