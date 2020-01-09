@isTest
public class TestProductBuilder {

	private Boolean insertRecord = false;
	private Boolean isActive = true;
	private String name;

	public TestProductBuilder withName(String name) {
		this.name = name;
		return this;
	}

	public TestProductBuilder insertRecord(Boolean insertRecord) {
		this.insertRecord = insertRecord;
		return this;
	}

	public Product2 build(){
		Product2 testProduct = new Product2 (
				Name = this.name,
				IsActive = this.isActive
		);

		if(insertRecord) {
			insert testProduct;
		}

		return testProduct;
	}

}
