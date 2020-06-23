@SuppressWarnings('PMD.ApexCRUDViolation')
//Incident #97 - https://confluence.nct.org.uk:8443/x/EoSO
public with sharing class ReconcilePaymentsBatchHelper {
    private static final String DRAFT_STATUS = 'Draft';
    private static final Integer BANK_NOMINAL_ACCOUNT_CODE = 9401;

    public static void processBatchReceiptReportItems(List<Batch_Receipt_Report_Item__c> receiptReportItems) {
        Batch_Receipt_Report__c receiptReport = getReceiptReportById(receiptReportItems[0].Batch_Receipt_Report__c);
        Zumzum__BankReconcile__c bankReconcile = getBankReconcile(receiptReport);

        Set<String> paymentReceiptReferences = new Set<String>();
        Set<String> refundReceiptReferences = new Set<String>();

        for (Batch_Receipt_Report_Item__c item : receiptReportItems) {
            if (item.Amount__c > 0) {
                paymentReceiptReferences.add(item.Payment_Id__c);
            } else if (item.Amount__c < 0) {
                refundReceiptReferences.add(item.Payment_Id__c);
            }
        }

        List<cpm__Payment__c> refundPayments = getRefundPaymentsByReference(refundReceiptReferences);
        Map<Id, cpm__Payment__c> salesInvoicesWithCreditsPayments = new Map<Id, cpm__Payment__c>();
        Map<String, Id> refundReferenceSalesInvoiceWithCreditIds = new Map<String, Id>();

        for (cpm__Payment__c payment : refundPayments) {
            salesInvoicesWithCreditsPayments.put(
                    payment.cpm__Installment__r.Sales_Invoice__c != null
                            ? payment.cpm__Installment__r.Sales_Invoice__c
                            : payment.cpm__Installment__r.cpm__Recurring_Payment__r.Sales_Invoice__c, payment
            );
            refundReferenceSalesInvoiceWithCreditIds.put(payment.cpm__Payment_Reference__c, payment.cpm__Installment__r.Sales_Invoice__c);
        }
        
        List<Zumzum__Bank_Payment__c> bankPaymentsForRefunds = getBankPaymentsBySalesCredits(salesInvoicesWithCreditsPayments.keySet());
        Map<Id, Id> salesCreditIdBankPaymentId = new Map<Id, Id>();
        
        for (Zumzum__Bank_Payment__c bankPayment : bankPaymentsForRefunds) {
            for (Zumzum__Ledger_Payment_History__c salesCreditAllocation : bankPayment.Zumzum__Ledger_Payment_History__r) {
                if (salesCreditAllocation.Zumzum__Amount__c == salesInvoicesWithCreditsPayments.get(salesCreditAllocation.Zumzum__Sales_Credit__r.Zumzum__Sales_Invoice_to_Credit__c).cpm__Amount__c) {
                    salesCreditIdBankPaymentId.put(salesCreditAllocation.Zumzum__Sales_Credit__r.Zumzum__Sales_Invoice_to_Credit__c, bankPayment.Id);
                }              
            }
        }

        List<Zumzum__Ledger__c> paymentAndRefundLedgers = getLedgers(paymentReceiptReferences, new Set<Id>(salesCreditIdBankPaymentId.values()));
        Map<String, Id> paymentsBankReceipts = getPaymentsBankReceipts(paymentAndRefundLedgers);

        for (Zumzum__Ledger__c ledger : paymentAndRefundLedgers) {
            ledger.Zumzum__BankReconcile__c = bankReconcile.Id;
            ledger.Zumzum__Bank_Reconcile__c = 'N';
        }
        update paymentAndRefundLedgers;

        for (Batch_Receipt_Report_Item__c reportItem : receiptReportItems) {
            if (reportItem.Amount__c > 0) {
                reportItem.Bank_Receipt__c = paymentsBankReceipts.get(reportItem.Payment_Id__c);
            } else if (reportItem.Amount__c < 0) {
                reportItem.Bank_Payment__c = salesCreditIdBankPaymentId.get(refundReferenceSalesInvoiceWithCreditIds.get(reportItem.Payment_Id__c));
            }
        }
        update receiptReportItems;

        receiptReport.BankReconcile__c = bankReconcile.Id;
        update receiptReport;
    }

    private static List<cpm__Payment__c> getRefundPaymentsByReference(Set<String> refundReceiptReferences) {
        return [
            SELECT 
                cpm__Amount__c, 
                cpm__Installment__c, 
                cpm__Installment__r.Sales_Invoice__c,
                cpm__Installment__r.cpm__Recurring_Payment__r.Sales_Invoice__c,
                cpm__Payment_Reference__c
            FROM cpm__Payment__c
            WHERE cpm__Payment_Reference__c IN :refundReceiptReferences
            WITH SECURITY_ENFORCED
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
            WITH SECURITY_ENFORCED
        ];
    }

    private static Batch_Receipt_Report__c getReceiptReportById(Id batchReceiptReportId) {
        return [
            SELECT Id, Status__c, Batch_Id__c, From_Date__c, To_Date__c
            FROM Batch_Receipt_Report__c
            WHERE Id = :batchReceiptReportId 
            WITH SECURITY_ENFORCED
            LIMIT 1
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

    private static List<Zumzum__Ledger__c> getLedgers(Set<String> paymentReceiptReferences, Set<Id> bankPaymentIds) {
        return [
            SELECT
                Zumzum__BankReconcile__c,
                Zumzum__Bank_Reconcile__c,
                Zumzum__Bank_Receipt__r.Payment__r.cpm__Payment_Reference__c,
                Zumzum__Bank_Receipt__c
            FROM Zumzum__Ledger__c
            WHERE
                (Zumzum__Bank_Receipt__r.Payment__r.cpm__Payment_Reference__c IN :paymentReceiptReferences OR Zumzum__Bank_Payment__c IN :bankPaymentIds)
                AND Zumzum__Sub_Account_Nominal_Link__r.Zumzum__Account_Code__c = :BANK_NOMINAL_ACCOUNT_CODE
            WITH SECURITY_ENFORCED
        ];
    }

    private static Id getBankAccountIdByNominalAccountCode(Integer code) {
        Zumzum__Bank_Account__c bankAccount = [
            SELECT Name
            FROM Zumzum__Bank_Account__c
            WHERE Zumzum__Nominal_Account__r.Zumzum__Account_Code__c = :code
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        return bankAccount.Id;
    }

    private static Map<String, Id> getPaymentsBankReceipts(List<Zumzum__Ledger__c> ledgers) {
        Map<String, Id> paymentsBankReceipts = new Map<String, Id>();
        for (Zumzum__Ledger__c ledger : ledgers) {
            if (String.isNotBlank(ledger.Zumzum__Bank_Receipt__c)) {
                paymentsBankReceipts.put(ledger.Zumzum__Bank_Receipt__r.Payment__r.cpm__Payment_Reference__c, ledger.Zumzum__Bank_Receipt__c);                
            }
        }
        return paymentsBankReceipts;
    }
}
