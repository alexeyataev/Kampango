<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Payment_Link_Email_Alert</fullName>
        <description>Payment Link Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>NCT_Templates/ETPaymentLinkExpiryTemplate</template>
    </alerts>
    <rules>
        <fullName>Payment Link Email Rule</fullName>
        <actions>
            <name>Payment_Link_Email_Alert</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This Workflow triggers when a record is created in Payment Link object and sends an email alert with an payment link.</description>
        <formula>True</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
