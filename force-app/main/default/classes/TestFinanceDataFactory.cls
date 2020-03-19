@isTest
public without sharing class TestFinanceDataFactory {
    private static TestFinanceDataFactory instance;

    public static TestFinanceDataFactory getInstance() {
        if (instance == NULL) {
            instance = new TestFinanceDataFactory();
        }
        return instance;
    }
    public void createZumzumData() {
        Zumzum__Tax_Rate__c zumzumTaxRate = new Zumzum__Tax_Rate__c(
            Name = 'No VAT',
            Zumzum__Type__c = 'Non-Vatable',
            Zumzum__Active__c = true,
            Zumzum__Tax_Rate__c = 0
        );

        insert zumzumTaxRate;     

        Zumzum__Company_Setup__c zumzumCompanySetup = new Zumzum__Company_Setup__c(
            Name = 'NCT',
            Zumzum__Account_Lock_Date__c = Date.today() + 7,
            Zumzum__VAT_Number__c = '12345678'
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

        Zumzum__Nominal_Account__c zumzumNominalAccount = new Zumzum__Nominal_Account__c(
            Name = 'Staff Salaries',
            Zumzum__Account_Code__c = 7003
        );
        insert zumzumNominalAccount;

        Zumzum__Nominal_Account__c zumzumDebtorNominalAccount = new Zumzum__Nominal_Account__c(
            Name = 'Debtor Control Account',
            Zumzum__Account_Code__c = 9300
        );
        insert zumzumDebtorNominalAccount;

        Zumzum__Nominal_Account__c zumzumMembershipNominalAccount = new Zumzum__Nominal_Account__c(
            Name = 'Debtor Control Account',
            Zumzum__Account_Code__c = 1003
        );
        insert zumzumMembershipNominalAccount;     

        Zumzum__Company__c zumzumCompany = new Zumzum__Company__c(
            Name = 'NCT',
            Zumzum__Company_Base_Currency__c = zumzumCurrency.Id,
            Zumzum__Corporate_Company__c = zumzumCompanySetup.Id,
            Zumzum__Active__c = true,
            Zumzum__Corporate__c = true
        );
        insert zumzumCompany;

        Zumzum__Nominal_Account__c zumzumCurrentNominalAccount = new Zumzum__Nominal_Account__c(
            Name = 'Bank Current Account',
            Zumzum__Account_Code__c = 9400
        );
        insert zumzumCurrentNominalAccount;
        
        Zumzum__Bank_Account__c zumzumBankAccount = new Zumzum__Bank_Account__c(
            Name = 'Card Receipts in Transit',
            Zumzum__Type__c = 'Current/Saving',
            Zumzum__Account_Number__c = '1',
            Zumzum__Status__c = 'Active',
            Zumzum__Nominal_Account__c = zumzumCurrentNominalAccount.Id
        );
        insert zumzumBankAccount;

        Zumzum__General_Setup__c zumzumGeneralSetupPurchaseInvoice = new Zumzum__General_Setup__c(
            Name = 'PI',
            Zumzum__Starting_Document_No__c = '00030000',
            Zumzum__Object__c = 'Purchase Invoice',
            Zumzum__Current_Document_Number__c = 30000
        );

        Zumzum__General_Setup__c zumzumGeneralSetupLedgerTransaction = new Zumzum__General_Setup__c(
            Name = 'Ledger',
    		Zumzum__Object__c = 'Ledger Transaction',
            Zumzum__Starting_Document_No__c = '00050000',
            Zumzum__Current_Document_Number__c = 50000
        );

        insert new List<Zumzum__General_Setup__c> {zumzumGeneralSetupPurchaseInvoice, zumzumGeneralSetupLedgerTransaction};

        insert new Financial_Settings__c(
            PI_Nominal_Account_Id__c = zumzumNominalAccount.Id, 
            Practitioner_Registration_Capped_Fees__c = 300, 
            Practitioner_Registration_Fees_Rate__c = 0.03
        );

        Zumzum__Dimension__c dimension1 = new Zumzum__Dimension__c();
        dimension1.Zumzum__Active__c = true;
        dimension1.Zumzum__Type__c = 'Dimension 1';
        insert dimension1;
        Zumzum__Dimension__c dimension2 = new Zumzum__Dimension__c();
        dimension2.Zumzum__Active__c = true;
        dimension2.Zumzum__Type__c = 'Dimension 2';
        insert dimension2;
    }        
}
