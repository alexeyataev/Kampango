@isTest
public without sharing class TestFinanceDataFactory {
    private static final String ACCOUNT_TYPE_CUSTOMER = 'Customer';
    private static final String PRODUCT_NAME_COURSE_PLACE = 'Course Place';
    private static final String PRODUCT_NAME_MEMBERSHIP_18_MONTH = 'Membership - 18 month';
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

        Zumzum__Nominal_Categories__c zumzumCreditorsNominalCategory = new Zumzum__Nominal_Categories__c(
            Name = 'Current Liabilities',
            Zumzum__Type__c = 'Current Liabilities'
        );
        insert zumzumCreditorsNominalCategory;

        Zumzum__Sub_Category__c zumzumCreditorsSubCategory = new Zumzum__Sub_Category__c(
            Name = 'Creditors',
            Zumzum__Range_From__c = 9600,
            Zumzum__Range_To__c = 9799,
            Zumzum__Nominal_Categories__c = zumzumCreditorsNominalCategory.Id 
        );
        insert zumzumCreditorsSubCategory;
        
        Zumzum__Nominal_Account__c zumzumCreditorsNominalAccount = new Zumzum__Nominal_Account__c(
            Name = 'Creditors',
            Zumzum__Account_Code__c = 9600,
            Zumzum__Credit_Balance__c = 154726.04,
            Zumzum__Debit_Balance__c = 8414.14
        );
        insert zumzumCreditorsNominalAccount; 

        Zumzum__Nominal_Budget__c nominalBudget = new Zumzum__Nominal_Budget__c(
            Name = 'Budget',
            Zumzum__Nominal_Account__c = zumzumCreditorsNominalAccount.Id,
            Zumzum__Month__c = 3,
            Zumzum__Year__c = 2020,
            Zumzum__Actuals_Credit__c = 16221.65,
            Zumzum__Actuals_Debit__c = 300.00
        );
        insert nominalBudget;
    
        Zumzum__Nominal_Account__c zumzumMembershipNominalAccount = new Zumzum__Nominal_Account__c(
            Name = 'Debtor Control Account',
            Zumzum__Account_Code__c = 1003
        );
        insert zumzumMembershipNominalAccount;

        Zumzum__Nominal_Account__c zumzumVatOnPurchaseNominalAccount = new Zumzum__Nominal_Account__c(
            Name = 'Input VAT (Sales) Control Account',
            Zumzum__Account_Code__c = 9691,
            Zumzum__Tax_Rate__c = zumzumTaxRate.Id,
            Zumzum__Sub_Category__c = zumzumCreditorsSubCategory.Id
        );
        insert zumzumVatOnPurchaseNominalAccount;

        Zumzum__Control_Account__c controlAccount = new Zumzum__Control_Account__c(
            Name = 'Control Accounts',
            Zumzum__Creditors_Control__c = zumzumCreditorsNominalAccount.Id,
            Zumzum__Debtors_Control__c = zumzumDebtorNominalAccount.Id,
            Zumzum__Credit_Charges__c = zumzumCreditorsNominalAccount.Id,
            Zumzum__VAT_on_Purchases__c = zumzumVatOnPurchaseNominalAccount.Id
        );
        insert controlAccount;

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
        
        Zumzum__Nominal_Account__c zumzumReconcileNominalAccount = new Zumzum__Nominal_Account__c(
            Name = 'Bank Current Account',
            Zumzum__Account_Code__c = 9401
        );
        insert zumzumReconcileNominalAccount;
        
        Zumzum__Bank_Account__c zumzumReconcileBankAccount = new Zumzum__Bank_Account__c(
            Name = 'Reconcile Bank',
            Zumzum__Type__c = 'Current/Saving',
            Zumzum__Account_Number__c = '3',
            Zumzum__Status__c = 'Active',
            Zumzum__Nominal_Account__c = zumzumReconcileNominalAccount.Id
        );
        insert zumzumReconcileBankAccount;

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
            PC_Nominal_Account_Id__c = zumzumNominalAccount.Id, 
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

    public String[] createBatchReceiptReportWithItems(Integer itemsCount) {
        String[] paymentIds = new String[]{};
        List<Batch_Receipt_Report_Item__c> batchReceiptReportItems = new List<Batch_Receipt_Report_Item__c>();
        TestBatchReceiptReportBuilder batchReceiptReportBulder = new TestBatchReceiptReportBuilder();
        Batch_Receipt_Report__c batchReceiptReport = batchReceiptReportBulder.withStatus('Not Created')
                                                                             .insertRecord(true)
                                                                             .build();
        
        TestBatchReceiptReportItemBuilder batchReceiptReportItemBuilder = new TestBatchReceiptReportItemBuilder();
        for (Integer i = 0; i < itemsCount; i++) {
            paymentIds.add(String.valueOf(i));
            batchReceiptReportItems.add(
                batchReceiptReportItemBuilder.withPaymentMethod('CreditCard')
                                             .withCurrencyCode('GBP')
                                             .withAmount(10.00)
                                             .withBatchReceiptReport(batchReceiptReport.Id)
                                             .withPaymentId(String.valueOf(i))
                                             .withCapturedOn(Date.today())
                                             .insertRecord(false)
                                             .build()
            );
        }
        insert batchReceiptReportItems;
        return paymentIds;
    }  
    
    public static void updateHouseholdAccountsToCustomerType() {
        List<Account> accList = [SELECT Id FROM Account WHERE Type = 'Household'];
        for(Account acc : accList) {
            acc.Type = ACCOUNT_TYPE_CUSTOMER;
            acc.AccountNumber = acc.Id;
        }
        update accList;
    }

    public static void createProducts() {
        TestProductBuilder productBuilder = new TestProductBuilder();
        Product2 productCourse = productBuilder
            .withName(PRODUCT_NAME_COURSE_PLACE)
            .insertRecord(true)
            .build();
        Product2 productMembership = productBuilder
            .withName(PRODUCT_NAME_MEMBERSHIP_18_Month)
            .insertRecord(false)
            .build();
            productMembership.ProductCode = 'E';
        insert productMembership;
    }

    public static List<List<ZumzumSalesInvoiceParameters>> getZumzumSalesInvoiceParameters() {
        Account customer = [SELECT Id FROM Account WHERE Type =: ACCOUNT_TYPE_CUSTOMER LIMIT 1];
        Zumzum__Currency__c transactionCurrency = [SELECT Id FROM Zumzum__Currency__c LIMIT 1];
        Product2 productCourse = [SELECT Id FROM Product2 WHERE Name =: PRODUCT_NAME_COURSE_PLACE LIMIT 1];
        Product2 productMembership = [SELECT Id FROM Product2 WHERE Name =: PRODUCT_NAME_MEMBERSHIP_18_Month LIMIT 1];
        Zumzum__Nominal_Account__c zumzumDebtorNominalAccount = [SELECT Id FROM Zumzum__Nominal_Account__c WHERE Zumzum__Account_Code__c = 9300 LIMIT 1];
        Zumzum__Nominal_Account__c zumzumMembershipNominalAccount = [SELECT Id FROM Zumzum__Nominal_Account__c WHERE Zumzum__Account_Code__c = 1003 LIMIT 1];
        Zumzum__Tax_Rate__c taxRate = [SELECT Id FROM Zumzum__Tax_Rate__c LIMIT 1];
        Zumzum__Dimension__c dimension1 = [SELECT Id FROM Zumzum__Dimension__c WHERE Zumzum__Type__c = 'Dimension 1' LIMIT 1];
        List<List<ZumzumSalesInvoiceParameters>> zumzumSalesInvoiceParameterList = new List<List<ZumzumSalesInvoiceParameters>>();
        ZumzumSalesInvoiceParameters courseZumzumSalesInvoiceParameter =  new ZumzumSalesInvoiceParameters();
        coursezumzumSalesInvoiceParameter.customerId = customer.Id;
        coursezumzumSalesInvoiceParameter.transactionCurrencyId = transactionCurrency.Id;
        coursezumzumSalesInvoiceParameter.productId = productCourse.Id;
        coursezumzumSalesInvoiceParameter.quantity = 1;
        coursezumzumSalesInvoiceParameter.nominalAccountId = zumzumDebtorNominalAccount.Id;
        coursezumzumSalesInvoiceParameter.taxRateId = taxRate.Id;
        coursezumzumSalesInvoiceParameter.foreignNetAmount = 100;
        coursezumzumSalesInvoiceParameter.dimension1Id = dimension1.Id;
        ZumzumSalesInvoiceParameters membershipZumzumSalesInvoiceParameter =  new ZumzumSalesInvoiceParameters();
        membershipZumzumSalesInvoiceParameter.customerId = customer.Id;
        membershipZumzumSalesInvoiceParameter.transactionCurrencyId = transactionCurrency.Id;
        // membershipZumzumSalesInvoiceParameter.bookingId = booking.Id;
        membershipZumzumSalesInvoiceParameter.productId = productMembership.Id;
        membershipZumzumSalesInvoiceParameter.quantity = 1;
        membershipZumzumSalesInvoiceParameter.nominalAccountId = zumzumMembershipNominalAccount.Id;
        membershipZumzumSalesInvoiceParameter.taxRateId = taxRate.Id;
        membershipZumzumSalesInvoiceParameter.foreignNetAmount = 10;
        membershipZumzumSalesInvoiceParameter.dimension1Id = dimension1.Id;
        zumzumSalesInvoiceParameterList.add(new List<ZumzumSalesInvoiceParameters> {courseZumzumSalesInvoiceParameter, membershipZumzumSalesInvoiceParameter});
        return zumzumSalesInvoiceParameterList;
    }
}
