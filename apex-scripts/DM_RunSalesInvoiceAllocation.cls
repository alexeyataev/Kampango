Integer numberOfRowsToAllocate = 15000;

List<Zumzum__Sales_Invoice_Line_Item__c> siLineItems = [SELECT Id, Zumzum__Sales_Invoice__r.Zumzum__Account__c, Allocate_To__c
                                                        FROM Zumzum__Sales_Invoice_Line_Item__c
                                                        WHERE Allocate_To__c != NULL
                                                        AND Zumzum__Sales_Invoice__r.Zumzum__Total_Unpaid_Amount__c > 0
                                                        LIMIT :numberOfRowsToAllocate];

allocateSI(siLineItems);

void allocateSI(List<Zumzum__Sales_Invoice_Line_Item__c> siLineItems){
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
            SELECT Id, Name, Zumzum__Net_Amount__c, Zumzum__Gross__c, Zumzum__Sales_Invoice__r.Zumzum__Type__c,
                    Zumzum__Nominal_Name__c, Zumzum__Nominal__c, Zumzum__Sub_Account_Nominal_Link__c,
                    Zumzum__Sales_Invoice_Line_Item__c
            FROM Zumzum__Ledger__c
            WHERE Zumzum__Sales_Invoice_Line_Item__c IN :allLineItemIds
            AND Zumzum__Paid__c != 'Y'
            AND Zumzum__Customer_Supplier_Account_Name__c != null
    ];

    for(Zumzum__Ledger__c ledgerRec : ledgerRecords){
        siLedgerMap.put(ledgerRec.Zumzum__Sales_Invoice_Line_Item__c, ledgerRec);
    }
    Zumzum.BankAllocateCreditsAndPaymentsService paymentService = new Zumzum.BankAllocateCreditsAndPaymentsService();
    
    Set<Id> processedLedgerIds = new Set<Id>();
    
    for(Zumzum__Sales_Invoice_Line_Item__c siLine : siLineItems) {
        String customerAcctId = siLineItemMap.get(siLine.Id).Zumzum__Sales_Invoice__r.Zumzum__Account__c;
        Zumzum__Ledger__c ledgerAllocateFrom = siLedgerMap.get(siLine.Id);
        Zumzum__Ledger__c ledgerAllocateTo = siLedgerMap.get(siAllocateIdMap.get(siLine.Id));

        if(ledgerAllocateFrom == null || ledgerAllocateTo == null || processedLedgerIds.contains(ledgerAllocateFrom.Id) || processedLedgerIds.contains(ledgerAllocateTo.Id))
        {
            continue;
        }
        
        processedLedgerIds.addAll(new Set<Id>{ledgerAllocateFrom.Id, ledgerAllocateTo.Id});

        Zumzum.BankAllocateCreditsAndPaymentsService.BankAllocateCreditsAndPaymentsWrapper allocatedPaymentWrapper =
                new Zumzum.BankAllocateCreditsAndPaymentsService.BankAllocateCreditsAndPaymentsWrapper();

        allocatedPaymentWrapper.AccountId = customerAcctId;
        allocatedPaymentWrapper.PostingDate = Date.today();

        List<Zumzum.BankAllocateCreditsAndPaymentsService.BankAllocateCreditsAndPaymentsLineWrapper> paymentLines = new List<Zumzum.BankAllocateCreditsAndPaymentsService.BankAllocateCreditsAndPaymentsLineWrapper>();
        Zumzum.BankAllocateCreditsAndPaymentsService.BankAllocateCreditsAndPaymentsLineWrapper bankLineItem;
        
        Decimal amountToAllocate = ledgerAllocateFrom.Zumzum__Gross__c > ledgerAllocateTo.Zumzum__Gross__c ? ledgerAllocateTo.Zumzum__Gross__c : ledgerAllocateFrom.Zumzum__Gross__c;

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