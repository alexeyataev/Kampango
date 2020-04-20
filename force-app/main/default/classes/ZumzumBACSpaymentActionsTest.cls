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
    static void ZumzumBACSpaymentActionsTest_AllPurchaseInvoicesDueDateEqualsToday_ReturnedTrue() {
        Payment_Run__c paymentRunInstance = new Payment_Run__c();
        insert paymentRunInstance;


        List<Zumzum__Purchase_Invoice__c> purchaseInvoiceList = [
            SELECT Id, Zumzum__Invoice_Due_Date__c FROM Zumzum__Purchase_Invoice__c 
        ];

        System.assertEquals(2, purchaseInvoiceList.size(), 'Size should be equals 2');

        for(Zumzum__Purchase_Invoice__c purchaseInvoice : purchaseInvoiceList) {
                purchaseInvoice.Zumzum__Invoice_Due_Date__c = Date.today();
        }

        update purchaseInvoiceList;

        ZumzumBACSpaymentActions.Request request = new ZumzumBACSpaymentActions.Request();
        request.recordId = paymentRunInstance.Id;

        List<ZumzumBACSpaymentActions.Response> linkPurchaseInvoicesResponse = new List<ZumzumBACSpaymentActions.Response>();
        linkPurchaseInvoicesResponse = ZumzumBACSpaymentActions.linkPurchaseInvoices(new List<ZumzumBACSpaymentActions.Request> {request});

        System.assertEquals(true, linkPurchaseInvoicesResponse.get(0).isSuccess, 'Should be returned true');
    }

}