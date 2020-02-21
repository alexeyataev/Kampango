public with sharing class ZumzumCreatePostSalesInvoice {
    public static ISalesInvoiceCreator salesInvoiceCreator {
        get {
            if(salesInvoiceCreator == null) {
                salesInvoiceCreator = new ZumzumSalesInvoiceCreator();
            }
            return salesInvoiceCreator;
        }
        public set;
    }
    @InvocableMethod
    public static List<Zumzum__Sales_Invoice__c> createSI(List<List<ZumzumSalesInvoiceParameters>> zumzumSalesInvoiceParameterList) {
        try {
            List<ZumzumSalesInvoiceParameters> zumzumSalesInvoiceParameters = zumzumSalesInvoiceParameterList[0];
            List<Zumzum.SalesInvoicePostService.SalesInvoiceWrapper> newSalesInvoiceDataList = new List<Zumzum.SalesInvoicePostService.SalesInvoiceWrapper>();
            Zumzum.SalesInvoicePostService.SalesInvoiceWrapper salesInvoice = new Zumzum.SalesInvoicePostService.SalesInvoiceWrapper( );
            salesInvoice.LineItems = new List<Zumzum.SalesInvoicePostService.SalesInvoiceLineWrapper>();
            for(ZumzumSalesInvoiceParameters zumzumSalesInvoiceParameter : zumzumSalesInvoiceParameters) {
                salesInvoice.InvoiceDate = Date.today();
                extractCommonValues(salesInvoice, zumzumSalesInvoiceParameter);
                if(salesInvoice.WrapperAPICustomFields == null) {
                    salesInvoice.WrapperAPICustomFields = new List<Zumzum.APICustomFieldWrapper>();
                    salesInvoice.WrapperAPICustomFields.add(new Zumzum.APICustomFieldWrapper('Zumzum__Sales_Invoice__c','Booking__c', zumzumSalesInvoiceParameter.bookingId)); 
                }
                
                Zumzum.SalesInvoicePostService.SalesInvoiceLineWrapper salesInvoiceLine = new Zumzum.SalesInvoicePostService.SalesInvoiceLineWrapper();
                salesInvoiceLine.Product = zumzumSalesInvoiceParameter.productId;
                salesInvoiceLine.NominalAccount = zumzumSalesInvoiceParameter.nominalAccountId;
                salesInvoiceLine.Quantity = zumzumSalesInvoiceParameter.quantity;
                salesInvoiceLine.TaxRate = zumzumSalesInvoiceParameter.taxRateId;
                salesInvoiceLine.ForeignNetAmount = zumzumSalesInvoiceParameter.foreignNetAmount;
                salesInvoiceLine.Dimension1 = zumzumSalesInvoiceParameter.dimension1Id;
                salesInvoiceLine.Dimension2 = zumzumSalesInvoiceParameter.dimension2Id;
                salesInvoice.LineItems.add(salesInvoiceLine);
            }
            newSalesInvoiceDataList.add(salesInvoice);
            List<Zumzum__Sales_Invoice__c> newSalesInvoices = salesInvoiceCreator.createSI(newSalesInvoiceDataList);
            salesInvoiceCreator.postSI(newSalesInvoices);
            return newSalesInvoices;
        } catch(Exception e) {
            return null;
        }
    }
    private static void extractCommonValues(Zumzum.SalesInvoicePostService.SalesInvoiceWrapper salesInvoice, ZumzumSalesInvoiceParameters zumzumSalesInvoiceParameter) {
        if((salesInvoice.Customer != null && salesInvoice.Customer != zumzumSalesInvoiceParameter.customerId) ||
        (salesInvoice.TransactionCurrency != null && salesInvoice.TransactionCurrency != zumzumSalesInvoiceParameter.transactionCurrencyId)) {
            throw new ListException('Sales Invoice parameters must contain same values');
        }
        salesInvoice.Customer = zumzumSalesInvoiceParameter.customerId;
        salesInvoice.TransactionCurrency = zumzumSalesInvoiceParameter.transactionCurrencyId;
    }
}