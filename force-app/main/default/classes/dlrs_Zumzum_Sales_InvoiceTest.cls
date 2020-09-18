@SuppressWarnings('PMD.ClassNamingConventions')
//Incident #143 - https://confluence.nct.org.uk:8443/x/EoSO
@IsTest
private class dlrs_Zumzum_Sales_InvoiceTest {
    private static final String PRACTITIONER_LASTNAME = 'Smith';
    private static final String PRACTITIONER_EMAIL_ADDRESS = 'partnerCommunityUser@ncttest.com';
    private static final String HOST_LASTNAME = 'Black';
    private static final String HOST_LASTNAME_TWO = 'Brown';
    private static final String HOST_EMAIL_ADDRESS = 'User@ncttest.com';
    private static final String ACCOUNT_TYPE_CUSTOMER = 'Customer';
    private static final String CREDIT_CARD_NUMBER = '1111-2222-3333-4444';
    private static final String PAYMENT_PROFILE_CREDIT_CARD_RECORD_TYPE = 'Credit Card';
    private static final String SALES_INVOICE_TYPE_SI = 'Sales Invoice';
    private static final String SALES_INVOICE_STATUS_POSTED = 'Posted';
    private static final String PRODUCT_NAME_COURSE_PLACE = 'Course Place';
    private static final String PRODUCT_NAME_MEMBERSHIP_18_MONTH = 'Membership - 18 month';
    private static final Integer BANK_NOMINAL_ACCOUNT_CODE = 9401;
    private static final Integer LINE_ITEM_QUANTITY = 1;
    private static final Decimal LINE_ITEM_AMOUNT_30 = 30.00;
    private static final Decimal LINE_ITEM_AMOUNT_40 = 40.00;
    private static final Decimal LINE_ITEM_AMOUNT_50 = 50.00;
    private static final Map<String, String> BOOKING_TRIGGER_PARAMS = new Map<String, String>{
        'triggerHandlerName' => 'Booking_Rollups_TDTM',
        'className' => 'Booking_Rollups_TDTM',
        'objectAPIName' => 'Booking__c',
        'triggerActions' => 'AfterInsert;AfterUpdate',
        'isActive' => 'true',
        'loadOrder' => '1',
        'isAsynchronous' => 'false'
    };
    private static final Map<String, String> SI_TRIGGER_PARAMS = new Map<String, String>{
        'triggerHandlerName' => 'SalesInvoice_Rollups_TDTM',
        'className' => 'SalesInvoice_Rollups_TDTM',
        'objectAPIName' => 'Zumzum__Sales_Invoice__c',
        'triggerActions' => 'AfterInsert;AfterUpdate',
        'isActive' => 'true',
        'loadOrder' => '1',
        'isAsynchronous' => 'false'
    };
    private static final Map<String, String> SILI_TRIGGER_PARAMS = new Map<String, String>{
        'triggerHandlerName' => 'SalesInvoiceLineItem_Rollups_TDTM',
        'className' => 'SalesInvoiceLineItem_Rollups_TDTM',
        'objectAPIName' => 'Zumzum__Sales_Invoice_Line_Item__c',
        'triggerActions' => 'AfterInsert;AfterUpdate',
        'isActive' => 'true',
        'loadOrder' => '1',
        'isAsynchronous' => 'false'
    };

