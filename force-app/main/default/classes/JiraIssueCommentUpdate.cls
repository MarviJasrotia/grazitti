global with sharing class JiraIssueCommentUpdate implements Database.batchable<string>,Database.AllowsCallouts,Schedulable{ 
    map<string,string> keyList= new map<string,string>();
    public List<JiraErrorLogs__c> JiraLogsToInsert = new List<JiraErrorLogs__c>();
    JiraSalesforceDetail__c  setting;
    List<JiraIssueComments__c> jiraCommentListtoInsert = new List<JiraIssueComments__c>();
    List<JiraIssueComments__c> jiraCommentListtoUpdate = new List<JiraIssueComments__c>();
    global JiraIssueCommentUpdate(map<String,string> jirakeyList){
        keyList = jirakeyList; 
    }
    
    global list<string> start(Database.BatchableContext bc){ 
        if (!keyList.isEmpty()) {
            
            list<string> keyList2 = new list<string>(keyList.keyset());
            return keyList2;
        } else {
            return null; 
        }     
    } 
    
    global void execute(Database.BatchableContext bc, list<string> scope){
        map<string,string> settingMap = new Map<string,string>();
        try{ 
            for(JiraSalesforceDetail__c  setting: [select name, Value__c from JiraSalesforceDetail__c where name = 'Jira_Comment_As_Private' or name='JiraCommentQualifier']){
                settingMap.put(setting.name, setting.Value__c);
            }
            
            
            for (string key:scope){
                set<string> commentIdJira = new set<string>();
                for (JiraIssueComments__c com:[SELECT Id,CommentId__c FROM JiraIssueComments__c WHERE JiraIssue__c =: keyList.get(key)]){
                    commentIdJira.add(com.CommentId__c);
                }
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                HttpResponse response = new HttpResponse();
                request = CreateJIRAWrapper.CreateRequest('/rest/api/2/issue/'+key+'/comment','GET', 'application/json');
               
                response = http.send(request);
                
                if(response.getstatuscode()==200){
                    Map < String, Object > results = (Map < String, Object > ) JSON.deserializeUntyped(response.getBody());
                    list<object> commentList = (list<object>)results.get('comments');
                    if (!commentList.isEmpty()){
                        for (object obj:commentList){
                            
                            map<string,object> objMap = (map<string,object>)obj;
                           
                            if(settingMap.get('JiraCommentQualifier')=='' ||settingMap.get('JiraCommentQualifier')==null || string.valueOf(objMap.get('body')).stripHTMLTags().startsWithIgnoreCase(settingMap.get('JiraCommentQualifier'))){
                                JiraIssueComments__c comment = new JiraIssueComments__c();
                                if(Schema.sObjectType.JiraIssueComments__c.fields.CommentBody__c.isCreateable() &&
                                   Schema.sObjectType.JiraIssueComments__c.fields.CommentBody__c.isUpdateable()){  
                                    comment.CommentBody__c = string.valueOf(objMap.get('body')).stripHTMLTags();
                                }
                                if(Schema.sObjectType.JiraIssueComments__c.fields.CommentId__c.isCreateable() &&
                                   Schema.sObjectType.JiraIssueComments__c.fields.CommentId__c.isUpdateable()){  
                                    comment.CommentId__c = string.valueOf(objMap.get('id')); 
                                }
                                if(Schema.sObjectType.JiraIssueComments__c.fields.IsPublished__c.isCreateable() &&
                                   Schema.sObjectType.JiraIssueComments__c.fields.IsPublished__c.isUpdateable()){  
                                    if (settingMap.containskey('IsCommentPrivate') && settingMap.get('IsCommentPrivate').tolowercase() == 'yes'){
                                        comment.IsPublished__c = false;  
                                    } else{
                                        comment.IsPublished__c = true;
                                    }
                                }
                                if(Schema.sObjectType.JiraIssueComments__c.fields.JiraId__c.isCreateable() && 
                                   Schema.sObjectType.JiraIssueComments__c.fields.JiraId__c.isUpdateable()){  
                                    comment.JiraId__c=key;
                                }
                                if(Schema.sObjectType.JiraIssueComments__c.fields.JiraIssue__c.isCreateable() && 
                                   Schema.sObjectType.JiraIssueComments__c.fields.JiraIssue__c.isUpdateable()){  
                                    comment.JiraIssue__c = keyList.get(key);
                                }
                                if(Schema.sObjectType.JiraIssueComments__c.fields.UpdateAuthor__c.isCreateable() &&
                                   Schema.sObjectType.JiraIssueComments__c.fields.UpdateAuthor__c.isUpdateable()){  
                                    comment.UpdateAuthor__c = string.valueOf(((map<string,object>)objMap.get('updateAuthor')).get('displayName')); 
                                }
                                if(Schema.sObjectType.JiraIssueComments__c.fields.Author__c.isCreateable() && 
                                   Schema.sObjectType.JiraIssueComments__c.fields.Author__c.isUpdateable()){  
                                    comment.Author__c = string.valueOf(((map<string,object>)objMap.get('author')).get('displayName'));  
                                }
                                if(Schema.sObjectType.JiraIssueComments__c.fields.Comment_Added__c.isCreateable() && 
                                   Schema.sObjectType.JiraIssueComments__c.fields.Comment_Added__c.isUpdateable()){  
                                    comment.Comment_Added__c = true; 
                                }
                                if(Schema.sObjectType.JiraIssueComments__c.fields.Source__c.isCreateable() &&
                                   Schema.sObjectType.JiraIssueComments__c.fields.Source__c.isUpdateable()){  
                                    comment.Source__c = 'Jira'; 
                                }
                              
                                if(!commentIdJira.contains(string.valueOf(objMap.get('id')))){
                                    jiraCommentListtoInsert.add(comment);
                                } else {
                                    jiraCommentListtoUpdate.add(comment) ;
                                }
                            }
                        }
                    }
                    
                    if(!jiraCommentListtoInsert.isEmpty()){
                        if(schema.sObjectType.JiraSalesforceDetail__c.isupdateable() && Schema.sObjectType.Jira_Project__c.isCreateable()){
                            Database.SaveResult[] saveResultList = Database.insert(jiraCommentListtoInsert, true);
                        }
                    }
                    if(!jiraCommentListtoUpdate.isEmpty()){
                        if(schema.sObjectType.JiraSalesforceDetail__c.isupdateable() && Schema.sObjectType.Jira_Project__c.isCreateable()){
                            Database.SaveResult[] saveResultList = Database.update(jiraCommentListtoUpdate, true);
                        }
                    }
                }else{
                    JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('JiraIssueCommentUpdate',request.getEndPoint(), request.getMethod(), String.valueof(response.getstatusCode()),response.getbody(),response.getstatus(), response.getbody() , null, null, 'Execute Method', response.getbody()));   
                }
            }
        }catch(Exception ex){
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('JiraIssueCommentUpdate',null, null, null,null,null, null , null, null, 'Execute method', Error));
            
        } 
    } 
    
    global void finish(Database.BatchableContext bc){  
 
        for(CronTrigger cronTrig:[SELECT State, Id FROM CronTrigger WHERE CronJobDetail.Name like '%Jira Comment Update%' AND State='DELETED' LIMIT 100]){
            System.abortJob(cronTrig.Id);  
        }
        
        if(!JiraLogsToInsert.isEmpty()){
            Insert JiraLogsToInsert;
        }
    } 
    
    global void execute(SchedulableContext sc) {
        JiraIssueCommentUpdate JiraCommentUpdate = new JiraIssueCommentUpdate(keyList);
        Database.executeBatch(JiraCommentUpdate,1);
    }
}