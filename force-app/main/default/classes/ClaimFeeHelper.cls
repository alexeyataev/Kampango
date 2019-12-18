public with sharing class ClaimFeeHelper {

    private static final String PURCHASE_INVOICE = 'Purchase Invoice';
    private static final String PURCHASE_CREDIT = 'Purchase Credit';
    private static final String DEFAULT_CURRENCY = 'GBP';
    private static final String PRACTITIONER_TAX_RATE = 'No VAT';

    @InvocableMethod(label='Create Purchase Invoice')
    public static void createPurchaseInvoice(List<ClaimFeeWrapper> flowData) {

        List<Session__c> sessions = flowData[0].sessions;

        Financial_Settings__c financialSettings = Financial_Settings__c.getInstance();
        User currentUser = [
            SELECT Name, AccountId, ContactId 
            FROM User WHERE Id =: UserInfo.getUserId() 
            WITH SECURITY_ENFORCED
        ];

        Zumzum__Currency__c zumzumCurrency = [
            SELECT Id
            FROM Zumzum__Currency__c 
            WHERE Zumzum__Is_Active__c = true AND Zumzum__Is_Corporate__c = true
            WITH SECURITY_ENFORCED
        ];

        Zumzum__Tax_Rate__c zumzumNoVAT = [
            SELECT Id, Name 
            FROM Zumzum__Tax_Rate__c 
            WHERE Name =: PRACTITIONER_TAX_RATE
            LIMIT 1
        ];
        
        Zumzum.PurchaseInvoiceService purchaseInvoiceService = new Zumzum.PurchaseInvoiceService();

        //Purchase Invoice
        Zumzum.PurchaseInvoiceService.PurchaseInvoiceWrapper purchaseInvoice = new Zumzum.PurchaseInvoiceService.PurchaseInvoiceWrapper();
        Zumzum.PurchaseInvoiceService.PurchaseInvoiceLineWrapper purchaseInvoiceLineItem;

        purchaseInvoice.InvoiceDate = Date.today();
        purchaseInvoice.InvoiceDueDate = Date.today();
        purchaseInvoice.SupplierName = currentUser.AccountId;
        purchaseInvoice.TransactionCurrency = zumzumCurrency.Id;
        purchaseInvoice.PurchaseInvoiceType = 'Purchase Invoice';
        purchaseInvoice.LineItems = new List<Zumzum.PurchaseInvoiceService.PurchaseInvoiceLineWrapper>();

        for (Session__c session : sessions) {
            purchaseInvoiceLineItem = new Zumzum.PurchaseInvoiceService.PurchaseInvoiceLineWrapper();
            purchaseInvoiceLineItem.NominalAccount = financialSettings.PI_Nominal_Account_Id__c;
            purchaseInvoiceLineItem.ForeignNetAmount = session.Practitioner_Fees__c;
            purchaseInvoiceLineItem.Quantity = 1;
            purchaseInvoiceLineItem.TaxRate = zumzumNoVAT.Id;
            purchaseInvoiceLineItem.Narrative = String.valueOf(session.Id);
            purchaseInvoice.LineItems.add(purchaseInvoiceLineItem);
        }

        //Purchase credit
        Zumzum.PurchaseInvoiceService.PurchaseInvoiceWrapper purchaseCredit = new Zumzum.PurchaseInvoiceService.PurchaseInvoiceWrapper();
        Zumzum.PurchaseInvoiceService.PurchaseInvoiceLineWrapper purchaseCreditLineItem = new Zumzum.PurchaseInvoiceService.PurchaseInvoiceLineWrapper();

        purchaseCredit.InvoiceDate = Date.today();
        purchaseCredit.InvoiceDueDate = Date.today();
        purchaseCredit.SupplierName = currentUser.AccountId;
        purchaseCredit.TransactionCurrency = zumzumCurrency.Id;
        purchaseCredit.PurchaseInvoiceType = PURCHASE_CREDIT;
        purchaseCredit.LineItems = new List<Zumzum.PurchaseInvoiceService.PurchaseInvoiceLineWrapper>();

        purchaseCreditLineItem.ForeignNetAmount = flowData[0].registrationFee;
        purchaseCreditLineItem.NominalAccount = financialSettings.PI_Nominal_Account_Id__c;
        purchaseCreditLineItem.Quantity = 1;
        purchaseCreditLineItem.TaxRate = zumzumNoVAT.Id;
        purchaseCreditLineItem.Narrative = 'required field';
        
        purchaseCredit.LineItems.add(purchaseCreditLineItem);

        System.debug('Purchase Invoice: ' + purchaseInvoice);
        System.debug('Purchase Credit: ' + purchaseCredit);

        Zumzum.PurchaseInvoiceService.Response objResponse = purchaseInvoiceService.createPurchaseInvoices(
            new List<Zumzum.PurchaseInvoiceService.PurchaseInvoiceWrapper>{purchaseInvoice, purchaseCredit}
        );

        System.debug('ZumzumAPI response message: ' + objResponse.ResponseMessage);

        Set<Id> purchaseInvoiceIds = new Set<Id>();

        if (objResponse.purchaseInvoices != null) {
            for (Zumzum__Purchase_Invoice__c pi : objResponse.purchaseInvoices) {
                purchaseInvoiceIds.add(pi.Id);
            }
        }

        List<Zumzum__Purchase_Invoice__c> purchaseInvoices = [
            SELECT Id, Zumzum__Type__c,
                (
                    SELECT Id, Session__c, Zumzum__Narrative__c
                    FROM Zumzum__Purchase_Invoice_Line_Items__r
                ) 
            FROM Zumzum__Purchase_Invoice__c 
            WHERE Id IN :purchaseInvoiceIds
        ];

        List<Zumzum__Purchase_Invoice_Line_Item__c> lineItemsToUpdate = new List<Zumzum__Purchase_Invoice_Line_Item__c>();

        for (Zumzum__Purchase_Invoice__c pi : purchaseInvoices) {
            if (pi.Zumzum__Type__c == PURCHASE_INVOICE) {
                for (Zumzum__Purchase_Invoice_Line_Item__c pili : pi.Zumzum__Purchase_Invoice_Line_Items__r) {
                    pili.Session__c = pili.Zumzum__Narrative__c;
                    lineItemsToUpdate.add(pili);
                }
            }
            if (pi.Zumzum__Type__c == PURCHASE_CREDIT) {
                for (Zumzum__Purchase_Invoice_Line_Item__c pili : pi.Zumzum__Purchase_Invoice_Line_Items__r) {
                    pili.Practitioner__c = currentUser.ContactId;
                    lineItemsToUpdate.add(pili);
                }
            }
        }

        System.debug('PILI to update: ' + lineItemsToUpdate);

        update lineItemsToUpdate;
    }
    
    public class ClaimFeeWrapper {

        @InvocableVariable
        public List<Session__c> sessions;
        
        @InvocableVariable
        public Decimal registrationFee;

    }
}