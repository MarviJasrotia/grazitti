global class Batch_DeleteJiraErrorLogs implements Schedulable, Database.Batchable<SObject>{
    public String LogsDuration;
    
    global  Database.QueryLocator start(Database.BatchableContext BC) {
        if(JiraSalesforceDetail__c.sObjectType.getDescribe().isAccessible()){
            LogsDuration = JiraSalesforceDetail__c.getValues('JiraErrorLogs_Duration')!=null? JiraSalesforceDetail__c.getValues('JiraErrorLogs_Duration').Value__c!=null? JiraSalesforceDetail__c.getValues('JiraErrorLogs_Duration').Value__c:'':'';
        } 
        Date errorlogdate=system.today()-Integer.valueOf(LogsDuration) ;
        return Database.getQueryLocator([SELECT Id, IsDeleted, Name FROM JiraErrorLogs__c WHERE createddate<=:errorlogdate]);
    }
    
    global void execute(Database.BatchableContext BC, List<JiraErrorLogs__c> ErrorLogsToDelete)
    {
        if(Jira_ProjectFieldsMapping__c.sObjectType.getDescribe().isAccessible() && schema.sObjectType.Jira_ProjectFieldsMapping__c.isDeletable()){
            if(ErrorLogsToDelete!=NULL && ErrorLogsToDelete.size()>0){
                delete ErrorLogsToDelete;
            }
        }
    }
    global void finish(Database.BatchableContext BC) {
       
    }
    
    global void execute (SchedulableContext SC) {
        Database.executeBatch(new Batch_DeleteJiraErrorLogs(),200);
    }
}