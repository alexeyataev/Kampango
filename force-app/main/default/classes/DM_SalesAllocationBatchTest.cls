/**
 * Created by johnp on 27/07/2020.
 */

@IsTest
private class DM_SalesAllocationBatchTest {
    private static final String ACCOUNT_TYPE_CUSTOMER = 'Customer';
    private static final String SALES_INVOICE_TYPE_SI = 'Sales Invoice';
    private static final String SALES_INVOICE_TYPE_SC = 'Sales Credit';
    private static final String SALES_INVOICE_STATUS_POSTED = 'Posted';
    private static final String PRODUCT_NAME_COURSE_PLACE = 'Course Place';
    private static final Integer BANK_NOMINAL_ACCOUNT_CODE = 9300;
    private static final Integer LINE_ITEM_QUANTITY = 1;
    private static final Decimal LINE_ITEM_AMOUNT = 100.00;

    @testSetup
    static void testSetup() {
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
        Zumzum__Nominal_Account__c nominalAccount = [SELECT Id FROM Zumzum__Nominal_Account__c WHERE Zumzum__Account_Code__c = :BANK_NOMINAL_ACCOUNT_CODE LIMIT 1];
        Zumzum__Tax_Rate__c taxRate = [SELECT Id FROM Zumzum__Tax_Rate__c LIMIT 1];

        Zumzum__Sales_Invoice__c salesInvoice = new Zumzum__Sales_Invoice__c(
                Zumzum__Account__c = customer.Id,
                Zumzum__Company__c = company.Id,
                Zumzum__Invoice_Date__c = Date.today(),
                Zumzum__Transaction_Currency__c = transactionCurrency.Id,
                Zumzum__Type__c = SALES_INVOICE_TYPE_SI,
                Zumzum__Status__c = SALES_INVOICE_STATUS_POSTED
        );
        insert salesInvoice;

        Zumzum__Sales_Invoice__c salesCredit = new Zumzum__Sales_Invoice__c(
                Zumzum__Account__c = customer.Id,
                Zumzum__Company__c = company.Id,
                Zumzum__Invoice_Date__c = Date.today(),
                Zumzum__Transaction_Currency__c = transactionCurrency.Id,
                Zumzum__Type__c = SALES_INVOICE_TYPE_SC,
                Zumzum__Status__c = SALES_INVOICE_STATUS_POSTED,
                Zumzum__Sales_Invoice_to_Credit__c = salesInvoice.Id
        );
        insert salesCredit;

        Zumzum__Sales_Invoice_Line_Item__c salesInvoiceLineItem = new Zumzum__Sales_Invoice_Line_Item__c(
                Zumzum__Product__c = productCourse.Id,
                Zumzum__Nominal_Account__c = nominalAccount.Id,
                Zumzum__Company__c = company.Id,
                Zumzum__Quantity__c = LINE_ITEM_QUANTITY,
                Zumzum__Tax_Rate__c = taxRate.Id,
                Zumzum__Foreign_Net_Amount__c = LINE_ITEM_AMOUNT,
                Zumzum__Amount__c = LINE_ITEM_AMOUNT,
                Zumzum__Foreign_Net_Total__c = LINE_ITEM_AMOUNT,
                Zumzum__Foreign_Gross__c = LINE_ITEM_AMOUNT,
                Zumzum__Total_Gross__c = LINE_ITEM_AMOUNT,
                Zumzum__Sales_Invoice__c = salesInvoice.Id
        );
        insert salesInvoiceLineItem;
        Zumzum__Sales_Invoice_Line_Item__c salesCreditLineItem = new Zumzum__Sales_Invoice_Line_Item__c(
                Zumzum__Product__c = productCourse.Id,
                Zumzum__Nominal_Account__c = nominalAccount.Id,
                Zumzum__Company__c = company.Id,
                Zumzum__Quantity__c = LINE_ITEM_QUANTITY,
                Zumzum__Tax_Rate__c = taxRate.Id,
                Zumzum__Foreign_Net_Amount__c = LINE_ITEM_AMOUNT,
                Zumzum__Amount__c = LINE_ITEM_AMOUNT,
                Zumzum__Foreign_Net_Total__c = LINE_ITEM_AMOUNT,
                Zumzum__Foreign_Gross__c = LINE_ITEM_AMOUNT,
                Zumzum__Total_Gross__c = LINE_ITEM_AMOUNT,
                Zumzum__Sales_Invoice__c = salesCredit.Id,
                Allocate_To__c =  salesInvoiceLineItem.Id
        );
        insert salesCreditLineItem;

        ZumzumSalesInvoiceCreator.postSI(new List<Zumzum__Sales_Invoice__c>{salesInvoice, salesCredit});
        List<Zumzum__Ledger__c> ledgers = new List<Zumzum__Ledger__c>();
        Zumzum__Ledger__c ledger1 = new Zumzum__Ledger__c(
                Zumzum__Company__c = company.Id,
                Zumzum__Transaction_Currency__c = transactionCurrency.Id,
                Zumzum__Trans_Date__c = Date.today() - 5,
                Zumzum__Sub_Account_Nominal_Link__c = nominalAccount.Id,
                Zumzum__Sales_Invoice__c = salesInvoice.Id,
                Zumzum__Sales_Invoice_Line_Item__c = salesInvoiceLineItem.Id,
                Zumzum__Net_Amount__c = 100,
                Zumzum__Customer_Supplier_Account_Name__c = customer.Id
        );
        Zumzum__Ledger__c ledger2 = new Zumzum__Ledger__c(
                Zumzum__Company__c = company.Id,
                Zumzum__Transaction_Currency__c = transactionCurrency.Id,
                Zumzum__Trans_Date__c = Date.today() - 5,
                Zumzum__Sub_Account_Nominal_Link__c = nominalAccount.Id,
                Zumzum__Sales_Invoice__c = salesCredit.Id,
                Zumzum__Sales_Invoice_Line_Item__c = salesCreditLineItem.Id,
                Zumzum__Net_Amount__c = 100,
                Zumzum__Customer_Supplier_Account_Name__c = customer.Id
        );
        ledgers.add(ledger1);
        ledgers.add(ledger2);
        insert ledgers;
    }

    @IsTest
    static void testSalesAllocationBatch(){
        Test.startTest();
            DM_SalesAllocationBatch dmBatch = new DM_SalesAllocationBatch();
            Database.executeBatch(dmBatch);
        Test.stopTest();
        Decimal allocationCnt = [SELECT Count() FROM Zumzum__Ledger_Payment_History__c];
    }
}