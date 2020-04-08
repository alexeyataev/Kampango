@isTest
public class ZumzumBACSpaymentActionsTest {

    private final static String TYPE_PURCHASE_INVOICE = 'Purchase Invoice';


	@testSetup
    static void setup() {
        TestAccountBuilder accountBuilder = new TestAccountBuilder();
        Account supplierAccount = accountBuilder.WithRecordType('Organization')
                .withName('Tom Genet')
                .withType('Supplier')
                .withAccountNumber('869344')
                .withBillingEmail('tets@gmail.com')
                .withBankSortCode('572899')
                .withBankAccountNumber('03456123')
                .withBankAccountName('TEST BANK ACCOUNT')
                .insertRecord(true)
                .build();
        Account account = accountBuilder
                .withRecordType('Household Account')
                .withBranchNumber('777')
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
    static void testLinkInvoicesAll() {
        Payment_Run__c pr2 = new Payment_Run__c();
        insert pr2;
        List<Zumzum__Purchase_Invoice__c> unlinkedInvoicesBefore = findUnlinkedInvoices();
       	ZumzumBACSpaymentActions.Request request = new ZumzumBACSpaymentActions.Request();
        request.recordId = pr2.Id;
        
        ZumzumBACSpaymentActions.linkPurchaseInvoices(new List<ZumzumBACSpaymentActions.Request> {request});
        
        List<Payment_Run_Line_Item__c> linkedInvoicesAfter = [
          	SELECT Id FROM Payment_Run_Line_Item__c 
            WHERE Payment_Run__c = :pr2.Id
        ];
        System.assertEquals(unlinkedInvoicesBefore.size(), linkedInvoicesAfter.size());
    }
    
    @isTest
    static void testLinkInvoicesPart() {
        Payment_Run__c pr1 = [
            SELECT Id FROM Payment_Run__c LIMIT 1
        ];
        List<Payment_Run_Line_Item__c> itemsBefore = [
          	SELECT Id FROM Payment_Run_Line_Item__c 
            WHERE Payment_Run__c = :pr1.Id
        ];
       	ZumzumBACSpaymentActions.Request request = new ZumzumBACSpaymentActions.Request();
        request.recordId = pr1.Id;
        
        ZumzumBACSpaymentActions.linkPurchaseInvoices(new List<ZumzumBACSpaymentActions.Request> {request});
        
        List<Payment_Run_Line_Item__c> itemsAfter = [
          	SELECT Id FROM Payment_Run_Line_Item__c 
            WHERE Payment_Run__c = :pr1.Id
        ];
        System.assert(itemsBefore.size() < itemsAfter.size());
    }
    
    @isTest
    static void testLinkWhenNoUnlinked() {
        Payment_Run__c pr1 = [
            SELECT Id FROM Payment_Run__c LIMIT 1
        ];
		Payment_Run__c pr2 = new Payment_Run__c();
        insert pr2;
        List<Zumzum__Purchase_Invoice__c> unlinkedInvoices = findUnlinkedInvoices();
        
        ZumzumBACSpaymentActions.Request request1 = new ZumzumBACSpaymentActions.Request();
        request1.recordId = pr1.Id;
        ZumzumBACSpaymentActions.Request request2 = new ZumzumBACSpaymentActions.Request();
        request2.recordId = pr2.Id;
        Test.startTest();
        
        ZumzumBACSpaymentActions.linkPurchaseInvoices(new List<ZumzumBACSpaymentActions.Request> {request1});
        ZumzumBACSpaymentActions.linkPurchaseInvoices(new List<ZumzumBACSpaymentActions.Request> {request2});
        
        Test.stopTest();
        List<Payment_Run_Line_Item__c> linksToNewPaymentRun = [
            SELECT Id FROM Payment_Run_Line_Item__c WHERE Payment_Run__c = :pr2.Id
        ];
        System.assertEquals(0, linksToNewPaymentRun.size());
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