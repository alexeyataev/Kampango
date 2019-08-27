Network myNetwork  = [SELECT id  FROM Network WHERE Name ='Practitioners'];
String url = Network.getSelfRegUrl(myNetwork .id);
Practitioner_Community_Settings__c practitionerCommunitySettings = new Practitioner_Community_Settings__c();
practitionerCommunitySettings.Base_Url__c = url.substringBefore('/s/');
practitionerCommunitySettings.SetupOwnerId = UserInfo.getOrganizationId();
insert practitionerCommunitySettings;