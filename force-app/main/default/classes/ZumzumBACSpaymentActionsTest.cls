@SuppressWarnings('PMD.MethodNamingConventions')

@isTest
public class ZumzumBACSpaymentActionsTest {

    private final static String TYPE_PURCHASE_INVOICE = 'Purchase Invoice';

    @testSetup
    static void setup() {
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
        TestPurchaseInvoiceLineItemBuilder purchaseInvoiceLineItemBuilder = new TestPurchaseInvoiceLineItemBuilder();
        Zumzum__Purchase_Invoice__c pi1 = purchaseInvoiceBuilder
            .withType(TYPE_PURCHASE_INVOICE)
            .withStatus('Posted')
            .withAccount(supplierAccount.Id)
            .withContact(contact.Id)
            .withDueDate(Date.today().addDays(20))
            .withInvoiceDate(Date.today())
            .insertRecord(true)
            .build();

        Zumzum__Purchase_Invoice_Line_Item__c pili11 = purchaseInvoiceLineItemBuilder
            .withAmount(120)
            .withGross(120)
            .withGross(120)
            .withNet(120)
            .withNarrative('Doll1')
            .withQuantity(1)
            .withPurchaseInvoice(pi1.Id)
            .insertRecord(true)
            .build();

        Zumzum__Purchase_Invoice__c pi2 = purchaseInvoiceBuilder
            .withType(TYPE_PURCHASE_INVOICE)
            .withStatus('Posted')
            .withAccount(supplierAccount.Id)
            .withContact(contact.Id)
            .withDueDate(Date.today().addDays(20))
            .withInvoiceDate(Date.today())
            .insertRecord(true)
            .build();

        Zumzum__Purchase_Invoice_Line_Item__c pili21 = purchaseInvoiceLineItemBuilder
            .withAmount(120)
            .withGross(120)
            .withGross(120)
            .withNet(120)
            .withNarrative('Doll2')
            .withQuantity(1)
            .withPurchaseInvoice(pi2.Id)
            .insertRecord(true)
            .build();

        Zumzum__Purchase_Invoice__c pi3 = purchaseInvoiceBuilder
            .withType(TYPE_PURCHASE_INVOICE)
            .withStatus('Posted')
            .withAccount(supplierAccount.Id)
            .withContact(contact.Id)
            .withDueDate(Date.today().addDays(20))
            .withInvoiceDate(Date.today())
            .insertRecord(true)
            .build();

        Zumzum__Purchase_Invoice_Line_Item__c pili31 = purchaseInvoiceLineItemBuilder
            .withAmount(120)
            .withGross(120)
            .withGross(120)
            .withNet(120)
            .withNarrative('Doll3')
            .withQuantity(1)
            .withPurchaseInvoice(pi3.Id)
            .insertRecord(true)
            .build();
    
        Zumzum__Purchase_Invoice__c pi4 = purchaseInvoiceBuilder
            .withType(TYPE_PURCHASE_INVOICE)
            .withStatus('Posted')
            .withAccount(supplierAccount.Id)
            .withContact(contact.Id)
            .withDueDate(Date.today().addDays(20))
            .withInvoiceDate(Date.today())
            .insertRecord(true)
            .build();

        Zumzum__Purchase_Invoice_Line_Item__c pili41 = purchaseInvoiceLineItemBuilder
            .withAmount(120)
            .withGross(120)
            .withGross(120)
            .withNet(120)
            .withNarrative('Doll4')
            .withQuantity(1)
            .withPurchaseInvoice(pi4.Id)
            .insertRecord(true)
            .build();
 
        TestPaymentRunBuilder paymentRunBuilder = new TestPaymentRunBuilder();
        Payment_Run__c pr1 = paymentRunBuilder
            .insertLineItem(pi1.Id, true)
            .insertLineItem(pi2.Id)
            .build();
    }

