public with sharing class MembershipCrudHelperVo {
        public String accountName {get; set;}
        public String sortCode {get; set;}
        public String accountNumber {get; set;}
        public String acquistion {get;set;}
        public String membershipSource{get;set;}
        public boolean isVolunteer {get; set;}
        public Contact pcont{set; get;}
        public Contact scont{set; get;}
    
    public class MembershipUtilitiesVo{
        public Id feeAmount {get;set;}
        public String recordType{get; set;}
        public String acquistion {get;set;}
        public string eDate{get;set;}
    }
}