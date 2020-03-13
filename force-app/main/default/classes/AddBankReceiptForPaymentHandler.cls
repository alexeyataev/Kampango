public with sharing class AddBankReceiptForPaymentHandler {
    private static final String DEBTOR_NOMINAL_CODE = '9300';
    private static final String MEMBERSHIP_NOMINAL_CODE = '1003';
    private static final String SALES_INVOICE_STATUS = 'Posted';
    private static final String IS_PAID = 'Y';
    private static final Id BANK_ACCOUNT_ID = Bank_Account_Settings__c.getOrgDefaults().Worldpay_Bank_Account_Id__c;

    public static void addBankReceipts(List<cpm__Payment__c> payments) {
        try {
            if (String.isBlank(BANK_ACCOUNT_ID)) {
                throw new ListException('Set Bank Account Id custom setting');
            }

            Zumzum.BankCustomerReceiptService bankCustomerReceiptService = new Zumzum.BankCustomerReceiptService();
            Zumzum.BankCustomerReceiptService.BankCustomerReceiptWrapper receiptWrapper = new Zumzum.BankCustomerReceiptService.BankCustomerReceiptWrapper();
            Map<Id, List<cpm__Payment__c>> salesInvoicesPaymentsMap = new Map<Id, List<cpm__Payment__c>>();

            for (cpm__Payment__c payment : payments) {
                if (payment.cpm__Installment__r.Sales_Invoice__c != null) {
                    if (salesInvoicesPaymentsMap.containsKey(payment.cpm__Installment__r.Sales_Invoice__c)) {
                        salesInvoicesPaymentsMap.get(payment.cpm__Installment__r.Sales_Invoice__c).add(payment);
                    } else {
                        salesInvoicesPaymentsMap.put(payment.cpm__Installment__r.Sales_Invoice__c, new List<cpm__Payment__c>{payment});
                    }
                } else if (payment.cpm__Installment__r.cpm__Recurring_Payment__r.Sales_Invoice__c <> null) {
                    if (salesInvoicesPaymentsMap.containsKey(payment.cpm__Installment__r.cpm__Recurring_Payment__r.Sales_Invoice__c)) {
                        salesInvoicesPaymentsMap.get(payment.cpm__Installment__r.cpm__Recurring_Payment__r.Sales_Invoice__c).add(payment);
                    } else {
                        salesInvoicesPaymentsMap.put(payment.cpm__Installment__r.cpm__Recurring_Payment__r.Sales_Invoice__c, new List<cpm__Payment__c>{payment});
                    }
                }
            }

            for (Zumzum__Sales_Invoice__c salesInvoice : [
                    SELECT Zumzum__Account__c, (
                            SELECT Name,
                                   Zumzum__Debit__c,
                                   Zumzum__Sub_Account_Nominal__c,
                                   Zumzum__Sales_Invoice_Line_Item__c,
                                   Zumzum__Sales_Invoice_Line_Item__r.Zumzum__Nominal_Account__r.Zumzum__Nominal_Code__c
                            FROM Zumzum__Ledger__r
                            WHERE Zumzum__Sub_Account_Nominal__c = :DEBTOR_NOMINAL_CODE AND Zumzum__Paid__c <> :IS_PAID
                    )
                    FROM Zumzum__Sales_Invoice__c
                    WHERE Id IN :salesInvoicesPaymentsMap.keySet() AND Zumzum__Status__c = :SALES_INVOICE_STATUS AND Zumzum__Paid__c <> :IS_PAID
                    WITH SECURITY_ENFORCED
            ]) {
                for (cpm__Payment__c payment : salesInvoicesPaymentsMap.get(salesInvoice.Id)) {
                    receiptWrapper.AccountId = salesInvoice.Zumzum__Account__c;
                    receiptWrapper.BankAccountId = BANK_ACCOUNT_ID;
                    receiptWrapper.PostingDate = Date.Today();
                    receiptWrapper.WrapperAPICustomFields = new List<Zumzum.APICustomFieldWrapper>();
                    receiptWrapper.WrapperAPICustomFields.add(new Zumzum.APICustomFieldWrapper('Zumzum__Bank_Receipt__c', 'Payment__c', payment.Id));
                    receiptWrapper.BankReceiptLines = createBankReceiptLines(payment, salesInvoice);
                    Zumzum.BankCustomerReceiptService.Response response = bankCustomerReceiptService.CreateBankCustomerReceipt(receiptWrapper);
                }
            }
        } catch(Exception e) {
            System.debug(e.getMessage());
        }
    }

    private static List<Zumzum.BankCustomerReceiptService.BankReceiptLine> createBankReceiptLines(cpm__Payment__c payment, Zumzum__Sales_Invoice__c salesInvoice) {
        List<Zumzum.BankCustomerReceiptService.BankReceiptLine> listBankReceiptLines = new List<Zumzum.BankCustomerReceiptService.BankReceiptLine>();
        Zumzum.BankCustomerReceiptService.BankReceiptLine courseBankReceiptLine = new Zumzum.BankCustomerReceiptService.BankReceiptLine();
        if (salesInvoice.Zumzum__Ledger__r.size() > 1) {
            Zumzum.BankCustomerReceiptService.BankReceiptLine membershipBankReceiptLine = new Zumzum.BankCustomerReceiptService.BankReceiptLine();
            for (Zumzum__Ledger__c ledger : salesInvoice.Zumzum__Ledger__r) {
                if (ledger.Zumzum__Sales_Invoice_Line_Item__r.Zumzum__Nominal_Account__r.Zumzum__Nominal_Code__c == MEMBERSHIP_NOMINAL_CODE) {
                    membershipBankReceiptLine.Amount = ledger.Zumzum__Debit__c;
                    membershipBankReceiptLine.LedgerName = ledger.Name;
                } else {
                    courseBankReceiptLine.LedgerName = ledger.Name;
                }                
            }
            courseBankReceiptLine.Amount = payment.cpm__Amount__c - membershipBankReceiptLine.Amount;
            listBankReceiptLines.add(membershipBankReceiptLine);
            listBankReceiptLines.add(courseBankReceiptLine);
        } else {
            courseBankReceiptLine.Amount = payment.cpm__Amount__c;
            courseBankReceiptLine.LedgerName = salesInvoice.Zumzum__Ledger__r[0].Name;
            listBankReceiptLines.add(courseBankReceiptLine);
        }
        return listBankReceiptLines;
    }
}
