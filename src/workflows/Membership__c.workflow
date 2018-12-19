<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Due_Amount_Calculation</fullName>
        <field>Subscription_Due_Total__c</field>
        <formula>If (ISPICKVAL(subscription_plan__c,&apos;6 Month Plan&apos;),2000/6,
    If(ISPICKVAL(subscription_plan__c,&apos;3 Month Plan&apos;),2000/3,
    If(ISPICKVAL(subscription_plan__c,&apos;12 Month Plan&apos;),2000/12,0)))</formula>
        <name>Due Amount Calculation</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
</Workflow>
