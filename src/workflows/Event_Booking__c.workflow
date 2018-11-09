<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Event_Booking_Confirmation</fullName>
        <description>Event Booking Confirmation</description>
        <protected>false</protected>
        <recipients>
            <recipient>veera.pallerla@csscorp.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Event_Booking_Conformation</template>
    </alerts>
    <alerts>
        <fullName>Event_Booking_Confirmation2</fullName>
        <description>Event Booking Confirmation2</description>
        <protected>false</protected>
        <recipients>
            <recipient>veera.pallerla@csscorp.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Event_Booking_Conformation2</template>
    </alerts>
    <rules>
        <fullName>Event Booking Conformation</fullName>
        <actions>
            <name>Event_Booking_Confirmation2</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Event_Booking__c.CreatedDate</field>
            <operation>equals</operation>
            <value>TODAY</value>
        </criteriaItems>
        <description>event booking conformation mail</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
