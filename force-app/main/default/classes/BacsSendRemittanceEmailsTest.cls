@SuppressWarnings('PMD.MethodNamingConventions')
//Incident #135 - https://confluence.nct.org.uk:8443/x/EoSO
@isTest
private class BacsSendRemittanceEmailsTest {
    private final static String TYPE_PURCHASE_INVOICE = 'Purchase Invoice';
    @TestSetup
    static void setupTestData(){
        TestAccountBuilder accountBuilder = new TestAccountBuilder();
        Account supplierAccount = accountBuilder.WithRecordType('Organization')
            .withName('Tom Genet')
            .withType('Supplier')
            .withAccountNumber('869343')
            .withBillingEmail('tets@gmail.com')
            .withBankSortCode('572899')
            .withBankAccountNumber('03456123')
            .withBankAccountName('TEST BANK ACCOUNT')
            .insertRecord(true)
            .build();

        Account account = accountBuilder
            .withRecordType('Household Account')
            .withBranchNumber('777')
            .withAccountNumber('869341')
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
            Zumzum__Purchase_Invoice__c purchaseInvoice = purchaseInvoiceBuilder
            .withType(TYPE_PURCHASE_INVOICE)
            .withStatus('Posted')
            .withAccount(supplierAccount.Id)
            .withContact(contact.Id)
            .withDueDate(Date.today().addDays(20))
            .withInvoiceDate(Date.today())
            .insertRecord(true)
            .build();

        TestPaymentRunBuilder paymentRunBuilder = new TestPaymentRunBuilder();
        Payment_Run__c paymentRun = paymentRunBuilder
            .insertLineItem(purchaseInvoice.Id)
            .build();
        paymentRun.Status__c = 'Completed';
        update paymentRun;
    }
    @isTest
    static void BacsSendRemittanceEmails_EmailSent_CheckboxSentTrue() {
        Test.startTest();
        List<Payment_Run_Line_Item__c> prliList = [SELECT Id, Paid_Amount__c, Reference_Info__c, Supplier_Account_Billing_Email__c FROM Payment_Run_Line_Item__c];
        BacsSendRemittanceEmailsHelper.sendEmails(new List<List<Payment_Run_Line_Item__c>> {prliList});
        Test.stopTest();
        List<Payment_Run_Line_Item__c> prliUpdatedList = [SELECT Is_Email_Sent__c FROM Payment_Run_Line_Item__c WHERE Id IN : prliList];
        for(Payment_Run_Line_Item__c prli : prliUpdatedList) {
            System.assertEquals(prli.Is_Email_Sent__c, true);
        }
    }
}
