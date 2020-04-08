@SuppressWarnings('PMD.ApexCRUDViolation')
/** As @SupressWarning annotation cannot be added along with @Invocable one
  * it was decided to add PMD.ApexCRUDViolation annotation to whole class
  * Incident #32 - https://confluence.nct.org.uk:8443/x/EoSO 
*/

public with sharing class ClaimFeeHelper {

    private static final String PURCHASE_INVOICE = 'Purchase Invoice';
    private static final String PURCHASE_CREDIT = 'Purchase Credit';
    private static final String DEFAULT_CURRENCY = 'GBP';
    private static final String PRACTITIONER_TAX_RATE = 'No VAT';
    private static final String API_SUCCESS_MESSAGE = 'Success';
    private static final String LINKING_ERROR_EMAIL_TEMPLATE = 'Practitioner_Registration_Fee_Claim_Error';
    private static final String TEMPLATE_PC = '{!PC}';
    private static final String TEMPLATE_PI = '{!PI}';
    private static final String PI_NARRATIVE = 'Fee Claim';
    private static final String PC_NARRATIVE = 'Registration Fees deduction';
    private static Map<String, String> statusInvoiceMap;

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

        Map<String, Id> dimensionsMap = getDimensionsMap();
        
        Zumzum.PurchaseInvoiceService purchaseInvoiceService = new Zumzum.PurchaseInvoiceService();
        List<Zumzum.PurchaseInvoiceService.PurchaseInvoiceWrapper> purchases = new List<Zumzum.PurchaseInvoiceService.PurchaseInvoiceWrapper>();
        
        //Purchase Invoice
        Zumzum.PurchaseInvoiceService.PurchaseInvoiceWrapper purchaseInvoice = new Zumzum.PurchaseInvoiceService.PurchaseInvoiceWrapper();
        Zumzum.PurchaseInvoiceService.PurchaseInvoiceLineWrapper purchaseInvoiceLineItem;

        purchaseInvoice.InvoiceDate = Date.today();
        purchaseInvoice.InvoiceDueDate = Date.today();
        purchaseInvoice.SupplierAccount = currentUser.AccountId;
        purchaseInvoice.TransactionCurrency = zumzumCurrency.Id;
        purchaseInvoice.PurchaseInvoiceType = PURCHASE_INVOICE;
        purchaseInvoice.LineItems = new List<Zumzum.PurchaseInvoiceService.PurchaseInvoiceLineWrapper>();

        for (Session__c session : sessions) {
            purchaseInvoiceLineItem = new Zumzum.PurchaseInvoiceService.PurchaseInvoiceLineWrapper();
            purchaseInvoiceLineItem.NominalAccount = financialSettings.PI_Nominal_Account_Id__c;
            purchaseInvoiceLineItem.ForeignNetAmount = session.Practitioner_Fees__c;
            purchaseInvoiceLineItem.Quantity = 1;
            purchaseInvoiceLineItem.TaxRate = zumzumNoVAT.Id;
            purchaseInvoiceLineItem.Narrative = PI_NARRATIVE;
            purchaseInvoiceLineItem.WrapperAPICustomFields = new Zumzum.APICustomFieldWrapper[]{
                new Zumzum.APICustomFieldWrapper('Zumzum__Purchase_Invoice_Line_Item__c', 'Session__c', session.Id)
            };
            purchaseInvoiceLineItem.Dimension1 = 
                String.isNotBlank(session.PSA_Area__c) ? dimensionsMap.get(session.PSA_Area__c) : null;
            purchaseInvoiceLineItem.Dimension2 = 
                String.isNotBlank(session.Course__c) ? dimensionsMap.get(session.Course__c) : null;

            purchaseInvoice.LineItems.add(purchaseInvoiceLineItem);
        }
    
        purchases.add(purchaseInvoice);
        
        //Purchase credit
        Boolean isPurchaseCreditNeeded = flowData[0].registrationFee > 0;
        if (isPurchaseCreditNeeded) {
            Zumzum.PurchaseInvoiceService.PurchaseInvoiceWrapper purchaseCredit = new Zumzum.PurchaseInvoiceService.PurchaseInvoiceWrapper();
            Zumzum.PurchaseInvoiceService.PurchaseInvoiceLineWrapper purchaseCreditLineItem = new Zumzum.PurchaseInvoiceService.PurchaseInvoiceLineWrapper();

            purchaseCredit.InvoiceDate = Date.today();
            purchaseCredit.InvoiceDueDate = Date.today();
            purchaseCredit.SupplierAccount = currentUser.AccountId;
            purchaseCredit.TransactionCurrency = zumzumCurrency.Id;
            purchaseCredit.PurchaseInvoiceType = PURCHASE_CREDIT;
            purchaseCredit.LineItems = new List<Zumzum.PurchaseInvoiceService.PurchaseInvoiceLineWrapper>();

            purchaseCreditLineItem.ForeignNetAmount = flowData[0].registrationFee;
            purchaseCreditLineItem.NominalAccount = financialSettings.PC_Nominal_Account_Id__c;
            purchaseCreditLineItem.Quantity = 1;
            purchaseCreditLineItem.TaxRate = zumzumNoVAT.Id;
            purchaseCreditLineItem.Narrative = PC_NARRATIVE;
            purchaseCreditLineItem.WrapperAPICustomFields = new Zumzum.APICustomFieldWrapper[]{
                new Zumzum.APICustomFieldWrapper('Zumzum__Purchase_Invoice_Line_Item__c', 'Practitioner__c', currentUser.ContactId)
            };
            purchaseCredit.LineItems.add(purchaseCreditLineItem);
            purchases.add(purchaseCredit);
        }

        Zumzum.PurchaseInvoiceService.Response objResponse = purchaseInvoiceService.createPurchaseInvoices(purchases);

        if (!objResponse.ResponseMessage.equals(API_SUCCESS_MESSAGE)) {
            throw new CreatePurchaseInvoiceException(objResponse.ResponseMessage);
        }
        updatePurchaseInvoicesContact(objResponse.purchaseInvoices, currentUser);

        postPurchaseInvoices(objResponse.purchaseInvoices);
        List<Id> invoices = new List<Id>();
        for (Zumzum__Purchase_Invoice__c pi : objResponse.purchaseInvoices) {
            invoices.add(pi.Id);
        } 
        allocateSupplierBalance(invoices);
    }

    private static void postPurchaseInvoices(List<Zumzum__Purchase_Invoice__c> invoices) {
        Zumzum.PurchaseInvoiceService postService = new Zumzum.PurchaseInvoiceService();
        for (Zumzum__Purchase_Invoice__c pi : invoices) {
            Zumzum.PurchaseInvoiceService.Response apiResponse = postService.postPurchaseInvoice(pi.Id);
            if (!apiResponse.ResponseMessage.equals(API_SUCCESS_MESSAGE)) {
                throw new CreatePurchaseInvoiceException(apiResponse.ResponseMessage);
            }
        }
    }

    @future
    private static void allocateSupplierBalance(List<Id> invoiceIds) {
        Financial_Settings__c financialSettings = Financial_Settings__c.getInstance();

        User currentUser = [
            SELECT Name, AccountId, ContactId 
            FROM User 
            WHERE Id =: UserInfo.getUserId()
            WITH SECURITY_ENFORCED
        ];

        Zumzum.BankAllocateCreditsAndPaymentsService paymentService = new Zumzum.BankAllocateCreditsAndPaymentsService();
        Zumzum.BankAllocateCreditsAndPaymentsService.BankAllocateCreditsAndPaymentsWrapper allocatedCreditWrapper = 
            new Zumzum.BankAllocateCreditsAndPaymentsService.BankAllocateCreditsAndPaymentsWrapper();

        allocatedCreditWrapper.AccountId = currentUser.AccountId;
        allocatedCreditWrapper.PostingDate = Date.today();
        
        List<Zumzum__Ledger__c> ledgerRecords = [
            SELECT Id, Name, Zumzum__Net_Amount__c, Zumzum__Purchase_Invoice__r.Zumzum__Type__c, Zumzum__Nominal_Name__c, Zumzum__Nominal__c, Zumzum__Sub_Account_Nominal_Link__c
            FROM Zumzum__Ledger__c
            WHERE Zumzum__Purchase_Invoice__c IN :invoiceIds
                AND Zumzum__Customer_Supplier_Account_Name__c != null
        ];

        List<Zumzum.BankAllocateCreditsAndPaymentsService.BankAllocateCreditsAndPaymentsLineWrapper> paymentLines = new List<Zumzum.BankAllocateCreditsAndPaymentsService.BankAllocateCreditsAndPaymentsLineWrapper>();
        Zumzum.BankAllocateCreditsAndPaymentsService.BankAllocateCreditsAndPaymentsLineWrapper bankLineItem;

        Decimal creditAmount = 0.00;
        Integer invoicesCount = 0;
        for (Zumzum__Ledger__c ledgerRecord : ledgerRecords) {
            if (ledgerRecord.Zumzum__Purchase_Invoice__r.Zumzum__Type__c == PURCHASE_CREDIT) {
                creditAmount = ledgerRecord.Zumzum__Net_Amount__c;
            } else if (ledgerRecord.Zumzum__Purchase_Invoice__r.Zumzum__Type__c == PURCHASE_INVOICE) {
                invoicesCount++;
            }
        }
        Decimal partialAllocation = (creditAmount / invoicesCount).setScale(2);
        Decimal runningTotal = 0.00;
        Decimal amountDifference = 0.00;
        Integer runningCount = 0;
        for (Zumzum__Ledger__c ledgerRecord : ledgerRecords) {
            if (ledgerRecord.Zumzum__Purchase_Invoice__r.Zumzum__Type__c == PURCHASE_CREDIT) {
                bankLineItem = new Zumzum.BankAllocateCreditsAndPaymentsService.BankAllocateCreditsAndPaymentsLineWrapper();
                bankLineItem.LedgerName = ledgerRecord.Name;
                bankLineItem.Amount = creditAmount;
                paymentLines.add(bankLineItem);
            } else if (ledgerRecord.Zumzum__Purchase_Invoice__r.Zumzum__Type__c == PURCHASE_INVOICE) {
                runningCount++;
                bankLineItem = new Zumzum.BankAllocateCreditsAndPaymentsService.BankAllocateCreditsAndPaymentsLineWrapper();
                bankLineItem.LedgerName = ledgerRecord.Name;
                bankLineItem.Amount = partialAllocation;
                runningTotal += partialAllocation;
                if(invoicesCount == runningCount && runningTotal != creditAmount) {
                    amountDifference = creditAmount - runningTotal;
                    if(amountDifference > 0) {
                        bankLineItem.Amount = partialAllocation + amountDifference;
                    } else {
                        bankLineItem.Amount = partialAllocation - amountDifference;
                    }
                }
                paymentLines.add(bankLineItem);
            }
        }
        
        allocatedCreditWrapper.BankAllocateLines = paymentLines;
        Zumzum.BankAllocateCreditsAndPaymentsService.Response objResponse = paymentService.bankAllocateSupplierBalance(allocatedCreditWrapper);
        if (!objResponse.ResponseMessage.equals(API_SUCCESS_MESSAGE)) {
            sendEmailToFinance(invoiceIds);
        }
    }

    private static void sendEmailToFinance(List<Id> invoiceIds) {
        if (!TestEmailUtility.emailsFeatureEnabled()) {
            return;
        }
        if (statusInvoiceMap == null || statusInvoiceMap.isEmpty()) {
            setStatusInvoiceMap(invoiceIds);
        }
        Financial_Settings__c financialSettings = Financial_Settings__c.getInstance();
        if (financialSettings.Error_Notification_To__c == null) {
            return;
        }
        EmailTemplate template = [
            SELECT Id, HtmlValue, Body, Subject 
            FROM EmailTemplate 
            WHERE DeveloperName =: LINKING_ERROR_EMAIL_TEMPLATE
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        String htmlBody = getReplacedBody(template.HtmlValue);
        String plainTextBody = getReplacedBody(template.Body);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] { financialSettings.Error_Notification_To__c };
        mail.setToAddresses(toAddresses);
        mail.setReplyTo(financialSettings.Error_Notification_To__c);
        mail.setSubject(template.Subject);
        mail.setHtmlBody(htmlBody);
        mail.setPlainTextBody(plainTextBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    private static Map<String, Id> getDimensionsMap() {
        List<Zumzum__Dimension__c> dimensions = [
            SELECT Name, Id
            FROM Zumzum__Dimension__c
            WHERE Zumzum__Active__c = true
        ];

        Map<String, Id> dimensionsMap = new Map<String, Id>();
        for (Zumzum__Dimension__c dimension : dimensions) {
            dimensionsMap.put(dimension.Name, dimension.Id);
        }
        return dimensionsMap;
    }

    private static void setStatusInvoiceMap(List<Id> invoiceIds) {
        List<Zumzum__Purchase_Invoice__c> invoices = [
            SELECT Id, Name, Zumzum__Type__c
            FROM Zumzum__Purchase_Invoice__c
            WHERE Id IN :invoiceIds
            WITH SECURITY_ENFORCED
        ];
        statusInvoiceMap =  new Map<String, String>();
        for (Zumzum__Purchase_Invoice__c pi : invoices) {
            if (pi.Zumzum__Type__c == PURCHASE_CREDIT) {
                statusInvoiceMap.put(PURCHASE_CREDIT, pi.Name);
            } else {
                statusInvoiceMap.put(PURCHASE_INVOICE, pi.Name);
            }
        }
    }

    private static void updatePurchaseInvoicesContact(List<Zumzum__Purchase_Invoice__c> purchases, User current) {
        for (Zumzum__Purchase_Invoice__c pi : purchases) {
            if (pi.Zumzum__Type__c == PURCHASE_INVOICE) {
                pi.Zumzum__Contact__c = current.ContactId;
            }
        }
        update purchases;
    }

    private static String getReplacedBody(String templateText) {
        String body = templateText.replace(TEMPLATE_PC, statusInvoiceMap.get(PURCHASE_CREDIT))
                                  .replace(TEMPLATE_PI, statusInvoiceMap.get(PURCHASE_INVOICE));
        return body;
    }
    
    public class ClaimFeeWrapper {

        @InvocableVariable
        public List<Session__c> sessions;
        
        @InvocableVariable
        public Decimal registrationFee;

    }
    public class CreatePurchaseInvoiceException extends Exception {}
}