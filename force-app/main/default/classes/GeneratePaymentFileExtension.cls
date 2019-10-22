@SuppressWarnings('PMD.ApexCRUDViolation')
//Incident #11 - https://confluence.nct.org.uk:8443/x/EoSO
public with sharing class GeneratePaymentFileExtension {

	public Boolean showError { get; set;}
	public String pageContent;
	public String contentType;

	private Id recordId;
	private static final String VALID_BATCH_BANK_PAYMENT_STATUS = 'Approved';
	private static final String TXT_CONTENT_TYPE = 'text/plain#';
	private static final String HTML_CONTENT_TYPE = 'text/html';

	public GeneratePaymentFileExtension(ApexPages.StandardController stdController){
		this.recordId = stdController.getId();
	}

	public void init(){
		Zumzum__Batch_Bank_Payment__c batchBankPayment = [
				SELECT id, Zumzum__Status__c
				FROM Zumzum__Batch_Bank_Payment__c
				WHERE id = :this.recordId
				WITH SECURITY_ENFORCED
		]; 
		
		this.showError = batchBankPayment.Zumzum__Status__c != VALID_BATCH_BANK_PAYMENT_STATUS;

		if(this.showError) {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Generate_Payment_File_Invalid_Batch_Bank_Payment_Status_Message));
		}
	}

	public String getPageContent(){
		return this.showError ? '' : GeneratePaymentFileUtil.generatePaymentFileContent(this.recordId);
	}

	public String getContentType(){
		return this.showError ? HTML_CONTENT_TYPE : TXT_CONTENT_TYPE + GeneratePaymentFileUtil.generatePaymentFileName();
	}

}
