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
                salesInvoice.Customer = salesInvoice.Customer == null ? zumzumSalesInvoiceParameter.customerId : salesInvoice.Customer;
                salesInvoice.InvoiceDate = Date.today();
                salesInvoice.TransactionCurrency = salesInvoice.TransactionCurrency == null ? zumzumSalesInvoiceParameter.transactionCurrencyId : salesInvoice.TransactionCurrency;
                
                if(salesInvoice.WrapperAPICustomFields == null) {
                    salesInvoice.WrapperAPICustomFields = new List<Zumzum.APICustomFieldWrapper>();
                    salesInvoice.WrapperAPICustomFields.add(new Zumzum.APICustomFieldWrapper('Zumzum__Sales_Invoice__c','Booking__c', zumzumSalesInvoiceParameter.bookingId)); 
                }
                
                Zumzum.SalesInvoicePostService.SalesInvoiceLineWrapper salesInvoiceLine = new Zumzum.SalesInvoicePostService.SalesInvoiceLineWrapper();
                salesInvoiceLine.Product = zumzumSalesInvoiceParameter.productId;
                salesInvoiceLine.NominalAccount = zumzumSalesInvoiceParameter.nominalAccountId;
                salesInvoiceLine.Quantity = 1;
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
}