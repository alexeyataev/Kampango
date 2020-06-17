public class ReconcilePaymentsBatchHelper {
    public static final String CREATED_STATUS = 'Created';
    private static final String DRAFT_STATUS = 'Draft';
    private static final Integer BANK_NOMINAL_ACCOUNT_CODE = 9401;

    public static void processBatchReceiptReportItems(List<Batch_Receipt_Report_Item__c> receiptReportItems) {
        List<Batch_Receipt_Report__c> receiptReports = [
            SELECT Id, Status__c, Batch_Id__c, From_Date__c, To_Date__c
            FROM Batch_Receipt_Report__c
            WHERE Id = :receiptReportItems[0].Batch_Receipt_Report__c
        ];

        Set<String> receiptIds = new Set<String>();
        Set<String> paymentIds = new Set<String>();

        for (Batch_Receipt_Report_Item__c item : receiptReportItems) {
            if (item.Amount__c > 0) {
                receiptIds.add(item.Payment_Id__c);
            } else if (item.Amount__c < 0) {
                paymentIds.add(item.Payment_Id__c);
            }
        }

        List<cpm__Payment__c> cpmPayments = getCpmPaymentsByTransactionIdAndAmount(paymentIds);
        Map<Id, cpm__Payment__c> salesInvoicesPaymentsMap = new Map<Id, cpm__Payment__c>();
        Map<String, Id> paymentsReferenceSalesInvoiceIdMap = new Map<String, Id>();

        for (cpm__Payment__c payment : cpmPayments) {
            salesInvoicesPaymentsMap.put(payment.cpm__Installment__r.Sales_Invoice__c, payment);
            paymentsReferenceSalesInvoiceIdMap.put(payment.cpm__Payment_Reference__c, payment.cpm__Installment__r.Sales_Invoice__c);
        }
        
        List<Zumzum__Bank_Payment__c> bankPayments = getBankPaymentsBySalesCredits(salesInvoicesPaymentsMap.keySet());
        Map<Id, Id> salesInvoicesBankPaymentsMap = new Map<Id, Id>();

        for (Zumzum__Bank_Payment__c bankPayment : bankPayments) {
            for (Zumzum__Ledger_Payment_History__c salesCreditAllocation : bankPayment.Zumzum__Ledger_Payment_History__r) {
                if (salesCreditAllocation.Zumzum__Amount__c == salesInvoicesPaymentsMap.get(salesCreditAllocation.Zumzum__Sales_Credit__r.Zumzum__Sales_Invoice_to_Credit__c).cpm__Amount__c) {
                    salesInvoicesBankPaymentsMap.put(salesCreditAllocation.Zumzum__Sales_Credit__r.Zumzum__Sales_Invoice_to_Credit__c, bankPayment.Id);
                }              
            }
        }

        Zumzum__BankReconcile__c bankReconcile = getBankReconcile(receiptReports[0]);
        List<Zumzum__Ledger__c> ledgers = getLedgers(receiptIds, new Set<Id>(salesInvoicesBankPaymentsMap.values()));
        Map<String, Id> paymentsBankReceiptsMap = getpaymentsBankReceiptsMap(ledgers);

        for (Zumzum__Ledger__c ledger : ledgers) {
            ledger.Zumzum__BankReconcile__c = bankReconcile.Id;
            ledger.Zumzum__Bank_Reconcile__c = 'N';
        }
        update ledgers;

        for (Batch_Receipt_Report_Item__c reportItem : receiptReportItems) {
            if (reportItem.Amount__c > 0) {
                reportItem.Bank_Receipt__c = paymentsBankReceiptsMap.get(reportItem.Payment_Id__c);
            } else if (reportItem.Amount__c < 0) {
                reportItem.Bank_Payment__c = salesInvoicesBankPaymentsMap.get(paymentsReferenceSalesInvoiceIdMap.get(reportItem.Payment_Id__c));
            }
        }
        update receiptReportItems;

        receiptReports[0].BankReconcile__c = bankReconcile.Id;
        update receiptReports[0];
    }

    private static List<cpm__Payment__c> getCpmPaymentsByTransactionIdAndAmount(Set<String> paymentIds) {
        return [
            SELECT 
                cpm__Amount__c, 
                cpm__Installment__c, 
                cpm__Installment__r.Sales_Invoice__c, 
                cpm__Payment_Reference__c
            FROM cpm__Payment__c
            WHERE cpm__Payment_Reference__c IN :paymentIds
        ];
    }

    private static List<Zumzum__Bank_Payment__c> getBankPaymentsBySalesCredits(Set<Id> salesInvoicesIds) {
        return [
            SELECT 
                Id, 
                (SELECT Zumzum__Amount__c, Zumzum__Sales_Credit__r.Zumzum__Sales_Invoice_to_Credit__c FROM Zumzum__Ledger_Payment_History__r)
            FROM Zumzum__Bank_Payment__c
            WHERE
                Id IN (
                    SELECT Zumzum__Bank_Payment__c
                    FROM Zumzum__Ledger_Payment_History__c
                    WHERE Zumzum__Sales_Credit__r.Zumzum__Sales_Invoice_to_Credit__c IN :salesInvoicesIds 
                )
        ];
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

    private static List<Zumzum__Ledger__c> getLedgers(Set<String> receiptIds, Set<Id> bankPaymentIds) {
        return [
            SELECT
                Zumzum__BankReconcile__c,
                Zumzum__Bank_Reconcile__c,
                Zumzum__Bank_Receipt__r.Payment__r.cpm__Payment_Reference__c,
                Zumzum__Bank_Receipt__c
            FROM Zumzum__Ledger__c
            WHERE
                (Zumzum__Bank_Receipt__r.Payment__r.cpm__Payment_Reference__c IN :receiptIds OR Zumzum__Bank_Payment__c IN :bankPaymentIds)
                AND Zumzum__Sub_Account_Nominal_Link__r.Zumzum__Account_Code__c = :BANK_NOMINAL_ACCOUNT_CODE
            WITH SECURITY_ENFORCED
        ];
    }

    private static Id getBankAccountIdByNominalAccountCode(Integer code) {
        Zumzum__Bank_Account__c bankAccount = [
            SELECT Name
            FROM Zumzum__Bank_Account__c
            WHERE Zumzum__Nominal_Account__r.Zumzum__Account_Code__c = :code
            LIMIT 1
        ];
        return bankAccount.Id;
    }

    private static Map<String, Id> getpaymentsBankReceiptsMap(List<Zumzum__Ledger__c> ledgers) {
        Map<String, Id> paymentsBankReceiptsMap = new Map<String, Id>();
        for (Zumzum__Ledger__c ledger : ledgers) {
            if (String.isNotBlank(ledger.Zumzum__Bank_Receipt__c)) {
                paymentsBankReceiptsMap.put(ledger.Zumzum__Bank_Receipt__r.Payment__r.cpm__Payment_Reference__c, ledger.Zumzum__Bank_Receipt__c);                
            }
        }
        return paymentsBankReceiptsMap;
    }
}
