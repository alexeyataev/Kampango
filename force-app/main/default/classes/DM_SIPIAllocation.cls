/**
 * Script to Allocate payments on Sales and Purchase
 */

public with sharing class DM_SIPIAllocation {
    public static void allocateSI(List<Zumzum__Sales_Invoice_Line_Item__c> siLineItems){
        Set<Id> allocateToLineItemIds = new Set<Id>();
        Set<Id> siLineItemIds = new Set<Id>();
        Set<Id> allLineItemIds = new Set<Id>();
        Map<Id,Id> siAllocateIdMap = new Map<Id,Id>();
        Map<Id,Zumzum__Ledger__c> siLedgerMap = new Map<Id,Zumzum__Ledger__c>();
        Map<Id,Zumzum__Sales_Invoice_Line_Item__c> siLineItemMap = new Map<Id,Zumzum__Sales_Invoice_Line_Item__c>();
        List<Zumzum.BankAllocateCreditsAndPaymentsService.BankAllocateCreditsAndPaymentsWrapper> allocatePaymentsWrapperList
                = new List<Zumzum.BankAllocateCreditsAndPaymentsService.BankAllocateCreditsAndPaymentsWrapper>();
        for(Zumzum__Sales_Invoice_Line_Item__c siLine : siLineItems){
            siLineItemIds.add(siLine.Id);
            allocateToLineItemIds.add(siLine.Allocate_To__c);
            siAllocateIdMap.put(siLine.Id, siLine.Allocate_To__c);
            siLineItemMap.put(siLine.Id, siLine);
        }
        allLineItemIds.addAll(siLineItemIds);
        allLineItemIds.addAll(allocateToLineItemIds);

        List<Zumzum__Ledger__c> ledgerRecords = [
                SELECT Id, Name, Zumzum__Net_Amount__c, Zumzum__Sales_Invoice__r.Zumzum__Type__c,
                        Zumzum__Nominal_Name__c, Zumzum__Nominal__c, Zumzum__Sub_Account_Nominal_Link__c,
                        Zumzum__Sales_Invoice_Line_Item__c
                FROM Zumzum__Ledger__c
                WHERE Zumzum__Sales_Invoice_Line_Item__c IN :allLineItemIds
                AND Zumzum__Customer_Supplier_Account_Name__c != null
        ];

        for(Zumzum__Ledger__c ledgerRec : ledgerRecords){
            siLedgerMap.put(ledgerRec.Zumzum__Sales_Invoice_Line_Item__c, ledgerRec);
        }
        Zumzum.BankAllocateCreditsAndPaymentsService paymentService = new Zumzum.BankAllocateCreditsAndPaymentsService();
        for(Zumzum__Sales_Invoice_Line_Item__c siLine : siLineItems) {
            String customerAcctId = siLineItemMap.get(siLine.Id).Zumzum__Sales_Invoice__r.Zumzum__Account__c;
            Zumzum__Ledger__c ledgerAllocateFrom = siLedgerMap.get(siLine.Id);
            Zumzum__Ledger__c ledgerAllocateTo = siLedgerMap.get(siAllocateIdMap.get(siLine.Id));


            Zumzum.BankAllocateCreditsAndPaymentsService.BankAllocateCreditsAndPaymentsWrapper allocatedPaymentWrapper =
                    new Zumzum.BankAllocateCreditsAndPaymentsService.BankAllocateCreditsAndPaymentsWrapper();

            allocatedPaymentWrapper.AccountId = customerAcctId;
            allocatedPaymentWrapper.PostingDate = Date.today();

            List<Zumzum.BankAllocateCreditsAndPaymentsService.BankAllocateCreditsAndPaymentsLineWrapper> paymentLines = new List<Zumzum.BankAllocateCreditsAndPaymentsService.BankAllocateCreditsAndPaymentsLineWrapper>();
            Zumzum.BankAllocateCreditsAndPaymentsService.BankAllocateCreditsAndPaymentsLineWrapper bankLineItem;

            Decimal amountToAllocate = ledgerAllocateFrom.Zumzum__Net_Amount__c > ledgerAllocateTo.Zumzum__Net_Amount__c ? ledgerAllocateTo.Zumzum__Net_Amount__c : ledgerAllocateFrom.Zumzum__Net_Amount__c;

            bankLineItem = new Zumzum.BankAllocateCreditsAndPaymentsService.BankAllocateCreditsAndPaymentsLineWrapper();
            bankLineItem.LedgerName = ledgerAllocateFrom.Name;
            bankLineItem.Amount = amountToAllocate;
            paymentLines.add(bankLineItem);

            bankLineItem = new Zumzum.BankAllocateCreditsAndPaymentsService.BankAllocateCreditsAndPaymentsLineWrapper();
            bankLineItem.LedgerName = ledgerAllocateTo.Name;
            bankLineItem.Amount = amountToAllocate;
            paymentLines.add(bankLineItem);

            allocatedPaymentWrapper.BankAllocateLines = paymentLines;
            allocatePaymentsWrapperList.add(allocatedPaymentWrapper);
        }
        Zumzum.BankAllocateCreditsAndPaymentsService.Response objResponse
                = paymentService.BankAllocateCustomerBalance(allocatePaymentsWrapperList);

    }

    public static void allocatePI(List<Zumzum__Purchase_Invoice_Line_Item__c> piLineItems){
        Set<Id> allocateToLineItemIds = new Set<Id>();
        Set<Id> piLineItemIds = new Set<Id>();
        Set<Id> allLineItemIds = new Set<Id>();
        Map<Id,Id> piAllocateIdMap = new Map<Id,Id>();
        Map<Id,Zumzum__Ledger__c> piLedgerMap = new Map<Id,Zumzum__Ledger__c>();
        Map<Id,Zumzum__Purchase_Invoice_Line_Item__c> piLineItemMap = new Map<Id,Zumzum__Purchase_Invoice_Line_Item__c>();
        List<Zumzum.BankAllocateCreditsAndPaymentsService.BankAllocateCreditsAndPaymentsWrapper> allocatePaymentsWrapperList
                = new List<Zumzum.BankAllocateCreditsAndPaymentsService.BankAllocateCreditsAndPaymentsWrapper>();
        for(Zumzum__Purchase_Invoice_Line_Item__c piLine : piLineItems){
            piLineItemIds.add(piLine.Id);
            allocateToLineItemIds.add(piLine.Allocate_To__c);
            piAllocateIdMap.put(piLine.Id, piLine.Allocate_To__c);
            piLineItemMap.put(piLine.Id, piLine);
        }
        allLineItemIds.addAll(piLineItemIds);
        allLineItemIds.addAll(allocateToLineItemIds);

        List<Zumzum__Ledger__c> ledgerRecords = [
                SELECT Id, Name, Zumzum__Net_Amount__c, Zumzum__Purchase_Invoice__r.Zumzum__Type__c,
                        Zumzum__Nominal_Name__c, Zumzum__Nominal__c, Zumzum__Sub_Account_Nominal_Link__c,
                        Zumzum__Purchase_Invoice_Line_Item__c
                FROM Zumzum__Ledger__c
                WHERE Zumzum__Purchase_Invoice_Line_Item__c IN :allLineItemIds
                AND Zumzum__Customer_Supplier_Account_Name__c != null
        ];

        for(Zumzum__Ledger__c ledgerRec : ledgerRecords){
            piLedgerMap.put(ledgerRec.Zumzum__Purchase_Invoice_Line_Item__c, ledgerRec);
        }
        Zumzum.BankAllocateCreditsAndPaymentsService paymentService = new Zumzum.BankAllocateCreditsAndPaymentsService();
        for(Zumzum__Purchase_Invoice_Line_Item__c piLine : piLineItems) {
            String customerAcctId = piLineItemMap.get(piLine.Id).Zumzum__Purchase_Invoice__r.Zumzum__Account__c;
            Zumzum__Ledger__c ledgerAllocateFrom = piLedgerMap.get(piLine.Id);
            Zumzum__Ledger__c ledgerAllocateTo = piLedgerMap.get(piAllocateIdMap.get(piLine.Id));

            Zumzum.BankAllocateCreditsAndPaymentsService.BankAllocateCreditsAndPaymentsWrapper allocatedPaymentWrapper =
                    new Zumzum.BankAllocateCreditsAndPaymentsService.BankAllocateCreditsAndPaymentsWrapper();

            allocatedPaymentWrapper.AccountId = customerAcctId;
            allocatedPaymentWrapper.PostingDate = Date.today();

            List<Zumzum.BankAllocateCreditsAndPaymentsService.BankAllocateCreditsAndPaymentsLineWrapper> paymentLines = new List<Zumzum.BankAllocateCreditsAndPaymentsService.BankAllocateCreditsAndPaymentsLineWrapper>();
            Zumzum.BankAllocateCreditsAndPaymentsService.BankAllocateCreditsAndPaymentsLineWrapper bankLineItem;

            bankLineItem = new Zumzum.BankAllocateCreditsAndPaymentsService.BankAllocateCreditsAndPaymentsLineWrapper();
            bankLineItem.LedgerName = ledgerAllocateFrom.Name;
            bankLineItem.Amount = ledgerAllocateFrom.Zumzum__Net_Amount__c;
            paymentLines.add(bankLineItem);

            bankLineItem = new Zumzum.BankAllocateCreditsAndPaymentsService.BankAllocateCreditsAndPaymentsLineWrapper();
            bankLineItem.LedgerName = LedgerAllocateTo.Name;
            bankLineItem.Amount = ledgerAllocateTo.Zumzum__Net_Amount__c;
            paymentLines.add(bankLineItem);

            allocatedPaymentWrapper.BankAllocateLines = paymentLines;
            allocatePaymentsWrapperList.add(allocatedPaymentWrapper);
        }
        Zumzum.BankAllocateCreditsAndPaymentsService.Response objResponse
                = paymentService.bankAllocateSupplierBalance(allocatePaymentsWrapperList);

    }
}