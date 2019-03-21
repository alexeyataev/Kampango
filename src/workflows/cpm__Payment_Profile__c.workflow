<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Bank_Details_changed_for_Payment_profile</fullName>
        <description>Bank Details changed for Payment profile</description>
        <protected>false</protected>
        <recipients>
            <field>cpm__Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>NCT_Templates/Bank_Details_changed</template>
    </alerts>
    <rules>
        <fullName>Payment details any one is updated parent get notify</fullName>
        <actions>
            <name>Bank_Details_changed_for_Payment_profile</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(
OR(ISCHANGED(cpm__Holder_Name__c), ISCHANGED( paybacs__Sort_Code__c ), ISCHANGED( cpm__Bank_Account__c )),
cpm__Active__c = true)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
