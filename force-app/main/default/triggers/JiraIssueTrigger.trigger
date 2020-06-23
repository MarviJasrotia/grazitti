trigger JiraIssueTrigger on JiraIssue__c (after insert,after update) {
    List<Sinergify_Trigger__c> Metdata =new List<Sinergify_Trigger__c>([SELECT Id, Name, IsActive__c FROM Sinergify_Trigger__c where Name='JiraIssueTrigger']);
    if(!Metdata.isEmpty() && Metdata[0].IsActive__c){  
        TriggerFactory.createHandler(JiraIssue__c.sObjectType);
    }   
}