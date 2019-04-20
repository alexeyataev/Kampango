/**
*   @author:  Mahanth Garlapati
*   @description: This class holds the data required for membership journey
*
**/

public with sharing class MembershipVo {

        public String membershipSource{get;set;}
        public list<SelectOption> membershipSourceOptions{get; set;}
        public Membership_Type__mdt membershipInfo {get;set;}
        public Map<String, List<Membership_Type__mdt>> membershipTypeMap{get;set;} 
        public string membershipNumber {get;set;}
        public Map<String, list<sObject>> nearestBranchs {get; set;}                          
        public String accountName {get; set;}
        public String sortCode {get; set;}
        public String accountNumber {get; set;}     
        public Id feeAmount {get;set;}
        public String recordType{get; set;}
        public String acquistion {get;set;}
        public string eDate{get;set;}

}