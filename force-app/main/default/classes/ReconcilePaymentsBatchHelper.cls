public class ReconcilePaymentsBatchHelper {
    public static final String CREATED_STATUS = 'Created';
    private static final String DRAFT_STATUS = 'Draft';
    private static final Integer BANK_NOMINAL_ACCOUNT_CODE = 9401;

    public static void processBatchReceiptReport(Batch_Receipt_Report__c receipt) {
        Map<String, Id> paymentsBankReceipt = new Map<String, Id>();
        List<Batch_Receipt_Report_Item__c> reportItems = receipt.Batch_Receipt_Report_Items__r;
        Set<String> paymentIds = new Set<String>();

        for (Batch_Receipt_Report_Item__c item : reportItems) {
            paymentIds.add(item.Payment_Id__c);
        }
        Zumzum__BankReconcile__c bankReconcile = getBankReconcile(receipt); 

        List<Zumzum__Ledger__c> ledgers = [
            SELECT Id, Zumzum__BankReconcile__c, Zumzum__Bank_Reconcile__c, Zumzum__Bank_Receipt__r.Payment__r.cpm__Payment_Reference__c,
                Zumzum__Bank_Receipt__c
            FROM Zumzum__Ledger__c
            WHERE Zumzum__Bank_Receipt__r.Payment__r.cpm__Payment_Reference__c IN:paymentIds
                AND Zumzum__Sub_Account_Nominal_Link__r.Zumzum__Account_Code__c =: BANK_NOMINAL_ACCOUNT_CODE
            WITH SECURITY_ENFORCED
        ];
        paymentsBankReceipt = getpaymentsBankReceiptMap(ledgers);

        for (Zumzum__Ledger__c ledger : ledgers) {
            ledger.Zumzum__BankReconcile__c = bankReconcile.Id;
            ledger.Zumzum__Bank_Reconcile__c = 'N';
        }
        update ledgers;
        
        for (Batch_Receipt_Report_Item__c reportItem : reportItems) {
            reportItem.Bank_Receipt__c = paymentsBankReceipt.get(reportItem.Payment_Id__c);
        }
        update reportItems;

        receipt.BankReconcile__c = bankReconcile.Id;
        update receipt;
    }

    private static Zumzum__BankReconcile__c getBankReconcile(Batch_Receipt_Report__c receipt) {
        Zumzum__BankReconcile__c bankReconcile = new Zumzum__BankReconcile__c(
            Zumzum__Status__c = DRAFT_STATUS,
            Zumzum__Bank_Account__c = getBankAccountIdByNominalAccountCode(BANK_NOMINAL_ACCOUNT_CODE),
            Zumzum__Statement_Date__c = Date.today(),
            Zumzum__Transaction_Start_Date__c = receipt.From_Date__c,
            Zumzum__Transaction_End_Date__c = receipt.To_Date__c
        );
        insert bankReconcile;
        return bankReconcile;
    }

    private static Id getBankAccountIdByNominalAccountCode(Integer code) {
        Zumzum__Bank_Account__c bankAccount = [
            SELECT Id, Name FROM 
            Zumzum__Bank_Account__c 
            WHERE Zumzum__Nominal_Account__r.Zumzum__Account_Code__c =: code
            LIMIT 1
        ];
        return bankAccount.Id;
    }

    private static Map<String, Id> getpaymentsBankReceiptMap(List<Zumzum__Ledger__c> ledgers) {
        Map<String, String> paymentsBankReceipt = new Map<String, String>();
        for (Zumzum__Ledger__c ledger : ledgers) {
            paymentsBankReceipt.put(ledger.Zumzum__Bank_Receipt__r.Payment__r.cpm__Payment_Reference__c, ledger.Zumzum__Bank_Receipt__c);
        }
        return paymentsBankReceipt;
    }
}