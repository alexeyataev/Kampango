@IsTest
public class TestPurchaseInvoiceLineItemBuilder {

	private Decimal amount;
	private Decimal totalAmount;
	private Decimal gross;
	private Boolean insertRecord = false;
	private String narrative;
	private Decimal net;
	private Id purchaseInvoiceId;
	private Integer quantity;
	
	public TestPurchaseInvoiceLineItemBuilder withAmount(Decimal amount) {
		this.amount = amount;
		return this;
	}

	public TestPurchaseInvoiceLineItemBuilder withTotalAmount(Decimal totalAmount) {
		this.totalAmount = totalAmount;
		return this;
	}

	public TestPurchaseInvoiceLineItemBuilder withPurchaseInvoice(Id purchaseInvoiceId) {
		this.purchaseInvoiceId = purchaseInvoiceId;
		return this;
	}

	public TestPurchaseInvoiceLineItemBuilder withQuantity(Integer quantity) {
		this.quantity = quantity;
		return this;
	}

	public TestPurchaseInvoiceLineItemBuilder withGross(Decimal gross) {
		this.gross = gross;
		return this;
	}

	public TestPurchaseInvoiceLineItemBuilder withNet(Decimal net) {
		this.net = net;
		return this;
	}

	public TestPurchaseInvoiceLineItemBuilder withNarrative(String narrative) {
		this.narrative = narrative;
		return this;
	}

	public TestPurchaseInvoiceLineItemBuilder insertRecord(Boolean insertRecord) {
		this.insertRecord = insertRecord;
		return this;
	}

	public Zumzum__Purchase_Invoice_Line_Item__c build(){
		Zumzum__Purchase_Invoice_Line_Item__c testPurchaseInvoiceLineItem = new Zumzum__Purchase_Invoice_Line_Item__c (
				Zumzum__Quantity__c = this.quantity,
				Zumzum__Amount__c = this.amount,
				Zumzum__Total_Amount__c = this.totalAmount,
				Zumzum__Total_Net__c = this.net,
				Zumzum__Narrative__c = this.narrative,
				Zumzum__Purchase_Invoice__c = this.purchaseInvoiceId,
				Zumzum__Total_Gross__c = this.gross
		);

		if(insertRecord) {
			insert testPurchaseInvoiceLineItem;
		}

		return testPurchaseInvoiceLineItem;
	}
}
