@SuppressWarnings('PMD.ApexCRUDViolation')
//Incident #1 - https://confluence.nct.org.uk:8443/x/EoSO
public without sharing class ClaimFeeHelper {

    private static final String PURCHASE_INVOICE = 'Purchase Invoice';
    private static final String PURCHASE_CREDIT = 'Purchase Credit';
    private static final String DEFAULT_CURRENCY = 'GBP';
    private static final String PRACTITIONER_TAX_RATE = 'No VAT';
    private static final String API_SUCCESS_MESSAGE = 'Success';

    @InvocableMethod(label='Create Purchase Invoice')
    public static void createPurchaseInvoice(List<ClaimFeeWrapper> flowData) {
        
        List<Session__c> sessions = flowData[0].sessions;
        
        Financial_Settings__c financialSettings = Financial_Settings__c.getInstance();
        User currentUser = [
            SELECT Name, AccountId, ContactId 
            FROM User 
            WHERE Id =: UserInfo.getUserId()
            WITH SECURITY_ENFORCED
        ];

        Zumzum__Currency__c zumzumCurrency = [
            SELECT Id
            FROM Zumzum__Currency__c 
            WHERE Name =: DEFAULT_CURRENCY
            WITH SECURITY_ENFORCED
        ];

        Zumzum__Tax_Rate__c zumzumNoVAT = [
            SELECT Id, Name 
            FROM Zumzum__Tax_Rate__c 
            WHERE Name =: PRACTITIONER_TAX_RATE
            WITH SECURITY_ENFORCED
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

        Zumzum.PurchaseInvoiceService.Response objResponse = purchaseInvoiceService.createPurchaseInvoices(
            new List<Zumzum.PurchaseInvoiceService.PurchaseInvoiceWrapper>{purchaseInvoice, purchaseCredit}
        );

        if (!objResponse.ResponseMessage.equals(API_SUCCESS_MESSAGE)) {
            throw new CreatePurchaseInvoiceException(objResponse.ResponseMessage);
        }

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
            WITH SECURITY_ENFORCED
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

        try {
            update lineItemsToUpdate;
        } catch (DmlException ex) {
            throw new ClaimFeeHelper.CreatePurchaseInvoiceException(ex.getMessage());
        }

        postPurchaseInvoices(purchaseInvoices);
    }

    private static void postPurchaseInvoices(List<Zumzum__Purchase_Invoice__c> invoices) {
        Zumzum.PurchaseInvoiceService postService = new Zumzum.PurchaseInvoiceService();
        for (Zumzum__Purchase_Invoice__c pi : invoices) {
            postService.postPurchaseInvoice(pi.Id);
        }
    }
    
    public class ClaimFeeWrapper {

        @InvocableVariable
        public List<Session__c> sessions;
        
        @InvocableVariable
        public Decimal registrationFee;

    }
    public class CreatePurchaseInvoiceException extends Exception {}
}