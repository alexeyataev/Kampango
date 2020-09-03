@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #132 - https://confluence.nct.org.uk:8443/x/EoSO

@IsTest
public with sharing class ZumzumPurchaseInvoice_TDTM_Test {

    private static final Integer EXPENSE_SHEET_DETAIL_TOTAL_GROSS = 12;
    private static final String SUPPLIER_ACCOUNT_NUMBER = '123456';
    private static final String PROFILE_NAME = 'Finance';

    private static final Map<String, String> TRIGGER_PARAMS = new Map<String, String> {
        'triggerHandlerName' => 'ZumzumPurchaseInvoice_TDTM',
        'className' => 'ZumzumPurchaseInvoice_TDTM',
        'objectAPIName' => 'Zumzum__Purchase_Invoice__c',
        'triggerActions' => 'AfterInsert;AfterUpdate;AfterDelete',
        'isActive' => 'true',
        'loadOrder' => '0',
        'isAsynchronous' => 'false'
    };

    @TestSetup 
    private static void testSetup() {

        TestDataFactory dataFactory = TestDataFactory.getInstance();
            TestDataFactory.getInstance()
                .buildBranchAccount()
                .buildOrganizationAccount(SUPPLIER_ACCOUNT_NUMBER)
                .createFinanceUser()
                .buildPractitioner('John Practitioner')
                .buildPractitionerFeeRate()
                .buildVenue()
                .buildRoom()
                .buildLicenceToPractice()
                .buildCoursesWithSessions(1, 1);

        Account supplierAccount = [SELECT Id FROM Account WHERE RecordType.Name = 'Organization' LIMIT 1];

        TestFinanceDataFactory financeDataFactory = TestFinanceDataFactory.getInstance();
        financeDataFactory.createZumzumData();
        financeDataFactory.createExpenseData(TestDataFactory.courses[0].Id, supplierAccount.Id, EXPENSE_SHEET_DETAIL_TOTAL_GROSS);
        financeDataFactory.createZumzumPurchaseInvoiceWithLineItems(1);

        TestDataFactory.createTriggerSystemHandlerRecord(TRIGGER_PARAMS);
    }

    @IsTest
    private static void CheckPurchaseInvoiceTDTM_UpdatedPIWithPopulateExpSheetField_NumberOfPIEqualsOne() {

        Zumzum__Expense_Sheet__c expenseSheetBeforeUpdated = [SELECT Id, Number_of_Purchase_Invoices__c FROM Zumzum__Expense_Sheet__c LIMIT 1];
        Zumzum__Purchase_Invoice__c purchaseInvoice = [SELECT Id, Zumzum__Expense_Sheet__c FROM Zumzum__Purchase_Invoice__c LIMIT 1];

        System.assertEquals(expenseSheetBeforeUpdated.Number_of_Purchase_Invoices__c, 0, 'Shoud be equals 0');
        purchaseInvoice.Zumzum__Expense_Sheet__c = expenseSheetBeforeUpdated.Id;

        User financeUser = TestDataFactory.getActiveTestUserByProfileName(PROFILE_NAME);
        Test.startTest();
            System.runAs(financeUser) {
                update purchaseInvoice;
            }
        Test.stopTest();

        Zumzum__Expense_Sheet__c expenseSheetAfterUpdated = [SELECT Id, Number_of_Purchase_Invoices__c FROM Zumzum__Expense_Sheet__c LIMIT 1];
        System.assertEquals(expenseSheetAfterUpdated.Number_of_Purchase_Invoices__c, 1, 'Shoud be equals 1');
    }
}
