trigger AddJiraComments on JiraIssueComments__c (after insert,after update,before insert) {
    if(JiraSalesforceDetail__c.sObjectType.getDescribe().isAccessible() && JiraSalesforceDetail__c.getValues('Sync_SF_Comments').value__c != null){
      //  if(JiraSalesforceDetail__c.getValues('Sync_SF_Comments').value__c.toLowerCase()=='yes'){
            List<Sinergify_Trigger__c> Metdata =new List<Sinergify_Trigger__c>([SELECT Id, Name, IsActive__c FROM Sinergify_Trigger__c where Name='AddJiraComments']);
            if(!Metdata.isEmpty() && Metdata[0].IsActive__c){
                TriggerFactory.createHandler(JiraIssueComments__c.sObjectType);
            }
       // }
    }
}