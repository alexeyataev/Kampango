/**
*   @author:  Mahanth Garlapati
*   @description: This class holds the data required for membership journey
*
**/

public with sharing class MembershipVo {
           
    public AccountInfo accountInformation{get; set;}
    public MembershipInformation membershipDetails{get;set;}

    public class MembershipInformation{
        public String membershipSource{get;set;}
        //public list<SelectOption> membershipSourceOptions{get; set;}
        //public Membership_Type__mdt membershipInfo {get;set;}
        public Map<String, List<Membership_Type__mdt>> membershipTypeMap{get;set;}    
        public Map<String, list<sObject>> nearestBranchs {get; set;}           
        public string membershipNumber {get;set;}
        public String staffMember {get; set;}               
    }    
    
    public class AccountInfo{
       //public String accountName {get; set;}
       //public String sortCode {get; set;}
       //public String accountNumber {get; set;}  
       public Id feeAmount {get;set;}            
       public string targetCustomer{get; set;}
       public string redirectURL{get; set;}
       public String sessionProfile{get; set;}
    }    

}