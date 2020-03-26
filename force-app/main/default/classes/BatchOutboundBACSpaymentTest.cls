@isTest
private class BatchOutboundBACSpaymentTest {


    @isTest
    static void runTest(){
        TestFinanceDataFactory.getInstance().createZumzumData();

        Zumzum__Nominal_Account__c zumzumCurrentNominalAccount = new Zumzum__Nominal_Account__c(
            Name = 'Bank Current Account',
            Zumzum__Account_Code__c = 9600
        );
        insert zumzumCurrentNominalAccount;
        
        Zumzum__Bank_Account__c zumzumBankAccount = new Zumzum__Bank_Account__c(
            Name = 'BACS Payments in Transit',
            Zumzum__Type__c = 'Current/Saving',
            Zumzum__Account_Number__c = '2',
            Zumzum__Status__c = 'Active',
            Zumzum__Nominal_Account__c = zumzumCurrentNominalAccount.Id
        );
        insert zumzumBankAccount;

        TestAccountBuilder accountBuilder = new TestAccountBuilder();
        Account supplierAccount = accountBuilder.WithRecordType('Organization')
                .withName('Tom Genet')
                .withType('Supplier')
                .withAccountNumber('869344')
                .withBillingEmail('tets@gmail.com')
                .withBankSortCode('572899')
                .withBankAccountNumber('03456123')
                .withBankAccountName('TEST BANK ACCOUNT')
                .insertRecord(true)
                .build();       

        createPI(supplierAccount.Id);
        test();
    }

    static void test(){       
        // 1. Create PI and related PILI
        //ClaimFeeHelper.createPurchaseInvoice(flowData);

        //2. Create Payment run
        Payment_Run__c paymentRun = new Payment_Run__c();
        paymentRun.Status__c = 'Draft';
        insert paymentRun;

        //3. Link PI to Payment run
        ZumzumBACSpaymentActions.Request request = new ZumzumBACSpaymentActions.Request();
        List<ZumzumBACSpaymentActions.Request> requests = new List<ZumzumBACSpaymentActions.Request>();
        requests.add(request);
        request.recordId =  paymentRun.Id;
        System.debug(JSON.serialize(ZumzumBACSpaymentActions.linkPurchaseInvoices(requests))) ;

        //4. Run Batch
        paymentRun.Status__c = 'Processing';
        update paymentRun;
        List<Id> ids = new List<Id>();
        ids.add(paymentRun.Id);

        Test.startTest();
            BatchOutboundBACSpayment.runBatch(ids);
        Test.stopTest();
    }

    static void createPI(Id supplierAccountId){
        final String PURCHASE_INVOICE = 'Purchase Invoice';
        final String PURCHASE_CREDIT = 'Purchase Credit';
        final String DEFAULT_CURRENCY = 'GBP';
        final String PRACTITIONER_TAX_RATE = 'No VAT';
        final String API_SUCCESS_MESSAGE = 'Success';
        final String LINKING_ERROR_EMAIL_TEMPLATE = 'Practitioner_Registration_Fee_Claim_Error';
        final String TEMPLATE_PC = '{!PC}';
        final String TEMPLATE_PI = '{!PI}';
        final String DEFAULT_NARRATIVE = 'Fee Claim';
        Map<String, String> statusInvoiceMap;

        Zumzum__Currency__c zumzumCurrency = [
            SELECT Id
            FROM Zumzum__Currency__c 
            WHERE Name =: DEFAULT_CURRENCY
            WITH SECURITY_ENFORCED
        ];

        Zumzum__Tax_Rate__c zumzumNoVAT = [
            SELECT Id, Name 
            FROM Zumzum__Tax_Rate__c 
            WHERE Name =: PRACTITIONER_TAX_RATE
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        Financial_Settings__c financialSettings = Financial_Settings__c.getInstance();

        Zumzum.PurchaseInvoiceService purchaseInvoiceService = new Zumzum.PurchaseInvoiceService();
        List<Zumzum.PurchaseInvoiceService.PurchaseInvoiceWrapper> purchases = new List<Zumzum.PurchaseInvoiceService.PurchaseInvoiceWrapper>();
        
        //Purchase Invoice
        Zumzum.PurchaseInvoiceService.PurchaseInvoiceWrapper purchaseInvoice = new Zumzum.PurchaseInvoiceService.PurchaseInvoiceWrapper();
        Zumzum.PurchaseInvoiceService.PurchaseInvoiceLineWrapper purchaseInvoiceLineItem;

        purchaseInvoice.InvoiceDate = Date.today();
        purchaseInvoice.InvoiceDueDate = Date.today();
        purchaseInvoice.SupplierAccount = supplierAccountId;// currentUser.AccountId;
        purchaseInvoice.TransactionCurrency = zumzumCurrency.Id;
        purchaseInvoice.PurchaseInvoiceType = PURCHASE_INVOICE;
        purchaseInvoice.LineItems = new List<Zumzum.PurchaseInvoiceService.PurchaseInvoiceLineWrapper>();
        
        purchaseInvoiceLineItem = new Zumzum.PurchaseInvoiceService.PurchaseInvoiceLineWrapper();
        purchaseInvoiceLineItem.NominalAccount = financialSettings.PI_Nominal_Account_Id__c;
        purchaseInvoiceLineItem.ForeignNetAmount = 100;
        purchaseInvoiceLineItem.Quantity = 1;
        purchaseInvoiceLineItem.TaxRate = zumzumNoVAT.Id;
        purchaseInvoiceLineItem.Narrative = DEFAULT_NARRATIVE;
        purchaseInvoiceLineItem.Dimension1 = null;
        purchaseInvoiceLineItem.Dimension2 = null;

        purchaseInvoice.LineItems.add(purchaseInvoiceLineItem);
        purchases.add(purchaseInvoice);   

        Zumzum.PurchaseInvoiceService.Response objResponse = purchaseInvoiceService.createPurchaseInvoices(purchases);

        postPurchaseInvoices(objResponse.purchaseInvoices);        
    }

    static void postPurchaseInvoices(List<Zumzum__Purchase_Invoice__c> invoices) {
        Zumzum.PurchaseInvoiceService postService = new Zumzum.PurchaseInvoiceService();
        for (Zumzum__Purchase_Invoice__c pi : invoices) {
            Zumzum.PurchaseInvoiceService.Response apiResponse = postService.postPurchaseInvoice(pi.Id);
        }
    }
}