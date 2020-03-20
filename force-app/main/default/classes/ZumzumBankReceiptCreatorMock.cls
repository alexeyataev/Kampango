@SuppressWarnings('PMD.ApexCRUDViolation')
//Incident #58 - https://confluence.nct.org.uk:8443/x/EoSO
public with sharing class ZumzumBankReceiptCreatorMock implements IBankReceiptCreator {
    public static void createBankReceipt(Zumzum.BankCustomerReceiptService.BankCustomerReceiptWrapper receiptWrapper) {
        Zumzum__Bank_Receipt__c bankReceipt = new Zumzum__Bank_Receipt__c();
        Zumzum__Batch_Bank_Receipt__c batchBankReceipt = new Zumzum__Batch_Bank_Receipt__c();
        Zumzum__Currency__c zumzumCurrency = [SELECT Id FROM Zumzum__Currency__c LIMIT 1];
        Zumzum__Company__c company = [SELECT Id FROM Zumzum__Company__c LIMIT 1];
        Zumzum__Tax_Rate__c zumzumTaxRate  = [SELECT Id FROM Zumzum__Tax_Rate__c LIMIT 1];
        List<Zumzum__Bank_Receipt_Line_Item__c> bankReceiptLineItemList = new List<Zumzum__Bank_Receipt_Line_Item__c>();
        Map<String, Zumzum__Bank_Receipt_Line_Item__c> legerNameBankReceiptLineItemMap = new Map<String, Zumzum__Bank_Receipt_Line_Item__c>();
        Decimal bankReceiptAmount = 0;
        
        for (Zumzum.BankCustomerReceiptService.BankReceiptLine bankReceiptLineItemFromWrapper : receiptWrapper.BankReceiptLines) {
            Zumzum__Bank_Receipt_Line_Item__c bankReceiptLineItemToCreate = new Zumzum__Bank_Receipt_Line_Item__c();
            bankReceiptLineItemToCreate.Zumzum__Amount__c = bankReceiptLineItemFromWrapper.Amount;
            bankReceiptLineItemToCreate.Zumzum__Date__c = Date.today();
            bankReceiptLineItemToCreate.Zumzum__Status__c = 'Posted';
            bankReceiptLineItemToCreate.Zumzum__Tax__c = zumzumTaxRate.Id;
            bankReceiptLineItemToCreate.Zumzum__Company__c = company.Id;
            bankReceiptLineItemToCreate.Zumzum__Company_Currency__c = zumzumCurrency.Id;
            bankReceiptLineItemToCreate.Zumzum__Corporate_Currency__c = zumzumCurrency.Id;
            bankReceiptLineItemToCreate.Zumzum__Transaction_Currency__c = zumzumCurrency.Id;
            bankReceiptLineItemToCreate.Zumzum__Company_To_Corporate_Rate__c = 1.00000000;
            bankReceiptLineItemToCreate.Zumzum__Foreign_Currency_Rate__c = 1.00000000;
            bankReceiptLineItemList.add(bankReceiptLineItemToCreate);
            bankReceiptAmount += bankReceiptLineItemFromWrapper.Amount;
            legerNameBankReceiptLineItemMap.put(bankReceiptLineItemFromWrapper.LedgerName, bankReceiptLineItemToCreate);
        }

        batchBankReceipt.Zumzum__Bank__c = receiptWrapper.BankAccountId;
        batchBankReceipt.Zumzum__Status__c = 'Posted';
        batchBankReceipt.Zumzum__Company__c = company.Id;
        batchBankReceipt.Zumzum__Company_Currency__c = zumzumCurrency.Id;
        batchBankReceipt.Zumzum__Corporate_Currency__c = zumzumCurrency.Id;
        batchBankReceipt.Zumzum__Transaction_Currency__c = zumzumCurrency.Id;
        batchBankReceipt.Zumzum__Company_To_Corporate_Rate__c = 1.00000000;
        batchBankReceipt.Zumzum__Foreign_Currency_Rate__c = 1.00000000;
        insert batchBankReceipt;

        bankReceipt.Zumzum__Amount__c = bankReceiptAmount;
        bankReceipt.Zumzum__Company_Amount__c = bankReceiptAmount;
        bankReceipt.Zumzum__Foreign_Amount__c = bankReceiptAmount;
        bankReceipt.Zumzum__Bank__c = receiptWrapper.BankAccountId;
        bankReceipt.Zumzum__Batch_Bank_Receipt__c = batchBankReceipt.Id;
        bankReceipt.Payment__c = receiptWrapper.WrapperAPICustomFields[0].fieldValue;
        bankReceipt.Zumzum__Customer__c = receiptWrapper.AccountId;
        bankReceipt.Zumzum__Date__c = Date.today();
        bankReceipt.Zumzum__Status__c = 'Posted';
        bankReceipt.Zumzum__Company_Currency__c = zumzumCurrency.Id;
        bankReceipt.Zumzum__Corporate_Currency__c = zumzumCurrency.Id;
        bankReceipt.Zumzum__Transaction_Currency__c = zumzumCurrency.Id;
        bankReceipt.Zumzum__Company__c = company.Id;
        bankReceipt.Zumzum__Company_To_Corporate_Rate__c = 1.00000000;
        bankReceipt.Zumzum__Foreign_Currency_Rate__c = 1.00000000;
        insert bankReceipt;
        
        List<Zumzum__Ledger__c> ledgersToUpdate = [SELECT Name, Zumzum__Debit__c, Zumzum__Paid__c, Zumzum__Sales_Invoice__c, Zumzum__Sales_Invoice_Line_Item__c FROM Zumzum__Ledger__c WHERE Name IN :legerNameBankReceiptLineItemMap.Keyset()];
        for (Zumzum__Ledger__c ledger : ledgersToUpdate) {
            if (!(legerNameBankReceiptLineItemMap.get(ledger.Name).Zumzum__Amount__c < ledger.Zumzum__Debit__c)) {
                ledger.Zumzum__Paid__c = 'Y';
            }
            legerNameBankReceiptLineItemMap.get(ledger.Name).Zumzum__Bank_Receipt__c = bankReceipt.Id;
            legerNameBankReceiptLineItemMap.get(ledger.Name).Zumzum__Sales_Invoice__c = ledger.Zumzum__Sales_Invoice__c;
            legerNameBankReceiptLineItemMap.get(ledger.Name).Zumzum__Sales_Invoice_Line_Item__c = ledger.Zumzum__Sales_Invoice_Line_Item__c;
        }
        insert bankReceiptLineItemList;
        update ledgersToUpdate;
    }
}