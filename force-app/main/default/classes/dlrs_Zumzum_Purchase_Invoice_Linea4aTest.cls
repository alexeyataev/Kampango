@SuppressWarnings('PMD.ClassNamingConventions')
//Incident #72 - https://confluence.nct.org.uk:8443/x/EoSO
@IsTest
private class dlrs_Zumzum_Purchase_Invoice_Linea4aTest
{
    private static final String PRACTITIONER_LASTNAME = 'Smith';
    private static final String HOST_EMAIL_ADDRESS = 'User@ncttest.com';
    private static final String HOST_LASTNAME = 'Black';
    private static final String PROFILE_NAME = 'Enquiry PSA';
    private static final String PERMISSION_SET_NAME = 'Override_Booking_Validation';

    @TestSetup 
    private static void SetupTestData() {
        TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory .buildOrganizationAccount('acc1')
                    .createEnquiryPSA()
                    .buildBranchAccountWithEnquiryPSA()
                    .buildPractitioner(PRACTITIONER_LASTNAME)
                    .buildPractitionerFeeRate()
                    .buildVenue()
                    .buildRoom()
                    .buildLicenceToPractice()
                    .buildCourse()
                    .buildEstimatedCosts()
                    .buildSession()
                    .buildParentHost(HOST_LASTNAME, HOST_EMAIL_ADDRESS)
                    .buildPartnertHost(HOST_LASTNAME, HOST_EMAIL_ADDRESS)
                    .buildSessionWithTypeAndStatus('Reunion', 'Confirmed')
                    .buildBooking('Enquiry');
        TestAccountBuilder accountBuilder = new TestAccountBuilder();
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
        TestPurchaseInvoiceLineItemBuilder purchaseInvoiceLineItemBuilder = new TestPurchaseInvoiceLineItemBuilder();
        
        Zumzum__Purchase_Invoice__c pi1 = purchaseInvoiceBuilder
                .withStatus('Posted')
                .withContact(contact.Id)
                .withDueDate(Date.today().addDays(20))
                .withInvoiceDate(Date.today())
                .insertRecord(true)
                .build();
        Zumzum__Purchase_Invoice_Line_Item__c pili11 = purchaseInvoiceLineItemBuilder
                .withAmount(120)
                .withGross(120)
                .withGross(120)
                .withNet(120)
                .withNarrative('Doll1')
                .withQuantity(1)
                .withPurchaseInvoice(pi1.Id)
                .insertRecord(true)
                .build();
    }
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Zumzum_Purchase_Invoice_La4aTrigger to be invoked, fails the test if org config or other Apex code prevents this.

        Course__c courseBeforeRecalculations = [
			SELECT Id, Total_Other_Costs__c
			FROM Course__c
			LIMIT 1
        ];
        
        Zumzum__Purchase_Invoice_Line_Item__c purchaseInvoiceLineItem = [
			SELECT Course__c
			FROM Zumzum__Purchase_Invoice_Line_Item__c
			LIMIT 1
        ];
        
        purchaseInvoiceLineItem.Course__c = courseBeforeRecalculations.Id;
        update purchaseInvoiceLineItem;

        Test.startTest();
        dlrs.RollupService.testHandler(purchaseInvoiceLineItem);
        Test.stopTest();

        Course__c courseAfterRecalculations = [
			SELECT Id, Total_Other_Costs__c
			FROM Course__c
			LIMIT 1
        ];

        System.assertEquals(null, courseBeforeRecalculations.Total_Other_Costs__c);
        System.assertNotEquals(0, courseAfterRecalculations.Total_Other_Costs__c);
    }
}