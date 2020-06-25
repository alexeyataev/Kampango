@SuppressWarnings('PMD.MethodNamingConventions')
@isTest
public without sharing class ZumzumEStoPIConverterTest {
    private static final String PROFILE_NAME = 'Finance';
    private static final Integer EXPENSE_SHEET_DETAIL_TOTAL_GROSS = 12;
    private static final String SUPPLIER_ACCOUNT_NUMBER = '123456';
    private static final Map<String, String> TRIGGER_PARAMS = new Map<String, String>{
        'triggerHandlerName' => 'EXPENSESHEET_ConvertEStoPI_TDTM',
        'className' => 'EXPENSESHEET_ConvertEStoPI_TDTM',
        'objectAPIName' => 'Zumzum__Expense_Sheet__c',
        'triggerActions' => 'AfterInsert;AfterUpdate;AfterDelete',
        'isActive' => 'true',
        'loadOrder' => '1',
        'isAsynchronous' => 'false'
    };

    @testSetup
    static void createTestData() {
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
            
        TestFinanceDataFactory financeDataFactory = TestFinanceDataFactory.getInstance();
        financeDataFactory.createZumzumData();
        Account supplierAccount = [SELECT Id FROM Account WHERE RecordType.Name = 'Organization' LIMIT 1];
        financeDataFactory.createExpenseData(TestDataFactory.courses[0].Id, supplierAccount.Id, EXPENSE_SHEET_DETAIL_TOTAL_GROSS);
        TestDataFactory.createTriggerSystemHandlerRecord(TRIGGER_PARAMS);
    }

    @isTest 
    static void ConvertEStoPI_ConvertedES_CreatedPI() {

        User financeUser = TestDataFactory.getActiveTestUserByProfileName(PROFILE_NAME);

        Test.startTest();
            System.runAs(financeUser) {
                Set<Id> expenseSheetIds = new Set<Id>();
                List<Zumzum__Expense_Sheet__c> expenseSheetList = [SELECT Id FROM Zumzum__Expense_Sheet__c];
                
                for(Zumzum__Expense_Sheet__c expenseSheet : expenseSheetList) {
                    expenseSheetIds.add(expenseSheet.Id);
                    expenseSheet.Approval_Status__c = 'Approved';
                }

                ConvertEStoPIHandler.expenseSheetToPurchaseInvoiceConverter = new ZumzumEStoPIConverterMock();
                update expenseSheetList;

                List<Id> expenseSheetIdsList = new List<Id>();
                expenseSheetIdsList.addAll(expenseSheetIds);
                Zumzum__Purchase_Invoice__c purchaseInvoice = [SELECT Id, Zumzum__Total_Gross__c FROM Zumzum__Purchase_Invoice__c WHERE Zumzum__Expense_Sheet__c =: expenseSheetIdsList[0]];

                System.assertEquals(purchaseInvoice.Zumzum__Total_Gross__c, EXPENSE_SHEET_DETAIL_TOTAL_GROSS);
            }
        Test.stopTest();
    }

    @isTest
    static void ConvertNotEStoPI_ConvertedES_CreatedPI() {

        User financeUser = TestDataFactory.getActiveTestUserByProfileName(PROFILE_NAME);

        Test.startTest();
            System.runAs(financeUser) {
                Set<Id> expenseSheetIds = new Set<Id>();
                List<Zumzum__Expense_Sheet__c> expenseSheetList = [SELECT Id FROM Zumzum__Expense_Sheet__c];

                for(Zumzum__Expense_Sheet__c expenseSheet : expenseSheetList) {
                    expenseSheetIds.add(expenseSheet.Id);
                    expenseSheet.Approval_Status__c = 'Rejected';
                }

                ConvertEStoPIHandler.expenseSheetToPurchaseInvoiceConverter = new ZumzumEStoPIConverterMock();
                update expenseSheetList;

                List<Id> expenseSheetIdsList = new List<Id>();
                expenseSheetIdsList.addAll(expenseSheetIds);
                List<Zumzum__Purchase_Invoice__c> purchaseInvoiceList = [SELECT Id, Zumzum__Total_Gross__c FROM Zumzum__Purchase_Invoice__c WHERE Zumzum__Expense_Sheet__c =: expenseSheetIdsList[0]];

                System.assert(purchaseInvoiceList.isEmpty());
            }
        Test.stopTest();
    }
}
