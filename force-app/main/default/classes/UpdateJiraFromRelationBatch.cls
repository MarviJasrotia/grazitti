global with Sharing class UpdateJiraFromRelationBatch implements Database.Batchable<sObject>,  Database.AllowsCallouts { 
    Map<String,Map<String,Set<String>>> UpdateJiraToObjectToObjectIds = new Map<String,Map<String,Set<String>>>();
    public List<JiraErrorLogs__c> JiraLogsToInsert = new List<JiraErrorLogs__c>();
    
    public UpdateJiraFromRelationBatch(Map<String,Map<String,Set<String>>> UpdateJiraToObjectToObjectIds){
        this.UpdateJiraToObjectToObjectIds=UpdateJiraToObjectToObjectIds;
    }
    
    global List<JiraIssue__c> start(Database.BatchableContext BC){
        Set<String> JiraIds = new Set<String>();
        JiraIds=UpdateJiraToObjectToObjectIds.keySet();
        String query = 'SELECT id,IssueKey__c FROM Jiraissue__c WHERE name in:JiraIds';
        return Database.query(query) ;
    }
    
    global void execute(Database.BatchableContext BC, List<JiraIssue__c> scope){
        
        for(JiraIssue__c ji : scope){
            String Finalbody='';
            for(String Fieldname:UpdateJiraToObjectToObjectIds.get(ji.IssueKey__c).keySet()){
                String Body='';
                for(String Ids:UpdateJiraToObjectToObjectIds.get(ji.IssueKey__c).get(Fieldname)){
                    Body+=Ids+'\r\n' ;
                }
                Body='"'+Fieldname+'":"'+Body.escapeJava()+ '"';
                if(Finalbody!=''){
                    Finalbody=Finalbody+','+Body;
                }else{
                    Finalbody=Body;
                }
            }
            
            if(Finalbody!=''&& Finalbody!=null){
                Finalbody='{"fields":{'+Finalbody +'}}';
                HttpRequest req = new HttpRequest(); 
                req = CreateJIRAWrapper.CreateRequest('/rest/api/2/issue/'+ji.IssueKey__c,'PUT','application/json');
                req.setBody(Finalbody);    
                Http http = new Http();
                HTTPResponse res;
                try {
                    res = http.send(req); 
                    if(res.getStatusCode()==204){
                    }else{
                        JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('UpdateJiraFromRelationBatch',req.getEndpoint(), req.getMethod(),String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), null, res.getbody(), ji.id, 'Update IssueKey', res.getBody()));
                        
                    }
                }catch(Exception ex){
                    String Error=ex.getMessage();
                    JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('UpdateJiraFromRelationBatch',req.getEndpoint(), req.getMethod(),String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), null, res.getbody(), ji.id, 'Update IssueKey', Error));
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){
        if(!JiraLogsToInsert.isEmpty()){
            Insert JiraLogsToInsert;
        }
    }
}