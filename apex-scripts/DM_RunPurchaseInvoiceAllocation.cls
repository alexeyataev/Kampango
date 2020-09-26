Integer numberOfRowsToAllocate = 15000;

List<Zumzum__Purchase_Invoice_Line_Item__c> piLineItems = [SELECT Id, Zumzum__Purchase_Invoice__r.Zumzum__Account__c, Allocate_To__c
                                                            FROM Zumzum__Purchase_Invoice_Line_Item__c
                                                            WHERE Allocate_To__c != NULL
                                                            AND Zumzum__Purchase_Invoice__r.Zumzum__Total_Unpaid_Amount__c > 0
                                                            LIMIT :numberOfRowsToAllocate];

allocatePI(piLineItems);

void allocatePI(List<Zumzum__Purchase_Invoice_Line_Item__c> piLineItems){
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
            SELECT Id, Name, Zumzum__Net_Amount__c, Zumzum__Gross__c, Zumzum__Purchase_Invoice__r.Zumzum__Type__c,
                    Zumzum__Nominal_Name__c, Zumzum__Nominal__c, Zumzum__Sub_Account_Nominal_Link__c,
                    Zumzum__Purchase_Invoice_Line_Item__c
            FROM Zumzum__Ledger__c
            WHERE Zumzum__Purchase_Invoice_Line_Item__c IN :allLineItemIds
            AND Zumzum__Paid__c != 'Y'
            AND Zumzum__Customer_Supplier_Account_Name__c != null
    ];

    for(Zumzum__Ledger__c ledgerRec : ledgerRecords){
        piLedgerMap.put(ledgerRec.Zumzum__Purchase_Invoice_Line_Item__c, ledgerRec);
    }
    Zumzum.BankAllocateCreditsAndPaymentsService paymentService = new Zumzum.BankAllocateCreditsAndPaymentsService();

    Set<Id> processedLedgerIds = new Set<Id>();

    for(Zumzum__Purchase_Invoice_Line_Item__c piLine : piLineItems) {
        String customerAcctId = piLineItemMap.get(piLine.Id).Zumzum__Purchase_Invoice__r.Zumzum__Account__c;
        Zumzum__Ledger__c ledgerAllocateFrom = piLedgerMap.get(piLine.Id);
        Zumzum__Ledger__c ledgerAllocateTo = piLedgerMap.get(piAllocateIdMap.get(piLine.Id));

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
        bankLineItem.LedgerName = LedgerAllocateTo.Name;
        bankLineItem.Amount = amountToAllocate;
        paymentLines.add(bankLineItem);

        allocatedPaymentWrapper.BankAllocateLines = paymentLines;
        allocatePaymentsWrapperList.add(allocatedPaymentWrapper);
    }
    Zumzum.BankAllocateCreditsAndPaymentsService.Response objResponse
            = paymentService.bankAllocateSupplierBalance(allocatePaymentsWrapperList);

}