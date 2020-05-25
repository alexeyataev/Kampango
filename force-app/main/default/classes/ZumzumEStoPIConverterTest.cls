@SuppressWarnings('PMD.MethodNamingConventions')
@isTest(SeeAllData=false)
public without sharing class ZumzumEStoPIConverterTest {
    @isTest static void ConvertEStoPI_ConvertedES_CreatedPI() {
        Test.startTest();
        Set<Id> expenseSheetIds = getId();
        ConvertEStoPIHandler.expenseSheetToPurchaseInvoiceConverter = new ZumzumEStoPIConverterMock();
        ConvertEStoPIHandler.convertExpenseSheetToPurchaseInvoice(expenseSheetIds);
        List<Id> expenseSheetIdsList = new List<Id>();
        expenseSheetIdsList.addAll(expenseSheetIds);
        Zumzum__Purchase_Invoice__c purchaseInvoice = [SELECT Id FROM Zumzum__Purchase_Invoice__c WHERE Zumzum__Expense_Sheet__c =: expenseSheetIdsList[0]];
        System.assertNotEquals(purchaseInvoice.Id, null);
        Test.stopTest();
    }
    private static Set<Id> getId() {
        //Course__c c = new Course__c();
        //insert c;
        Zumzum__Company_Setup__c zumzumCompanySetup = new Zumzum__Company_Setup__c(
            Name = 'NCT',
            Zumzum__Account_Lock_Date__c = Date.today() + 7,
            Zumzum__VAT_Number__c = 'XXXXXXXX'
        );
        insert zumzumCompanySetup;
         
        Zumzum__Currency__c zumzumCurrency = new Zumzum__Currency__c(
            Name = 'GBP',
            Zumzum__Is_Active__c = true,
            Zumzum__Is_Corporate__c = true,
            Zumzum__Symbol__c = '£',
            Zumzum__Company_Setup__c = zumzumCompanySetup.Id
        );
        insert zumzumCurrency;

        Zumzum__Nominal_Categories__c zumzumCreditorsNominalCategory = new Zumzum__Nominal_Categories__c(
            Name = 'Current Liabilities',
            Zumzum__Type__c = 'Current Liabilities'
        );
        insert zumzumCreditorsNominalCategory;

        Zumzum__Sub_Category__c zumzumCreditorsSubCategory = new Zumzum__Sub_Category__c(
            Name = 'Creditors666',
            Zumzum__Range_From__c = 9600,
            Zumzum__Range_To__c = 9799,
            Zumzum__Nominal_Categories__c = zumzumCreditorsNominalCategory.Id 
        );
        insert zumzumCreditorsSubCategory;
        Zumzum__Nominal_Account__c na = new Zumzum__Nominal_Account__c();
        na.Name = 'Test Nominal Account';
        na.Zumzum__Expense__c = true;
        na.Zumzum__Account_Code__c = 10;
        na.Zumzum__Sub_Category__c = zumzumCreditorsSubCategory.Id;
        na.Zumzum__P_O__c = true;
        na.Zumzum__Debit_Balance__c = 600;
        insert na;
        Zumzum__Tax_Rate__c tr = new Zumzum__Tax_Rate__c(
            Name = 'Standard Rated Transactions (20%)',
            Zumzum__Type__c = 'Standard Rate',
            Zumzum__Active__c = true,
            Zumzum__Tax_Rate__c = 20
        );
        insert tr;
        Account acc = new Account();
        acc.AccountNumber = '12345877878';
        acc.Name = 'test';
        acc.Type = 'Supplier';
        acc.Billing_Email__c = 'test@test.com';
        insert acc;
        Zumzum__Expense_Sheet__c es = new Zumzum__Expense_Sheet__c();
        es.Zumzum__Supplier_Account__c = acc.Id;
        es.Zumzum__Type__c = 'Cash';
        insert es;
        Zumzum__Expense_Sheet_Detail__c esD = new Zumzum__Expense_Sheet_Detail__c();
        esD.Zumzum__Expense_Sheet__c = es.Id;
        esD.Zumzum__Tax_Rate__c = tr.Id;
        esD.Zumzum__Nominal_Account__c = na.Id;
        esD.Zumzum__Narrative__c = 'Item name';
        esD.Zumzum__Miles__c = 0;
        esD.Zumzum__Unit_Amount__c = 10;
        esD.Zumzum__Total_Net__c = 10;
        esD.Zumzum__Total_VAT__c = 2;
        esD.Zumzum__Total_Gross__c = 12;
        esD.Zumzum__Quantity__c = 1;
        esD.Zumzum__Date__c = Date.today();
        //esD.Course__c = c.Id;
        insert esD;
        return new Set<Id> {es.Id};
    }
}
