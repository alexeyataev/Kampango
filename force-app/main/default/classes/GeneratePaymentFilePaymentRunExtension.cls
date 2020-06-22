@SuppressWarnings('PMD.ApexCRUDViolation')
//Incident #11 - https://confluence.nct.org.uk:8443/x/EoSO
public with sharing class GeneratePaymentFilePaymentRunExtension {

	// public Boolean showError { get; set;}
	// public String pageContent;
	// public String contentType;

    // private Id recordId;
    // private Payment_Run__c paymentRun;
	// private final String VALID_PAYMENT_RUN_STATUS = 'Ready';
	// private final String TXT_CONTENT_TYPE = 'text/plain#';
	// private final String HTML_CONTENT_TYPE = 'text/html';

	// public GeneratePaymentFilePaymentRunExtension(ApexPages.StandardController stdController){
	// 	this.recordId = stdController.getId();
	// }

	// public virtual void init(){
	// 	Payment_Run__c paymentRun = [
    //         SELECT Id, Status__c,
    //         (
    //             SELECT Id, Payment_Run__c, Zumzum__Bank_Payment__c, Zumzum__Purchase_Invoice__r.Name
    //             FROM Bank_Payment_Line_Items__r
    //         )
    //         FROM Payment_Run__c
    //         WHERE Id =: recordId
    //     ];

    //     this.paymentRun = paymentRun;
        
	// 	this.showError = paymentRun.Status__c != VALID_PAYMENT_RUN_STATUS;

	// 	if(this.showError) {
	// 		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Payment Run should be ready to generate Payment File'));
	// 	}
	// }

	// public String getPageContent(){
	// 	return this.showError ? '' : GeneratePaymentFileUtil.generatePaymentFileContent(paymentRun);
	// }

	// public String getContentType(){
	// 	return this.showError ? HTML_CONTENT_TYPE : TXT_CONTENT_TYPE + GeneratePaymentFileUtil.generatePaymentFileName();
	// }

}