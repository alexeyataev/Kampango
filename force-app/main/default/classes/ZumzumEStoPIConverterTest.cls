@SuppressWarnings('PMD.MethodNamingConventions')
@isTest(SeeAllData=false)
public without sharing class ZumzumEStoPIConverterTest {
    private static final String SUPPLIER_ACCOUNT_NUMBER = '123456';
    @testSetup
    static void createTestData() {
        TestDataFactory.getInstance()
            .buildBranchAccount()
            .buildOrganizationAccount(SUPPLIER_ACCOUNT_NUMBER)
            .buildPractitioner('John Practitioner')
            .buildPractitionerFeeRate()
            .buildVenue()
            .buildRoom()
            .buildLicenceToPractice()
            .buildCoursesWithSessions(1, 1);
        TestFinanceDataFactory financeDataFactory = TestFinanceDataFactory.getInstance();
        financeDataFactory.createZumzumData();
        Account supplierAccount = [SELECT Id FROM Account WHERE AccountNumber =: SUPPLIER_ACCOUNT_NUMBER];
        financeDataFactory.createExpenseDate(TestDataFactory.courses[0].Id, supplierAccount.Id);
    }
    @isTest static void ConvertEStoPI_ConvertedES_CreatedPI() {
        Test.startTest();
        Set<Id> expenseSheetIds = new Set<Id>();
        for(Zumzum__Expense_Sheet__c expenseSheet : [SELECT Id FROM Zumzum__Expense_Sheet__c]) {
            expenseSheetIds.add(expenseSheet.Id);
        }
        ConvertEStoPIHandler.expenseSheetToPurchaseInvoiceConverter = new ZumzumEStoPIConverterMock();
        ConvertEStoPIHandler.convertExpenseSheetToPurchaseInvoice(expenseSheetIds);
        List<Id> expenseSheetIdsList = new List<Id>();
        expenseSheetIdsList.addAll(expenseSheetIds);
        Zumzum__Purchase_Invoice__c purchaseInvoice = [SELECT Id, Zumzum__Total_Gross__c FROM Zumzum__Purchase_Invoice__c WHERE Zumzum__Expense_Sheet__c =: expenseSheetIdsList[0]];
        System.assertEquals(purchaseInvoice.Zumzum__Total_Gross__c, 12);
        Test.stopTest();
    }
}