    @testSetup
    static void testSetup() {
        TestDataFactory.createTriggerSystemHandlerRecord(BOOKING_TRIGGER_PARAMS);
        TestDataFactory.createTriggerSystemHandlerRecord(SI_TRIGGER_PARAMS);
        TestDataFactory.createTriggerSystemHandlerRecord(SILI_TRIGGER_PARAMS);
        TestDataFactory dataFactory = TestDataFactory.getInstance();
        dataFactory .buildOrganizationAccount('acc1')
                    .buildBranchAccount()
                    .buildPractitioner(PRACTITIONER_LASTNAME, PRACTITIONER_EMAIL_ADDRESS)
                    .buildPractitionerFeeRate()
                    .buildVenue()
                    .buildRoom()
                    .buildLicenceToPractice()
                    .buildCourse()
                    .buildParentHost(HOST_LASTNAME, HOST_EMAIL_ADDRESS)
                    .buildPartnertHost(HOST_LASTNAME_TWO, HOST_EMAIL_ADDRESS)
                    .buildBooking('Enquiry');
        TestFinanceDataFactory financeDataFactory = TestFinanceDataFactory.getInstance();
        financeDataFactory.createZumzumData();
        TestAccountBuilder accountBuilder = new TestAccountBuilder();
        Account customer = accountBuilder
                                .withRecordType('Household Account')
                                .withName('Test Customer')
                                .withType(ACCOUNT_TYPE_CUSTOMER)
                                .withAccountNumber('123456')
                                .withBillingEmail('testbilling@nonsense.noemails')
                                .insertRecord(true)
                                .build();
        
        TestFinanceDataFactory.updateHouseholdAccountsToCustomerType();
        TestFinanceDataFactory.createProducts();

        Zumzum__Bank_Account__c bankAccount = [SELECT Id FROM Zumzum__Bank_Account__c WHERE Name = 'Reconcile Bank' LIMIT 1];
        Zumzum__Company__c company = [SELECT Id FROM Zumzum__Company__c WHERE Name = 'NCT' LIMIT 1];
        Zumzum__Currency__c transactionCurrency = [SELECT Id FROM Zumzum__Currency__c WHERE Name = 'GBP' LIMIT 1];
        Product2 productCourse = [SELECT Id FROM Product2 WHERE Name =: PRODUCT_NAME_COURSE_PLACE LIMIT 1];
        Product2 productMembership = [SELECT Id FROM Product2 WHERE Name =: PRODUCT_NAME_MEMBERSHIP_18_MONTH LIMIT 1];
        Zumzum__Nominal_Account__c nominalAccount = [SELECT Id FROM Zumzum__Nominal_Account__c WHERE Zumzum__Account_Code__c = :BANK_NOMINAL_ACCOUNT_CODE LIMIT 1];
        Zumzum__Tax_Rate__c taxRate = [SELECT Id FROM Zumzum__Tax_Rate__c LIMIT 1];
        Set<String> paymentIds = financeDataFactory.createBatchReceiptReportWithItems(2, 100.00, true);
        List<Batch_Receipt_Report_Item__c> receiptReportItems = [SELECT Amount__c, Payment_Id__c FROM Batch_Receipt_Report_Item__c];
        Booking__c booking = [SELECT Id, Primary_Contact__c FROM Booking__c LIMIT 1];
        
        Zumzum__Sales_Invoice__c salesInvoicePosted = new Zumzum__Sales_Invoice__c(
            Booking__c = booking.Id,
            Zumzum__Contact__c = booking.Primary_Contact__c,
            Zumzum__Account__c = customer.Id,
            Zumzum__Company__c = company.Id,
            Zumzum__Invoice_Date__c = Date.today(),
            Zumzum__Transaction_Currency__c = transactionCurrency.Id,
            Zumzum__Type__c = SALES_INVOICE_TYPE_SI
        );
        insert salesInvoicePosted;

        Zumzum__Sales_Invoice__c salesInvoice = new Zumzum__Sales_Invoice__c(
            Booking__c = booking.Id,
            Zumzum__Contact__c = booking.Primary_Contact__c,
            Zumzum__Account__c = customer.Id,
            Zumzum__Company__c = company.Id,
            Zumzum__Invoice_Date__c = Date.today(),
            Zumzum__Transaction_Currency__c = transactionCurrency.Id,
            Zumzum__Type__c = SALES_INVOICE_TYPE_SI
        );
        insert salesInvoice;

        Zumzum__Sales_Invoice_Line_Item__c salesInvoiceLineItem1 = new Zumzum__Sales_Invoice_Line_Item__c(
            Zumzum__Product__c = productCourse.Id,
            Zumzum__Nominal_Account__c = nominalAccount.Id,
            Zumzum__Company__c = company.Id,
            Zumzum__Quantity__c = LINE_ITEM_QUANTITY,
            Zumzum__Tax_Rate__c = taxRate.Id,
            Zumzum__Foreign_Net_Amount__c = LINE_ITEM_AMOUNT_30,
            Zumzum__Amount__c = LINE_ITEM_AMOUNT_30,
            Zumzum__Foreign_Net_Total__c = LINE_ITEM_AMOUNT_30,
            Zumzum__Foreign_Gross__c = LINE_ITEM_AMOUNT_30,
            Zumzum__Total_Gross__c = LINE_ITEM_AMOUNT_30,
            Zumzum__Sales_Invoice__c = salesInvoicePosted.Id
        );
        Zumzum__Sales_Invoice_Line_Item__c salesInvoiceLineItem2 = new Zumzum__Sales_Invoice_Line_Item__c(
            Zumzum__Product__c = productMembership.Id,
            Zumzum__Nominal_Account__c = nominalAccount.Id,
            Zumzum__Company__c = company.Id,
            Zumzum__Quantity__c = LINE_ITEM_QUANTITY,
            Zumzum__Tax_Rate__c = taxRate.Id,
            Zumzum__Foreign_Net_Amount__c = LINE_ITEM_AMOUNT_40,
            Zumzum__Amount__c = LINE_ITEM_AMOUNT_40,
            Zumzum__Foreign_Net_Total__c = LINE_ITEM_AMOUNT_40,
            Zumzum__Foreign_Gross__c = LINE_ITEM_AMOUNT_40,
            Zumzum__Total_Gross__c = LINE_ITEM_AMOUNT_40,
            Zumzum__Sales_Invoice__c = salesInvoicePosted.Id
        );
        Zumzum__Sales_Invoice_Line_Item__c salesInvoiceLineItem3 = new Zumzum__Sales_Invoice_Line_Item__c(
            Zumzum__Product__c = productCourse.Id,
            Zumzum__Nominal_Account__c = nominalAccount.Id,
            Zumzum__Company__c = company.Id,
            Zumzum__Quantity__c = LINE_ITEM_QUANTITY,
            Zumzum__Tax_Rate__c = taxRate.Id,
            Zumzum__Foreign_Net_Amount__c = LINE_ITEM_AMOUNT_50,
            Zumzum__Amount__c = LINE_ITEM_AMOUNT_50,
            Zumzum__Foreign_Net_Total__c = LINE_ITEM_AMOUNT_50,
            Zumzum__Foreign_Gross__c = LINE_ITEM_AMOUNT_50,
            Zumzum__Total_Gross__c = LINE_ITEM_AMOUNT_50,
            Zumzum__Sales_Invoice__c = salesInvoice.Id
        );
        insert new List<Zumzum__Sales_Invoice_Line_Item__c>{salesInvoiceLineItem1, salesInvoiceLineItem2, salesInvoiceLineItem3};
        salesInvoicePosted.Zumzum__Status__c = SALES_INVOICE_STATUS_POSTED;
        update salesInvoicePosted;
    }
    @IsTest
    private static void testTrigger() {
        Test.startTest();
        Zumzum__Sales_Invoice__c salesInvoicePosted = [SELECT Id, Course_Place_Total__c FROM Zumzum__Sales_Invoice__c WHERE Zumzum__Status__c =: SALES_INVOICE_STATUS_POSTED LIMIT 1];
        Zumzum__Sales_Invoice__c salesInvoice = [SELECT Id, Course_Place_Total__c FROM Zumzum__Sales_Invoice__c WHERE Zumzum__Status__c !=: SALES_INVOICE_STATUS_POSTED LIMIT 1];
        Booking__c booking = [SELECT Id, Status__c, Actual_Fee_Charged__c FROM Booking__c LIMIT 1];
        System.assertEquals(salesInvoicePosted.Course_Place_Total__c, 30);
        System.assertEquals(salesInvoice.Course_Place_Total__c, 50);
        System.assertEquals(booking.Actual_Fee_Charged__c, 30);
        booking.Status__c = 'Confirmed';
        update booking;
        Course__c courseAfterRecalculations = [
            SELECT Id, Total_Course_Booking_Income__c, Total_Course_Fee_Income__c, Total_Other_Income__c
            FROM Course__c
            LIMIT 1
        ];
        System.assertEquals(courseAfterRecalculations.Total_Course_Fee_Income__c + courseAfterRecalculations.Total_Other_Income__c, courseAfterRecalculations.Total_Course_Booking_Income__c);
        Test.stopTest();
    }
}