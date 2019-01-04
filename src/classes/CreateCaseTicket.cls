public class CreateCaseTicket {
    
    public string subject{get;set;}
    public string description{get;set;}
    public contact cont{get; set;}
    public string message{get;set;} // succcess message variable
    public string recordType{get;set;}
    public Attachment myAttachment{get;set;}
    public string fileName{get;set;} 
    public Blob fileBody{get;set;}
    public case csnum{set;get;}
    public case cs{set;get;}
    
    
    public CreateCaseTicket()
    {
        csnum = new Case();
        myAttachment =new Attachment();
    }
    

        public pageReference submit(){
        fileBody = Blob.valueOf('Swathi');
        system.debug(csnum + '   ****' + recordType);
        //csnum = new case();
        //insert csnum;
         System.debug('@@@@@Insertcase'+csnum);    
         System.debug('@@@@@fileBodytest2'+fileBody);    
         myAttachment  = new Attachment();
         Integer i=0;
         myAttachment.Body = fileBody; 
         System.debug('@@@@@Insertcase @@@@@@@'+myAttachment.Body);  
         myAttachment.Name = 'Logo_'+csnum.id+'.jpeg' ; 
         system.debug(recordType);
         integer cancelMembershipCaseCount;
         User currentUser = [SELECT Contact.id,profile.name,id FROM User where username = :UserInfo.getUsername() limit 1];
         message=''; // message setter variable
         if(recordType == 'Cancel Membership') {
              Id RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
             cancelMembershipCaseCount = [SELECT count() FROM Case where ContactId= : currentUser.Contact.id and RecordTypeId=:RecordTypeId];
             if(cancelMembershipCaseCount>=1) {
             message='you already created a case for Cancel Membership';
 			// return null;               
             }
         }
                case cs = new case();
                cs.Status = 'new';
                cs.ContactId = currentUser.Contact.id;
                cs.Subject= subject;
                cs.Description= description;
         		if(!String.isBlank(recordType))
                cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(recordType).getRecordTypeId(); 
                insert cs; 
                System.debug('Case Inserted @@@@@' +cs.Id);
                myAttachment.ParentId = cs.id;
        		myAttachment.OwnerId = currentUser.id;
                insert myAttachment;   
         csnum = [Select id,casenumber,recordType.name from case where id=:cs.id];  // get case number which is inserted newly
         message = csnum.recordType.name + ' Request has been created, case number is :'+ csnum.caseNumber; // set page message for case created
        return null;
    }
}