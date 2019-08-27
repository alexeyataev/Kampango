String practitionersNetworkName = 'Practitioners';
List<Network> networks  = [SELECT id
    FROM Network
    WHERE Name =: practitionersNetworkName
    LIMIT 1
];

String url;
if(networks.size() != 0) {
    url = Network.getSelfRegUrl(networks[0].id);
}

List<Practitioner_Community_Settings__c> settings = [SELECT Id
    FROM Practitioner_Community_Settings__c
    LIMIT 1
];

if (settings.size()== 0) {
    Practitioner_Community_Settings__c newPractitionerCommunitySettings = new Practitioner_Community_Settings__c();
    newPractitionerCommunitySettings.Base_Url__c = url.substringBefore('/s/');
    newPractitionerCommunitySettings.SetupOwnerId = UserInfo.getOrganizationId();
    insert newPractitionerCommunitySettings;
} else{
    settings[0].Base_Url__c = url.substringBefore('/s/');
    settings[0].SetupOwnerId = UserInfo.getOrganizationId();
    update settings;
}