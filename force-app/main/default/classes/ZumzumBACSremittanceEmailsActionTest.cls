@isTest
public with sharing class ZumzumBACSremittanceEmailsActionTest {
    private static final String OWA_VALUE = 'nctcourses@nct.org.uk';
    private static final String CONTACT_EMAIL = 'john.black@example.com';
    private static final String TEMPLATE_NAME = 'test';
    private static final String TEMPLATE_DEV_NAME = 'temp';

    @testSetup
    public static void setup() {
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
    static void testAction() {
        List<OrgWideEmailAddress> orgEmailObject = [
            SELECT Id, Address 
            FROM OrgWideEmailAddress
            WHERE Address = :OWA_VALUE
            LIMIT 1
        ];
        Id paymentRunId = [
            SELECT Id FROM Payment_Run__c LIMIT 1
        ].Id;

        if (TestEmailUtility.emailsFeatureEnabled() && !orgEmailObject.isEmpty()) {
            Id templateId = [
                SELECT Id 
                FROM EmailTemplate 
                WHERE DeveloperName = :TEMPLATE_DEV_NAME
                    AND Name = :TEMPLATE_NAME
                LIMIT 1
            ].Id;
            ZumzumBACSremittanceEmailsAction.Request testReq = new ZumzumBACSremittanceEmailsAction.Request();
            testReq.paymentRunId = paymentRunId;
            testReq.emailTemplateId = templateId;
            testReq.orgWideEmailAddress = OWA_VALUE;
            List<ZumzumBACSremittanceEmailsAction.Request> reqList = new List<ZumzumBACSremittanceEmailsAction.Request>();
            reqList.add(testReq);
            
            Boolean success = true;
            Test.startTest();
            Id batchId;
            try {
                List<ZumzumBACSremittanceEmailsAction.Response> responses = ZumzumBACSremittanceEmailsAction.sendRemittanceEmails(reqList);
                batchId = responses[0].message;
            } catch (Exception e) {
                System.debug(e.getMessage());
                success = false;
            }
            Test.stopTest();
            
            if (success) {
                System.assertNotEquals(null, batchId, 'Batch was not started');
                AsyncApexJob a = [
                    SELECT Id, Status, NumberOfErrors, JobItemsProcessed
                    FROM AsyncApexJob WHERE Id = :batchId
                ];

                System.assertEquals('Completed', a.Status);
                Integer itemsCount = [
                    SELECT count() FROM Payment_Run_Line_Item__c WHERE Payment_Run__c = :paymentRunId
                ];
                Payment_Run__c paymentRun = [
                    SELECT Id, Status__c FROM Payment_Run__c WHERE Id = :paymentRunId
                ];
                System.assertEquals(itemsCount, a.JobItemsProcessed);
                System.assertEquals('Closed', paymentRun.Status__c);
            } else {
                System.assert(false, 'An exception occured. Probably Apex action was finished with error');
            }
        }
    }

	@isTest    
    static void testError() {
        List<OrgWideEmailAddress> orgEmailObject = [
            SELECT Id, Address 
            FROM OrgWideEmailAddress
            WHERE Address = :OWA_VALUE
            LIMIT 1
        ];
        Id paymentRunId = [
            SELECT Id FROM Payment_Run__c LIMIT 1
        ].Id;

        if (TestEmailUtility.emailsFeatureEnabled() && !orgEmailObject.isEmpty()) {
            Id templateId = [
                SELECT Id 
                FROM EmailTemplate 
                WHERE DeveloperName = :TEMPLATE_DEV_NAME
                    AND Name = :TEMPLATE_NAME
                LIMIT 1
            ].Id;
			Id orgWideAddressId = orgEmailObject[0].Id;
            ZumzumBACSremittanceEmailsAction.Request testReq = new ZumzumBACSremittanceEmailsAction.Request();
            testReq.paymentRunId = paymentRunId;
            testReq.emailTemplateId = templateId;
            testReq.orgWideEmailAddress = orgWideAddressId; //putting Id instead of Address
            List<ZumzumBACSremittanceEmailsAction.Request> reqList = new List<ZumzumBACSremittanceEmailsAction.Request>();
            reqList.add(testReq);
            
            Boolean success = true;
            Test.startTest();
            Id batchId;
            List<ZumzumBACSremittanceEmailsAction.Response> responses = ZumzumBACSremittanceEmailsAction.sendRemittanceEmails(reqList);
            success = responses[0].isSuccess;
            Test.stopTest();
            
            System.assertEquals(false, success, 'Exception was not thrown');
        }
    }
}