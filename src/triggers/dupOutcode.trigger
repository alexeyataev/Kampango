trigger dupOutcode on PostCode_Allocation__c (before insert, before update) {
    
   dupOutcodeHandler doh = new dupOutcodeHandler();
       
   if(Trigger.isBefore&&(Trigger.isInsert||Trigger.isUpdate)){
   
        doh.onBeforeInsertUpdate(Trigger.new);
    
   }

}