    @isTest
    static void ZumzumBACSpaymentActionsTest_AllPurchaseInvoicesDueDateMoreThanTodayPlusSixDays_ReturnedFalse() {
        Payment_Run__c paymentRunInstance = new Payment_Run__c();
        insert paymentRunInstance;

       	ZumzumBACSpaymentActions.Request request = new ZumzumBACSpaymentActions.Request();
        request.recordId = paymentRunInstance.Id;

        List<ZumzumBACSpaymentActions.Response> linkPurchaseInvoicesResponse = new List<ZumzumBACSpaymentActions.Response>();
        linkPurchaseInvoicesResponse = ZumzumBACSpaymentActions.linkPurchaseInvoices(new List<ZumzumBACSpaymentActions.Request> {request});
        
        System.assertEquals(false, linkPurchaseInvoicesResponse.get(0).isSuccess, 'Should be false');
        System.assertEquals('There are no Purchase Invoices matching the action criteria',
                             linkPurchaseInvoicesResponse.get(0).message,
                             'Should be message no Purchase Invoices matching the action criteria');
    }

    @isTest
    static void ZumzumBACSpaymentActionsTest_SetAllPurchaseInvoiceDueDateToToday_ReturnedFourLinkedInvoices() {
        Payment_Run__c paymentRunInstance = new Payment_Run__c();
        insert paymentRunInstance;

        List<Zumzum__Purchase_Invoice__c> purchaseInvoiceList = [
            SELECT Id, Zumzum__Invoice_Due_Date__c FROM Zumzum__Purchase_Invoice__c 
        ];

        for(Zumzum__Purchase_Invoice__c purchaseInvoice : purchaseInvoiceList) {
                purchaseInvoice.Zumzum__Invoice_Due_Date__c = Date.today();
        }

        update purchaseInvoiceList;

        ZumzumBACSpaymentActions.Request request = new ZumzumBACSpaymentActions.Request();
        request.recordId = paymentRunInstance.Id;

        ZumzumBACSpaymentActions.linkPurchaseInvoices(new List<ZumzumBACSpaymentActions.Request> { request });
        List<Payment_Run_Line_Item__c> linkedInvoicesAfter = [
            SELECT Id FROM Payment_Run_Line_Item__c 
            WHERE Payment_Run__c = :paymentRunInstance.Id
        ];

        System.assertEquals(2, linkedInvoicesAfter.size(), 'Size should be equals 2');
    }

    @isTest
    static void TestWhenNoUnlinked_SetPaymentRun_ReturnedLinksToNewPaymentRunListEqualsNull() {
        Payment_Run__c paymentRunInstanceOne = [
                SELECT Id FROM Payment_Run__c LIMIT 1
        ];

        Payment_Run__c paymentRunInstanceTwo = new Payment_Run__c();
        insert paymentRunInstanceTwo;

        List<Zumzum__Purchase_Invoice__c> unlinkedInvoices = findUnlinkedInvoices();

        ZumzumBACSpaymentActions.Request request1 = new ZumzumBACSpaymentActions.Request();
        request1.recordId = paymentRunInstanceOne.Id;

        ZumzumBACSpaymentActions.Request request2 = new ZumzumBACSpaymentActions.Request();
        request2.recordId = paymentRunInstanceTwo.Id;

        Test.startTest();
            ZumzumBACSpaymentActions.linkPurchaseInvoices(new List<ZumzumBACSpaymentActions.Request> {request1});
            ZumzumBACSpaymentActions.linkPurchaseInvoices(new List<ZumzumBACSpaymentActions.Request> {request2});
        Test.stopTest();

        List<Payment_Run_Line_Item__c> linksToNewPaymentRun = [
            SELECT Id FROM Payment_Run_Line_Item__c WHERE Payment_Run__c = :paymentRunInstanceTwo.Id
        ];

        System.assertEquals(0, linksToNewPaymentRun.size(), 'Size should be equals 0');
    }

    private static List<Zumzum__Purchase_Invoice__c> findUnlinkedInvoices() {
        Set<Id> linkedInvoiceIds = new Set<Id>();
        for (Payment_Run_Line_Item__c item : [SELECT Id, Purchase_Invoice__c FROM Payment_Run_Line_Item__c]) {
            linkedInvoiceIds.add(item.Purchase_Invoice__c);
        }

        List<Zumzum__Purchase_Invoice__c> unlinkedInvoices = [
            SELECT Id FROM Zumzum__Purchase_Invoice__c 
            WHERE Id NOT IN :linkedInvoiceIds
        ];

        return unlinkedInvoices;
    }

}