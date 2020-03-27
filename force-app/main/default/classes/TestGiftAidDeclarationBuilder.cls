@isTest
public with sharing class TestGiftAidDeclarationBuilder {

    private Contact contact;
    private String acquisitionMethod = 'Digital';
    private String method = 'GiftAid';
    private String postalcode;
    private String housenameOrNumber;
    private Boolean active = false;
    private Boolean insertRecord = false;

    public TestGiftAidDeclarationBuilder withContact(Contact contactInstance) {
        this.contact = contactInstance;
        return this;
    }

    public TestGiftAidDeclarationBuilder withHousenameOrNumber(String housenameOrNumber) {
        this.housenameOrNumber = housenameOrNumber;
        return this;
    }

    public TestGiftAidDeclarationBuilder withMethod(String method) {
        this.method = method;
        return this;
    }

    public TestGiftAidDeclarationBuilder withActive(Boolean isActive) {
        this.active = isActive;
        return this;
    }

    public TestGiftAidDeclarationBuilder withaAcquisitionMethod(String acquisitionMethod) {
        this.acquisitionMethod = acquisitionMethod;
        return this;
    }

    public TestGiftAidDeclarationBuilder withaPostalcode(String postalcode) {
        this.postalcode = postalcode;
        return this;
    }

    public TestGiftAidDeclarationBuilder insertRecord(Boolean insertRecord) {
        this.insertRecord = insertRecord;
        return this;
    }

    public gaid__Gift_Aid_Declaration__c build() {
        gaid__Gift_Aid_Declaration__c giftAidDeclaration = new gaid__Gift_Aid_Declaration__c (
            gaid__Contact__c = this.contact.Id,
            Method__c = this.method,
            gaid__Active__c = this.active,
            gaid__Acquisition_Method__c = this.acquisitionMethod,
            gaid__Postalcode__c = contact.MailingPostalCode,
            gaid__Housename_or_number__c = contact.MailingStreet
        );

        if(insertRecord) {
            insert giftAidDeclaration;
        }

        return giftAidDeclaration;
    }

}
