@isTest
public class TestPurchaseOrderLineItemBuilder {

	private Double amount;
	private Double gross;
	private Boolean insertRecord = false;
	private String narrative;
	private Id productId;
	private Id purchaseOrderId;
	private Integer quantity;

	public TestPurchaseOrderLineItemBuilder withProduct(Id productId) {
		this.productId = productId;
		return this;
	}

	public TestPurchaseOrderLineItemBuilder withAmount(Double amount) {
		this.amount = amount;
		return this;
	}

	public TestPurchaseOrderLineItemBuilder withPurchaseOrder(Id purchaseOrderId) {
		this.purchaseOrderId = purchaseOrderId;
		return this;
	}

	public TestPurchaseOrderLineItemBuilder withQuantity(Integer quantity) {
		this.quantity = quantity;
		return this;
	}

	public TestPurchaseOrderLineItemBuilder withGross(Double gross) {
		this.gross = gross;
		return this;
	}

	public TestPurchaseOrderLineItemBuilder withNarrative(String narrative) {
		this.narrative = narrative;
		return this;
	}

	public TestPurchaseOrderLineItemBuilder insertRecord(Boolean insertRecord) {
		this.insertRecord = insertRecord;
		return this;
	}

	public Zumzum__Purchase_Order_Line_Items__c build() {
		Zumzum__Purchase_Order_Line_Items__c testPurchaseOrderLineItems = new Zumzum__Purchase_Order_Line_Items__c(
						Zumzum__Amount__c = this.amount,
						Zumzum__Purchase_Order__c = this.purchaseOrderId,
						Zumzum__Product__c = this.productId,
						Zumzum__Quantity__c = this.quantity,
						Zumzum__Total_Gross__c = this.gross,
						Zumzum__Narrative__c = this.narrative
		);

		if(insertRecord) {
			insert testPurchaseOrderLineItems;
		}

		return testPurchaseOrderLineItems;
	}
}
