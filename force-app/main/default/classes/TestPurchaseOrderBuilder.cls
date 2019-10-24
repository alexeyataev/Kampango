@isTest
public class TestPurchaseOrderBuilder {

	private Boolean insertRecord = false;
	private Date orderDate;
	private String status;
	private Id supplierId;
	private String type;

	public TestPurchaseOrderBuilder withType(String type) {
		this.type = type;
		return this;
	}

	public TestPurchaseOrderBuilder withStatus(String status) {
		this.status = status;
		return this;
	}

	public TestPurchaseOrderBuilder withSupplier(Id supplierId) {
		this.supplierId = supplierId;
		return this;
	}

	public TestPurchaseOrderBuilder withOrderDate(Date orderDate) {
		this.orderDate = orderDate;
		return this;
	}

	public TestPurchaseOrderBuilder insertRecord(Boolean insertRecord) {
		this.insertRecord = insertRecord;
		return this;
	}

	public Zumzum__Purchase_Order__c build(){
		Zumzum__Purchase_Order__c testPurchaseOrder = new Zumzum__Purchase_Order__c (
				Zumzum__Account__c = this.supplierId,
				Zumzum__Order_Date__c = this.orderDate,
				Zumzum__Status__c =  this.status,
				Zumzum__Type__c = this.type
		);

		if(insertRecord) {
			insert testPurchaseOrder;
		}

		return testPurchaseOrder;
	}

}
