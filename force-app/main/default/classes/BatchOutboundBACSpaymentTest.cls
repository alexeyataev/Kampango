@isTest
private class BatchOutboundBACSpaymentTest {
    private static final String OWA_VALUE = 'nctcourses@nct.org.uk';
    private static final String CONTACT_EMAIL = 'john.black@example.com';
    private static final String TEMPLATE_NAME = 'test';
    private static final String TEMPLATE_DEV_NAME = 'temp';       

    static void setupTestData(){
        Id folderId = [SELECT Id FROM Folder WHERE Type = 'Email' LIMIT 1].Id;
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs ( thisUser ) {
            EmailTemplate template = new EmailTemplate(
                DeveloperName = TEMPLATE_DEV_NAME,
                FolderId = folderId,
                TemplateType= 'custom', 
                Name = TEMPLATE_NAME,
                IsActive = true
            );
            insert template;
        }

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
        Account account = accountBuilder
                .withRecordType('Household Account')
                .withBranchNumber('777')
                .insertRecord(true)
                .build();
        TestContactBuilder contactBuilder = new TestContactBuilder();
        Contact contact = contactBuilder
            .withRecordType('Client')
            .withAccount(account)
            .withFirstName('John')
            .withLastName('Smith')
            .withNctNumber('123123')
            .insertRecord(true)
            .build();

        TestPurchaseInvoiceBuilder purchaseInvoiceBuilder = new TestPurchaseInvoiceBuilder();
        Zumzum__Purchase_Invoice__c pi1 = purchaseInvoiceBuilder
                .withStatus('Posted')
                .withAccount(supplierAccount.Id)
                .withContact(contact.Id)
                .withDueDate(Date.today().addDays(20))
                .withInvoiceDate(Date.today())
                .insertRecord(true)
                .build();
        TestPurchaseInvoiceLineItemBuilder purchaseInvoiceLineItemBuilder = new TestPurchaseInvoiceLineItemBuilder();
        Zumzum__Purchase_Invoice_Line_Item__c purchaseInvoiceLineItems = purchaseInvoiceLineItemBuilder
                .withAmount(120)
                .withGross(120)
                .withGross(120)
                .withNet(120)
                .withNarrative('Doll')
                .withQuantity(1)
                .withPurchaseInvoice(pi1.Id)
                .insertRecord(true)
                .build();
        
        TestPaymentRunBuilder paymentRunBuilder = new TestPaymentRunBuilder();
        Payment_Run__c pr1 = paymentRunBuilder
            .insertLineItem(pi1.Id, true)
            .insertLineItem(pi1.Id)
            .build();

        Payment_Run__c pr2 = paymentRunBuilder
            .insertLineItem(pi1.Id)
            .insertLineItem(pi1.Id)
            .build();        
    }   
    
    @isTest
    static void performTest(){
        ZumzumBACSremittanceEmailsActionTest.setup();
        Payment_Run__c paymentRun = [
            SELECT Id, Status__c,
                (
                    SELECT Purchase_Invoice__c
                    FROM Payment_Run_Line_Items__r
                )
            FROM Payment_Run__c
            LIMIT 1
        ];

        Set<Id> purchaseInvoiceIds = new Set<Id>();
        for (Payment_Run_Line_Item__c p: paymentRun.Payment_Run_Line_Items__r){
            purchaseInvoiceIds.add(p.Purchase_Invoice__c);
        }

        List<Zumzum__Purchase_Invoice__c> invoices = [
            SELECT Id, Zumzum__Status__c 
            FROM Zumzum__Purchase_Invoice__c
            WHERE Id IN :purchaseInvoiceIds
        ];

        Test.startTest();
            paymentRun.Status__c = 'Processing';
            update paymentRun;
            List<Id> ids = new List<Id>();
            ids.add(paymentRun.Id);
            BatchOutboundBACSpayment.runBatch(ids);
        Test.stopTest();
    }
}