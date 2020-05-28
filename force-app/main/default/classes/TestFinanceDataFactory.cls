@isTest
public without sharing class TestFinanceDataFactory {
    private static final String ACCOUNT_TYPE_CUSTOMER = 'Customer';
    private static final String PRODUCT_NAME_COURSE_PLACE = 'Course Place';
    private static final String PRODUCT_NAME_MEMBERSHIP_18_MONTH = 'Membership - 18 month';
    private static TestFinanceDataFactory instance;
    private Zumzum__Tax_Rate__c zumzumNoVatTaxRate;
    private Zumzum__Nominal_Account__c expenseNominalAccount;

    public static TestFinanceDataFactory getInstance() {
        if (instance == NULL) {
            instance = new TestFinanceDataFactory();
        }
        return instance;
    }

    public void createZumzumData() {
        zumzumNoVatTaxRate = new Zumzum__Tax_Rate__c(
            Name = 'No VAT',
            Zumzum__Type__c = 'Non-Vatable',
            Zumzum__Active__c = true,
            Zumzum__Tax_Rate__c = 0
        );

        insert zumzumNoVatTaxRate;

        Zumzum__Invoice_Template__c zumzumInvoiceTemplate = new Zumzum__Invoice_Template__c(
            Name = 'Zumzum Sample Template',
            Zumzum__Is_Default__c = true,
            Zumzum__Type__c = 'Sales Invoice',
            Zumzum__Margins_left_right_Inches__c = 0.5,
            Zumzum__Margins_top_bottom__c = 0.5
        );

        insert zumzumInvoiceTemplate;

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
            Zumzum__Tax_Rate__c = zumzumNoVatTaxRate.Id,
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
            Name = 'CARD RECEIPTS IN TRANSIT',
            Zumzum__Type__c = 'Current/Saving',
            Zumzum__Account_Number__c = '12345678',
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

        Zumzum__General_Setup__c zumzumGeneralSetupSalesInvoiceTransaction = new Zumzum__General_Setup__c(
            Name = 'SI',
            Zumzum__Object__c = 'Sales Invoice',
            Zumzum__Starting_Document_No__c = '00000000',
            Zumzum__Current_Document_Number__c = 171
        );

        insert new List<Zumzum__General_Setup__c> {zumzumGeneralSetupPurchaseInvoice, zumzumGeneralSetupLedgerTransaction, zumzumGeneralSetupSalesInvoiceTransaction};

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

        expenseNominalAccount = new Zumzum__Nominal_Account__c();
        expenseNominalAccount.Name = 'Test Expense Nominal Account';
        expenseNominalAccount.Zumzum__Expense__c = true;
        expenseNominalAccount.Zumzum__Account_Code__c = 10;
        expenseNominalAccount.Zumzum__Sub_Category__c = zumzumCreditorsSubCategory.Id;
        expenseNominalAccount.Zumzum__P_O__c = true;
        expenseNominalAccount.Zumzum__Debit_Balance__c = 600;
        insert expenseNominalAccount;
    }

    public void createExpenseData(Id courseId, Id supplierId, Integer amount) {
        Zumzum__Expense_Sheet__c expenseSheet = new Zumzum__Expense_Sheet__c();
        expenseSheet.Zumzum__Supplier_Account__c = supplierId;
        expenseSheet.Zumzum__Type__c = 'Cash';
        insert expenseSheet;
        Zumzum__Expense_Sheet_Detail__c expenseSheetDetail = new Zumzum__Expense_Sheet_Detail__c();
        expenseSheetDetail.Zumzum__Expense_Sheet__c = expenseSheet.Id;
        expenseSheetDetail.Zumzum__Tax_Rate__c = zumzumNoVatTaxRate.Id;
        expenseSheetDetail.Zumzum__Nominal_Account__c = expenseNominalAccount.Id;
        expenseSheetDetail.Zumzum__Narrative__c = 'Item name';
        expenseSheetDetail.Zumzum__Miles__c = 0;
        expenseSheetDetail.Zumzum__Unit_Amount__c = amount;
        expenseSheetDetail.Zumzum__Total_Net__c = amount;
        expenseSheetDetail.Zumzum__Total_VAT__c = 0;
        expenseSheetDetail.Zumzum__Total_Gross__c = amount;
        expenseSheetDetail.Zumzum__Quantity__c = 1;
        expenseSheetDetail.Zumzum__Date__c = Date.today();
        expenseSheetDetail.Course__c = courseId;
        insert expenseSheetDetail;
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
        // Booking__c booking = [SELECT Id FROM Booking__c LIMIT 1];
        Account customer = [SELECT Id FROM Account WHERE Type =: ACCOUNT_TYPE_CUSTOMER LIMIT 1];
        Zumzum__Currency__c transactionCurrency = [SELECT Id FROM Zumzum__Currency__c LIMIT 1];
        Product2 productCourse = [SELECT Id FROM Product2 WHERE Name =: PRODUCT_NAME_COURSE_PLACE LIMIT 1];
        Product2 productMembership = [SELECT Id FROM Product2 WHERE Name =: PRODUCT_NAME_MEMBERSHIP_18_Month LIMIT 1];
        Zumzum__Nominal_Account__c zumzumDebtorNominalAccount = [SELECT Id FROM Zumzum__Nominal_Account__c WHERE Zumzum__Account_Code__c = 9300 LIMIT 1];
        Zumzum__Nominal_Account__c zumzumMembershipNominalAccount = [SELECT Id FROM Zumzum__Nominal_Account__c WHERE Zumzum__Account_Code__c = 1003 LIMIT 1];
        Zumzum__Tax_Rate__c taxRate = [SELECT Id FROM Zumzum__Tax_Rate__c LIMIT 1];
        Zumzum__Dimension__c dimension1 = [SELECT Id FROM Zumzum__Dimension__c WHERE Zumzum__Type__c = 'Dimension 1' LIMIT 1];
        Zumzum__Dimension__c dimension2 = [SELECT Id FROM Zumzum__Dimension__c WHERE Zumzum__Type__c = 'Dimension 2' LIMIT 1];
        List<List<ZumzumSalesInvoiceParameters>> zumzumSalesInvoiceParameterList = new List<List<ZumzumSalesInvoiceParameters>>();
        ZumzumSalesInvoiceParameters courseZumzumSalesInvoiceParameter =  new ZumzumSalesInvoiceParameters();
        coursezumzumSalesInvoiceParameter.customerId = customer.Id;
        coursezumzumSalesInvoiceParameter.transactionCurrencyId = transactionCurrency.Id;
        // coursezumzumSalesInvoiceParameter.bookingId = booking.Id;
        coursezumzumSalesInvoiceParameter.productId = productCourse.Id;
        coursezumzumSalesInvoiceParameter.quantity = 1;
        coursezumzumSalesInvoiceParameter.nominalAccountId = zumzumDebtorNominalAccount.Id;
        coursezumzumSalesInvoiceParameter.taxRateId = taxRate.Id;
        coursezumzumSalesInvoiceParameter.foreignNetAmount = 100;
        coursezumzumSalesInvoiceParameter.dimension1Id = dimension1.Id;
        coursezumzumSalesInvoiceParameter.dimension2Id = dimension2.Id;
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
        membershipZumzumSalesInvoiceParameter.dimension2Id = dimension2.Id;
        zumzumSalesInvoiceParameterList.add(new List<ZumzumSalesInvoiceParameters> {courseZumzumSalesInvoiceParameter, membershipZumzumSalesInvoiceParameter});
        return zumzumSalesInvoiceParameterList;
    }
}
