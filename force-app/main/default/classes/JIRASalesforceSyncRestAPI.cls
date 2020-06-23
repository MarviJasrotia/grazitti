/*******************************************************************************
Created By: @Grazitti
Purpose: 
- This class has been exposed to JIRA environment to get the response from WebHook whenever a JIRA is updated.

***************************************************************************************/

@RestResource(urlMapping='/webhook/JIRA/*')
global without sharing class JIRASalesforceSyncRestAPI{
    
    /**
* if webhookEvent =
* projet_deleted Delete the project instance in salesforce and update all the related issues with Deleted_in_JIRA__c as true.
* projet_updated Update the project instace in salesforce and also update all the related issues with new project name followed by the old no. (OP-1 to NP-1) 
* jira:issue_deleted  update the related issues with Deleted_in_JIRA__c as true.
* comment_deleted Does nothing.
* 
* if Jira is updated , we update jira issue in salesforce
* if new  comment is inserted in jira, comments are inserted in salesforce as case comments and if sync is on in admin settings,
* comments are  inserted in salesforce as jiraissue comments
* 
*/
    @HttpPost
    global static void linkJiraIssueToSalesforceCase(){
        String bodyString;
        String strbody;
        
        try{ 
            
            String orgId = UserInfo.getOrganizationId();
            if(!orgId.contains(RestContext.request.params.get('orgId')) && !Test.IsrunningTest()) return;
            
            if(!Jira_ProjectFieldsMapping__c.sObjectType.getDescribe().isAccessible() || !JiraRelationship__c.sObjectType.getDescribe().isAccessible() || !Jira_Project__c.sObjectType.getDescribe().isAccessible() || !JiraIssue__c.sObjectType.getDescribe().isAccessible()){return;}
            
            RestRequest req = RestContext.request;  
            Blob body = req.requestBody;
            bodyString = body.toString();
            
            
            Map<String, Object> WebhookJsonMap = (Map<String, Object>)JSON.deserializeUntyped(bodyString);
            
            
            Decimal jiraId;
            if(RestContext.request.params.get('jiraId')!=null && RestContext.request.params.get('jiraId')!='')
            {
                jiraId = Decimal.valueOf(RestContext.request.params.get('jiraId'));
            }
            String commentId = RestContext.request.params.get('commentId');
            String jiraKey = RestContext.request.params.get('jirakey');
            
            
            if('project_deleted'.equals(WebhookJsonMap.get('webhookEvent'))){
                map<string,Object> webhookprojectMap= (map<string,Object>)WebhookJsonMap.get('project'); 
                String Proid=String.valueof(webhookprojectMap.get('id'));
                
                Jira_Project__c projectMappingInstance = [select Id, Name, ProjectId__c, ProjectKey__c 
                                                          from Jira_Project__c where ProjectId__c = :Proid];
                
                if(JiraIssue__c.sObjectType.getDescribe().isAccessible() && JiraIssue__c.sObjectType.getDescribe().isUpdateable() ){
                    List<JiraIssue__c> jiraIssueList = new  List<JiraIssue__c>([select Id, IssueKey__c, Project__c FROM JiraIssue__c where Project_Id__c = :Decimal.valueOf(projectMappingInstance.ProjectId__c)]);
                    for(Integer index = 0;index<jiraIssueList.size();index++){
                        JiraIssue__c issue = jiraIssueList.get(index);
                        issue.Deleted_in_JIRA__c = true;
                    }
                    if(schema.sObjectType.JiraIssue__c.isupdateable()){
                        update jiraIssueList;
                    }
                }
                
                if(projectMappingInstance!=null){
                    if(schema.sObjectType.Jira_Project__c.isDeletable()){
                        delete projectMappingInstance;
                    }
                }
                return;
                
            }else if(WebhookJsonMap.get('webhookEvent').equals('project_updated')){
                map<string,Object> webhookprojectMap= (map<string,Object>)WebhookJsonMap.get('project'); 
                
                String Proid=String.valueof(webhookprojectMap.get('id'));
                String ProKey=String.valueof(webhookprojectMap.get('key'));
                String ProName=String.valueof(webhookprojectMap.get('name'));
                
                reIndexIssues(Proid,ProKey,ProName);
                return;
                
            }
            
            if(WebhookJsonMap.get('webhookEvent').equals('attachment_created')){
                return;
            }
            if('issuelink_created'.equals(WebhookJsonMap.get('webhookEvent')) ||'issuelink_deleted'.equals(WebhookJsonMap.get('webhookEvent'))){
                if(WebhookJsonMap.containskey('issueLink')){
                    Map<String, Object> issueLinkMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(WebhookJsonMap.get('issueLink')));
                    jiraId = (decimal)issueLinkMap.get('destinationIssueId');
                    HttpRequest req1 = new HttpRequest(); 
                    Http http = new Http();
                    HTTPResponse res;
                    req1 = CreateJIRAWrapper.CreateRequest('/rest/api/2/issue/'+jiraId,'GET','application/json');
                    res =http.send(req1);
                    
                    if( res.getStatusCode()==200){
                        bodyString = res.getBody();
                    }else{
                        GenerateJiraLogs.CreateLogRealTime('JIRASalesforceSyncRestAPI',req1.getEndPoint(), req1.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), res.getbody() , null, String.valueof(jiraId), 'linkJiraIssueToSalesforceCase', res.getbody());   
                        
                    }
                }
            }
            
            
            
            updateJiraFromWebhook(jiraId,commentId,bodyString);
            
            if( String.isnotEmpty(commentId)){
                Map<String, JiraSalesforceDetail__c> mcs = JiraSalesforceDetail__c.getAll();
                String jiraCharacter='';
                if(mcs.containsKey('JiraCommentQualifier'))
                    jiraCharacter=mcs.get('JiraCommentQualifier').Value__c;
                
                String webhookEvent = ((String)WebhookJsonMap.get('webhookEvent')).trim();
                String commentBody = (String)((Map<String, Object>)WebhookJsonMap.get('comment')).get('body');
                if(commentBody!=null){
                    
                    List<String> commentBodybreak =commentBody.split('\n');
                    commentBody='';
                    for(String Combody :commentBodybreak){
                        commentBody+=combody.stripHtmlTags()+'\n';
                    }
                }
                commentBody=commentBody.removeEnd('\n');
                
                if(jiraCharacter!=null && jiraCharacter!='' && !commentBody.StartsWith(jiraCharacter)){
                    return;
                }
                
                String updateAuthorName = (String)((Map<String, Object>)((Map<String, Object>)WebhookJsonMap.get('comment')).get('updateAuthor')).get('displayName');
                if(updateAuthorName==null){
                    updateAuthorName = (String)((Map<String, Object>)((Map<String, Object>)WebhookJsonMap.get('comment')).get('updateAuthor')).get('name');
                }
                String author = (String)((Map<String, Object>)((Map<String, Object>)WebhookJsonMap.get('comment')).get('author')).get('displayName');
                if(author==null){
                    author = (String)((Map<String, Object>)((Map<String, Object>)WebhookJsonMap.get('comment')).get('author')).get('name');
                }
                Jira_login__c loginSettings = Jira_login__c.getValues('JIRA');
                list<JiraIssue__c> jirarelation=[SELECT Id, IssueId__c FROM JiraIssue__c where IssueId__c = :jiraId];
                //  list<JiraRelationship__c> jirarelation=[select Id, Jira_Case__c,JiraIssue__c,JiraIssue__r.name, JiraIssueId__c  from JiraRelationship__c where JiraIssueId__c = :jiraId];
                //  map<String,JiraRelationship__c> jirarelationmap= new map<String,JiraRelationship__c>();
                //  for(JiraRelationship__c jr:jirarelation){
                //      jirarelationmap.put(String.valueof(jr.JiraIssueId__c),jr);
                //  }
                list<JiraCommentController__c> ControllerList= new list<JiraCommentController__c>();
                
                if(JiraSalesforceDetail__c.getvalues('JiraCommentsSyncToJiraIssue').value__c.toLowerCase() == 'yes'){
                    
                    if(WebhookJsonMap.get('webhookEvent').equals('comment_created')){ //&& !commentBody.contains('Created by Salesforce :')){
                        
                        
                        Map<Decimal,JiraIssueComments__c> JiraIssueComments =new Map<Decimal,JiraIssueComments__c>();
                        if(JiraIssueComments__c.sObjectType.getDescribe().isAccessible() && JiraIssueComments__c.sObjectType.getDescribe().isUpdateable() && JiraIssueComments__c.sObjectType.getDescribe().isCreateable()){
                            List<JiraIssueComments__c> existingcomments=[Select id,CommentId__c from JiraIssueComments__c where CommentId__c=:commentId];
                            // List<JiraCommentController__c> comcontroller=[Select id,CommentId__c from JiraCommentController__c where CommentId__c=:commentId];
                            
                            if(existingcomments.isEmpty() ){
                                for(JiraIssue__c jiraCaseInstance : jirarelation){
                                    
                                    if(!JiraIssueComments.containsKey(jiraCaseInstance.IssueId__c )){
                                        JiraIssueComments__c jic=new JiraIssueComments__c();
                                        jic.JiraIssue__c=jiraCaseInstance.Id;
                                        
                                        if(JiraSalesforceDetail__c.getValues('Jira_Comment_As_Private').value__c.toLowerCase() == 'yes'){
                                            jic.IsPublished__c=false;
                                        }else{
                                            jic.IsPublished__c=true;
                                        }
                                        
                                        jic.Author__c=author;
                                        jic.JiraId__c=String.valueof(jiraId);
                                        jic.CommentId__c=commentId;
                                        jic.Comment_Added__c=true;
                                        if(CommentBody.contains('Created by Salesforce :')){
                                            jic.source__c='Salesforce';
                                        }else{
                                            jic.source__c='Jira';
                                        }
                                        
                                        jic.UpdateAuthor__c=updateAuthorName;
                                        jic.CommentBody__c= commentBody;
                                        JiraIssueComments.put(jiraCaseInstance.IssueId__c,jic);
                                    }
                                    
                                }
                                
                                if(!JiraIssueComments.isEmpty()){
                                    if(schema.sObjectType.JiraIssueComments__c.isCreateable()){
                                        insert JiraIssueComments.values();
                                    }
                                }
                            }
                        }
                        
                    }
                    
                    else if(WebhookJsonMap.get('webhookEvent').equals('comment_updated')){
                        String Comm;
                        list<JiraIssueCOmments__c> commentupdate=[select id,commentbody__c from JiraIssueComments__c where CommentId__c=:commentId ];
                        // List<JiraCommentController__c> comcontroller=[Select id,CommentId__c from JiraCommentController__c where CommentId__c=:commentId];
                        
                        for(JiraIssueCOmments__c c:commentupdate){
                            Comm=c.commentbody__c;
                        }
                        if(!commentupdate.isEmpty())
                        {
                            if(!Comm.equals(commentBody))
                            {
                                list<JiraIssueComments__c> jiracommenttoupdate=new  list<JiraIssueComments__c>();
                                for(JiraIssueCOmments__c Jcon:commentupdate){
                                    if(Jcon.Id!=null){
                                        jcon.Author__c=author;
                                        jcon.CommentBody__c=  commentBody;   
                                        jcon.UpdateAuthor__c=updateAuthorName;
                                        jiracommenttoupdate.add(jcon);
                                    }
                                    
                                }
                                if(!jiracommenttoupdate.isEmpty()){
                                    if(schema.sObjectType.JiraIssueComments__c.isUpdateable() ){
                                        update jiracommenttoupdate;
                                    }
                                }
                            }
                        }else{
                            Map<Decimal,JiraIssueComments__c> JiraIssueComments =new Map<Decimal,JiraIssueComments__c>();
                            if(JiraIssueComments__c.sObjectType.getDescribe().isAccessible() && JiraIssueComments__c.sObjectType.getDescribe().isUpdateable() && JiraIssueComments__c.sObjectType.getDescribe().isCreateable()){
                                for(JiraIssue__c jiraCaseInstance : jirarelation){
                                    
                                    if(!JiraIssueComments.containsKey(jiraCaseInstance.IssueId__c )){
                                        JiraIssueComments__c jic=new JiraIssueComments__c();
                                        jic.JiraIssue__c=jiraCaseInstance.Id;
                                        
                                        if(JiraSalesforceDetail__c.getValues('Jira_Comment_As_Private').value__c.toLowerCase() == 'yes'){
                                            jic.IsPublished__c=false;
                                        }else{
                                            jic.IsPublished__c=true;
                                        }
                                        
                                        jic.Author__c=author;
                                        jic.JiraId__c=String.valueof(jiraId);
                                        jic.CommentId__c=commentId;
                                        jic.Comment_Added__c=true;
                                        if(CommentBody.contains('Created by Salesforce :')){
                                            jic.source__c='Salesforce';
                                        }else{
                                            jic.source__c='Jira';
                                        }
                                        
                                        jic.UpdateAuthor__c=updateAuthorName;
                                        jic.CommentBody__c= commentBody;
                                        JiraIssueComments.put(jiraCaseInstance.IssueId__c,jic);
                                    }
                                    
                                }
                                
                                if(!JiraIssueComments.isEmpty()){
                                    if(schema.sObjectType.JiraIssueComments__c.isCreateable()){
                                        insert JiraIssueComments.values();
                                    }
                                }
                            }
                            
                        }
                    }
                }
            }
            
        }catch(Exception ex){
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('JIRASalesforceSyncRestAPI', '', 'RestContext', null, null,null,null, bodyString,null,'linkJiraIssueToSalesforceCase', Error);
        }
        // }
    }
    
    public static void  updateJiraFromWebhook(Decimal jiraId,String commentId,String bodyString){
        
        Map<String, Object> WebhookJsonMap = (Map<String, Object>)JSON.deserializeUntyped(bodyString);
        String NameSpace=''; 
        map<String,Jira_Project__c> ProjectkeyToObjectmap = new  map<String,Jira_Project__c>();
        String EndPoint = Jira_login__c.getValues('JIRA')!= null? Jira_login__c.getValues('JIRA').End_Point__c!= null ? Jira_login__c.getValues('JIRA').End_Point__c+'/browse/' : '' : '';
        Map<String,String> FieldNameByDataType = New Map<String,String>();
        List<Organization> ThisOrg = [SELECT NameSpacePrefix FROM Organization LIMIT 1];
        
        if(!ThisOrg.isEmpty() && ThisOrg[0].NameSpacePrefix!= null)
            NameSpace = ThisOrg[0].NameSpacePrefix.toLowerCase();
        
        
        for(Jira_Project__c project:[select id,Name,ProjectKey__c,ProjectId__c from Jira_Project__c LIMIT 1000]){
            ProjectkeyToObjectmap.put(project.ProjectKey__c,project);
            
        }   
        
        if(JiraIssue__c.sObjectType.getDescribe().isAccessible() && JiraIssue__c.sObjectType.getDescribe().isUpdateable() ){
            JiraIssue__c jiraIssue = new JiraIssue__c(); 
            List<JiraIssue__c> issueListJiraSF = new List<JiraIssue__c>([SELECT Id, Name,IssueKey__c,Jira_Link__c FROM JiraIssue__c WHERE IssueId__c = :jiraId]);
            
            
            if(issueListJiraSF!=null && issueListJiraSF.size()>0){
                jiraIssue = issueListJiraSF.get(0);
                if('jira:issue_deleted'.equals(WebhookJsonMap.get('webhookEvent'))){
                    if(schema.sObjectType.JiraIssue__c.fields.Deleted_in_JIRA__c.isUpdateable() && schema.sObjectType.JiraIssue__c.fields.Deleted_in_JIRA__c.isCreateable()){
                        jiraIssue.Deleted_in_JIRA__c = true;
                    }
                    try{
                        if(schema.sObjectType.JiraIssue__c.isUpdateable()){
                            update jiraIssue;
                        }
                    }catch(Exception ex){
                        String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                        GenerateJiraLogs.CreateLogRealTime('JIRASalesforceSyncRestAPI',null, null, null,null,null, null , null, null, 'updateJiraFromWebhook', Error);
                        
                    }
                    return;
                }else if('comment_deleted'.equals(WebhookJsonMap.get('webhookEvent'))) return;
                
            } 
            
            if(jiraId!=null && String.isEmpty(commentId)){
                if(JiraIssue__c.sObjectType.getDescribe().isAccessible() && JiraIssue__c.sObjectType.getDescribe().isUpdateable() && JiraIssue__c.sObjectType.getDescribe().isCreateable() ){
                    
                    
                    map<string,Object> innerobj = new map<string,Object>();
                    map<string,Object> Fieldobj = new map<string,Object>();
                    if(WebhookJsonMap.containskey('issue')){
                        innerobj=(map<string,Object>)JSON.deserializeUntyped(JSON.serialize(WebhookJsonMap.get('issue')));
                        Fieldobj=(map<string,Object>)JSON.deserializeUntyped(JSON.serialize(innerobj.get('fields')));
                    }else{
                        Fieldobj=(map<string,Object>)JSON.deserializeUntyped(JSON.serialize(WebhookJsonMap.get('fields')));
                    }                    
                    
                    
                    String jStatus;
                    String jPriority;
                    String jUpdated;
                    String jCreated;
                    Integer jCommentCount;
                    Integer linkedIssueCount;
                    Decimal issueId;
                    if(innerobj!=null && !innerobj.isEmpty()){
                        issueId = Decimal.valueOf(String.valueOf(innerobj.get('id')));
                    }else {
                        issueId = Decimal.valueOf(String.valueOf(WebhookJsonMap.get('id')));
                    }
                    
                    map<string,Object> statusObj = new map<string,Object>();
                    if(Fieldobj.containskey('status') && Fieldobj.get('status')!=null && Fieldobj.get('status')!=''){
                        statusObj = (map<string,Object>)Fieldobj.get('status');
                        jiraIssue.Status__c = (String)statusObj.get('name');
                        
                    } else{
                        if(schema.sObjectType.JiraIssue__c.fields.Status__c.isupdateable() && schema.sObjectType.JiraIssue__c.fields.Status__c.isCreateable()){
                            jiraIssue.Status__c ='';
                        }
                    }
                    
                    if(Fieldobj.containskey('priority')){
                        map<string,Object> priorityObj = (map<string,Object>)Fieldobj.get('priority');
                        jPriority = (String)priorityObj.get('id');
                        if(schema.sObjectType.JiraIssue__c.fields.Priority__c.isupdateable() && schema.sObjectType.JiraIssue__c.fields.Priority__c.isCreateable()){
                            jiraIssue.Priority__c = (String)priorityObj.get('name');
                            
                        }
                        
                    }
                    if(Fieldobj.containskey('updated')){
                        jUpdated = (String)Fieldobj.get('updated');
                        
                    }
                    if((String)Fieldobj.get('created') != null){
                        jCreated = (String)Fieldobj.get('created');
                        
                    }
                    
                    if(Fieldobj.containskey('assignee') && Fieldobj.get('assignee')!=null && Fieldobj.get('assignee')!='' ){
                        map<string,Object> assigneeObj = (map<string,Object>)Fieldobj.get('assignee');                                        
                        if(assigneeObj != null && schema.sObjectType.JiraIssue__c.fields.Assignee__c.isCreateable() && schema.sObjectType.JiraIssue__c.fields.Assignee__c.isUpdateable()){
                            jiraIssue.Assignee__c = (String)assigneeObj.get('displayName');                    
                        }else{
                            if(schema.sObjectType.JiraIssue__c.fields.Assignee__c.isCreateable() && schema.sObjectType.JiraIssue__c.fields.Assignee__c.isUpdateable())
                            {
                                jiraIssue.Assignee__c = '';
                            }
                        }
                    }else{
                        if(schema.sObjectType.JiraIssue__c.fields.Assignee__c.isCreateable() && schema.sObjectType.JiraIssue__c.fields.Assignee__c.isUpdateable())
                        {
                            jiraIssue.Assignee__c = 'Unassigned';
                        }
                    }
                    
                    if(Fieldobj.containskey('reporter') && Fieldobj.get('reporter')!=null && Fieldobj.get('reporter')!=''){
                        map<string,Object> reporterObj = (map<string,Object>)Fieldobj.get('reporter');
                        if(reporterObj != null && schema.sObjectType.JiraIssue__c.fields.Reporter__c.isUpdateable() && schema.sObjectType.JiraIssue__c.fields.Reporter__c.isCreateable()){
                            jiraIssue.Reporter__c = (String)reporterObj.get('displayName');
                        }else{
                            if(schema.sObjectType.JiraIssue__c.fields.Reporter__c.isUpdateable() && schema.sObjectType.JiraIssue__c.fields.Reporter__c.isCreateable()){
                                jiraIssue.Reporter__c='';
                            }
                        }                                       
                    }else{
                        if(schema.sObjectType.JiraIssue__c.fields.Reporter__c.isUpdateable() && schema.sObjectType.JiraIssue__c.fields.Reporter__c.isCreateable()){
                            jiraIssue.Reporter__c='';
                        }
                    }
                    if(jCreated!=null && schema.sObjectType.JiraIssue__c.fields.Created__c.isCreateable() && schema.sObjectType.JiraIssue__c.fields.Created__c.isUpdateable()){
                        jiraIssue.Created__c = (DateTime)JSON.deserialize('"'+jCreated+'"', DateTime.class);
                        
                    }else{
                        if(schema.sObjectType.JiraIssue__c.fields.Created__c.isCreateable() && schema.sObjectType.JiraIssue__c.fields.Created__c.isUpdateable()){
                            jiraIssue.Created__c=null; 
                        }
                    }
                    if(Fieldobj.containskey('description') && Fieldobj.get('description')!=null && Fieldobj.get('description')!=''){
                        if(schema.sObjectType.JiraIssue__c.fields.Description__c.isCreateable() && schema.sObjectType.JiraIssue__c.fields.Description__c.isUpdateable()){
                            jiraIssue.Description__c = (String)Fieldobj.get('description');
                        }
                    }else{
                        if(schema.sObjectType.JiraIssue__c.fields.Description__c.isCreateable() && schema.sObjectType.JiraIssue__c.fields.Description__c.isUpdateable()){
                            jiraIssue.Description__c ='';
                        }
                        
                    }
                    if(WebhookJsonMap!=null && WebhookJsonMap.containskey('key') && WebhookJsonMap.containskey('id') ){
                        if(schema.sObjectType.JiraIssue__c.fields.IssueKey__c.isCreateable() && schema.sObjectType.JiraIssue__c.fields.IssueKey__c.isUpdateable()){
                            jiraIssue.IssueKey__c = (String)WebhookJsonMap.get('key');
                        }
                        if(schema.sObjectType.JiraIssue__c.fields.IssueId__c.isUpdateable() && schema.sObjectType.JiraIssue__c.fields.IssueId__c.isCreateable()){
                            jiraIssue.IssueId__c = Decimal.valueof(String.valueOf(WebhookJsonMap.get('id')));
                        }
                        
                    }else if(innerobj.containskey('key') && innerobj.containskey('id')){
                        if(schema.sObjectType.JiraIssue__c.fields.IssueKey__c.isUpdateable() && schema.sObjectType.JiraIssue__c.fields.IssueKey__c.isCreateable()){
                            jiraIssue.IssueKey__c = (String)innerobj.get('key');
                        }
                        if(schema.sObjectType.JiraIssue__c.fields.IssueId__c.isUpdateable() && schema.sObjectType.JiraIssue__c.fields.IssueId__c.isCreateable()){
                            jiraIssue.IssueId__c = Decimal.valueof(String.valueOf(innerobj.get('id')));
                            
                        }
                    }
                    if(schema.sObjectType.JiraIssue__c.fields.name.isUpdateable() && schema.sObjectType.JiraIssue__c.fields.name.isCreateable()){
                        jiraIssue.name=jiraIssue.IssueKey__c;
                    }
                    //jiraIssue.Jira_Link__c=JiraService.fetchDomain(String.valueOf(innerobj.get('self')))+'/browse/'+innerobj.get('key');
                    if(schema.sObjectType.JiraIssue__c.fields.Jira_Link__c.isUpdateable() && schema.sObjectType.JiraIssue__c.fields.Jira_Link__c.isCreateable()){
                        jiraIssue.Jira_Link__c = EndPoint!='' ? EndPoint + jiraIssue.IssueKey__c : '' ;
                    }
                    if(jiraIssue.name!=jiraIssue.IssueKey__c && jiraIssue.id!=null){
                        if(schema.sObjectType.JiraIssue__c.fields.name.isUpdateable() && schema.sObjectType.JiraIssue__c.fields.name.isCreateable()){
                            jiraIssue.name=jiraIssue.IssueKey__c;
                        }
                        String s= jiraIssue.Jira_Link__c;
                        s='['+s.substring(0,s.lastIndexOf('/'))+'/'+jiraIssue.IssueKey__c+']';
                        if(schema.sObjectType.JiraIssue__c.fields.Jira_Link__c.isUpdateable() && schema.sObjectType.JiraIssue__c.fields.Jira_Link__c.isCreateable()){
                            jiraIssue.Jira_Link__c =s;
                        }
                    }
                    if(Fieldobj.containskey('issuetype')  ){
                        map<string,Object> IssuetypeObj = (map<string,Object>)Fieldobj.get('issuetype'); 
                        if(schema.sObjectType.JiraIssue__c.fields.IssueType__c.isUpdateable() && schema.sObjectType.JiraIssue__c.fields.IssueType__c.isCreateable()){
                            jiraIssue.IssueType__c = (String)IssuetypeObj.get('name');
                        }
                    }
                    
                    if(Fieldobj.containskey('project') ){
                        map<string,Object> projectObj = (map<string,Object>)Fieldobj.get('project'); 
                        if(schema.sObjectType.JiraIssue__c.fields.Project__c.isUpdateable() && schema.sObjectType.JiraIssue__c.fields.Project__c.isCreateable()){
                            jiraIssue.Project__c = (String)projectObj.get('key');
                        }
                        if(schema.sObjectType.JiraIssue__c.fields.Project_Id__c.isUpdateable() && schema.sObjectType.JiraIssue__c.fields.Project_Id__c.isCreateable()){
                            jiraIssue.Project_Id__c = (Decimal.valueof(String.valueOf(projectObj.get('id'))));
                        }
                    }
                    
                    if(Fieldobj.containskey('summary') && Fieldobj.get('summary')!=null && Fieldobj.get('summary')!=''){
                        if(schema.sObjectType.JiraIssue__c.fields.Summary__c.isUpdateable() && schema.sObjectType.JiraIssue__c.fields.Summary__c.isCreateable()){
                            jiraIssue.Summary__c = (String)Fieldobj.get('summary');
                        }
                    }else{
                        if(schema.sObjectType.JiraIssue__c.fields.Summary__c.isUpdateable() && schema.sObjectType.JiraIssue__c.fields.Summary__c.isCreateable()){
                            jiraIssue.Summary__c ='';
                        }
                        
                    }
                    if(Fieldobj.containskey('updated') && Fieldobj.get('updated')!=null && Fieldobj.get('updated')!=''){
                        if(schema.sObjectType.JiraIssue__c.fields.Updated__c.isUpdateable() && schema.sObjectType.JiraIssue__c.fields.Updated__c.isCreateable()){
                            jiraIssue.Updated__c = (DateTime)JSON.deserialize('"'+(String)Fieldobj.get('updated')+'"', DateTime.class);
                        }
                    }else{
                        if(schema.sObjectType.JiraIssue__c.fields.Updated__c.isUpdateable() && schema.sObjectType.JiraIssue__c.fields.Updated__c.isCreateable()){
                            jiraIssue.Updated__c=null;
                        }
                    }
                    
                    string resolutionDate =FieldJsonHelper.getFieldData('resolutiondate',(innerobj.isEmpty()||innerobj==null)?WebhookJsonMap:innerobj);
                    if(resolutionDate!=null && resolutionDate!=''){
                        resolutionDate = EditAddJiraIssueController.ConvertDate(resolutionDate);
                        if(schema.sObjectType.JiraIssue__c.fields.ResolutionDate__c.isUpdateable() && schema.sObjectType.JiraIssue__c.fields.ResolutionDate__c.isCreateable()){
                            jiraIssue.ResolutionDate__c= DateTime.Parse(resolutionDate);
                        }
                    }
                    if(schema.sObjectType.JiraIssue__c.fields.Resolution__c.isUpdateable() && schema.sObjectType.JiraIssue__c.fields.Resolution__c.isCreateable()){
                        jiraIssue.Resolution__c = FieldJsonHelper.getFieldDataForReporting('resolution',(innerobj.isEmpty()||innerobj==null)?WebhookJsonMap:innerobj);
                    }
                    if(schema.sObjectType.JiraIssue__c.fields.Creator__c.isUpdateable() && schema.sObjectType.JiraIssue__c.fields.Creator__c.isCreateable()){
                        jiraIssue.Creator__c = FieldJsonHelper.getFieldDataForReporting('creator',(innerobj.isEmpty()||innerobj==null)?WebhookJsonMap:innerobj);
                    }
                    string created = FieldJsonHelper.getFieldData('created',(innerobj.isEmpty()||innerobj==null)?WebhookJsonMap:innerobj);
                    if(created!=null && created!=''){
                        created = EditAddJiraIssueController.ConvertDate(created);
                        if(schema.sObjectType.JiraIssue__c.fields.ResolutionDate__c.isUpdateable() && schema.sObjectType.JiraIssue__c.fields.ResolutionDate__c.isCreateable()){
                            jiraIssue.ResolutionDate__c= DateTime.Parse(created);
                        }
                        if(schema.sObjectType.JiraIssue__c.fields.Created__c.isUpdateable() && schema.sObjectType.JiraIssue__c.fields.Created__c.isCreateable()){
                            jiraIssue.Created__c = DateTime.Parse(created);
                        }
                    }
                    
                    
                    String finalstring='';
                    set<string> JiraApiName=new set<String>();
                    // String caseNumberApi=CaseNumberField__c.getValues('FieldApi')!=Null?CaseNumberField__c.getValues('FieldApi').JiraFieldApi__c:'';
                    
                    for(Jira_ProjectFieldsMapping__c s:JiraSFService.fetchJiraCustomFields().values()){
                        JiraApiName.add(s.JIRA_Field_Api_Name__c);
                        FieldNameByDataType.put(s.JIRA_Field_Api_Name__c , s.DataType__c);      
                        
                        
                    }
                    /* if(caseNumberApi!=''){
JiraApiName.add(caseNumberApi);
}*/
                    
                    JiraApiName.add('issuetype');
                    JiraApiName.add('project');
                    JiraApiName.add('fixVersions');
                    JiraApiName.add('reporter');
                    JiraApiName.add('summary');
                    JiraApiName.add('description');
                    JiraApiName.add('components');
                    JiraApiName.add('status');
                    JiraApiName.add('assignee');
                    JiraApiName.add('priority');
                    JiraApiName.add('created');
                    
                    JiraApiName.add('creator');
                    
                    for(String s:JiraApiName){
                        if(Fieldobj.containskey(s)){
                            finalstring+='"'+s+'":'+JSON.serialize(Fieldobj.get(s))+',';
                        }
                    }
                    finalstring=finalstring.removeend(',');
                    finalstring='"fields":{'+finalstring +'}';
                    
                    if(innerobj!=null && !innerobj.isEmpty()){
                        if(schema.sObjectType.JiraIssue__c.fields.JsonData__c.isCreateable() &&  schema.sObjectType.JiraIssue__c.fields.JsonData__c.isUpdateable()){
                            jiraIssue.JsonData__c='{"key":"'+innerobj.get('key')+'","self":"'+innerobj.get('self')+'","id":"'+innerobj.get('id')+'",'+finalstring+'}';
                        }
                    }
                    else{
                        if(schema.sObjectType.JiraIssue__c.fields.JsonData__c.isCreateable() &&  schema.sObjectType.JiraIssue__c.fields.JsonData__c.isUpdateable()){
                            jiraIssue.JsonData__c='{"key":"'+WebhookJsonMap.get('key')+'","self":"'+WebhookJsonMap.get('self')+'","id":"'+WebhookJsonMap.get('id')+'",'+finalstring+'}';
                        }
                        
                    }
                    if(jiraIssue.Project__c!=null &&  ProjectkeyToObjectmap.containskey(jiraIssue.Project__c)  && jiraIssue.id!=null){//(jiraIssue.id!=null || (jiraIssue.CaseNos__c!=null && jiraIssue.CaseNos__c!=''))){
                        Map<String,String> ReportingFieldsMap = ReportingData.getReportingFieldsMap(
                            String.ValueOf(ProjectkeyToObjectmap.get(jiraIssue.Project__c).Id));
                        
                        if(!ReportingFieldsMap.isEmpty()){
                            Set<String> IssueFields = New Set<String>();
                            Map<String,Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('jiraIssue__c').getDescribe().fields.getMap();
                            
                            for(String sfield: fieldMap.Keyset()) {
                                if(NameSpace!=''){
                                    sfield= sfield.toLowerCase().replace(NameSpace.toLowerCase()+'__','');
                                }else{
                                    sfield=  sfield.toLowerCase().replace('Grz_Sf__',''); 
                                }
                                IssueFields.add(sfield);
                            }
                            
                            For(String fieldApi : ReportingFieldsMap.keySet()){
                                if(!IssueFields.isEmpty() && IssueFields.contains(fieldApi.toLowerCase()+'__c')){
                                    String val = fieldApi + '__c';
                                    String field_val = FieldJsonHelper.getFieldDataForReporting(fieldApi , innerobj);
                                    if(field_val!= null && field_val!= ''){
                                        if(FieldNameByDataType.get(fieldApi).toLowerCase() == 'float'){
                                            jiraIssue.put(val , Decimal.ValueOf(field_val));
                                        }else if(FieldNameByDataType.get(fieldApi).toLowerCase() == 'datetime'){
                                            jiraIssue.put(val , DateTime.ValueOf(field_val.replace('T',' ')));
                                        }else if(FieldNameByDataType.get(fieldApi).toLowerCase() == 'date' ||
                                                 FieldNameByDataType.get(fieldApi).toLowerCase() == 'datepicker'){
                                                     jiraIssue.put(val , Date.valueOf(field_val));
                                                 }
                                        else{
                                            jiraIssue.put(val , field_val);
                                            
                                        }
                                    }else{
                                        jiraIssue.put(val,null);
                                    }
                                }
                            }
                        }
                        Schema.SObjectField f = JiraIssue__c.Fields.Id;
                        if(schema.sObjectType.JiraIssue__c.isUpdateable() && schema.sObjectType.JiraIssue__c.isCreateable()){
                            Database.UpsertResult  cr = Database.upsert(jiraIssue, f, false);
                            
                            
                            if(!cr.isSuccess()){
                                Database.Error [] Err =cr.getErrors();
                                if(Err[0].getStatusCode()==System.StatusCode.DUPLICATE_VALUE && !System.isFuture()){
                                    // workaround to all update jira issue is not found initially but do exisit according to logic.
                                    
                                    updateJiraFromWebhookInFuture(jiraId,commentId,bodyString);
                                    
                                }else{
                                    String Error=System.label.cause_Label +Err[0].getStatusCode()+'\n'+Err[0].getMessage();
                                    GenerateJiraLogs.CreateLog('JIRASalesforceSyncRestAPI', '', 'RestContext', null, null,null,null, bodyString,null,'JIRA', Error);
                                    
                                }
                            }else{
                                if('jira:issue_updated'.equals(WebhookJsonMap.get('webhookEvent'))){
                                    if(JiraSalesforceDetail__c.sObjectType.getDescribe().isAccessible() && JiraSalesforceDetail__c.getValues('SyncJiraAttachmentsToSalesforce').value__c != null){
                                        if(JiraSalesforceDetail__c.getValues('SyncJiraAttachmentsToSalesforce').value__c.toLowerCase()=='yes'){
                                            List<String> contentdocumentids = new List<String>();
                                            Set<String> JiraAttachmentIdToInsert = new Set<String>();
                                            //Set<String> CvattachId = new Set<String>();
                                            Set<String> ContentDocid = new Set<String>();
                                            Set<String> ContentDocIdsToDelete = new Set<String>();
                                            List<ContentDocument> ContentDocstodlt = new List<ContentDocument>();
                                            Map<String,String> SFAttachmentIdToContent = new   Map<String,String>();
                                            Map<String,String> JiraAttachmentIdToContent = new   Map<String,String>();
                                            Map<String,String> finalmap = new   Map<String,String>();
                                            Set<String> jiraAttachmentId = new Set<String>();
                                            List<Object> issueattachments = ( List<Object> ) Fieldobj.get('attachment');
                                            if(issueattachments!=null || !issueattachments.isempty()){
                                                for(Object filds:issueattachments ){
                                                    Map<String, Object> attachmnt = ( Map<String, Object>) filds; 
                                                    String contentlink = (String) attachmnt.get('content');
                                                    String attachmentId = (String) attachmnt.get('id');
                                                    Integer attsize = (Integer) attachmnt.get('size');
                                                    contentlink = EncodingUtil.urlDecode(contentlink, 'UTF-8');
                                                    contentlink=contentlink.deleteWhitespace();
                                                    if(attsize<=10485760){
                                                        system.debug('attachmentId '+attachmentId);
                                                        JiraAttachmentIdToContent.put(attachmentId,contentlink);
                                                        jiraAttachmentId.add(attachmentId);
                                                    }
                                                }
                                                
                                            }
                                            JiraIssue__c ji;
                                            if(JiraIssue__c.sObjectType.getDescribe().isAccessible()){
                                                ji=[SELECT Id, Name, IssueKey__c FROM JiraIssue__c where issuekey__c=:jiraIssue.IssueKey__c];
                                            }
                                            if(ContentDocumentLink.sObjectType.getDescribe().isAccessible() ){
                                                for(ContentDocumentLink cl:[SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink where LinkedEntityId =:ji.id]){
                                                    ContentDocid.add(cl.ContentDocumentId);
                                                    
                                                }
                                            }
                                            if(!ContentDocid.isempty()){
                                                if(ContentVersion.sObjectType.getDescribe().isAccessible() ){
                                                    DateTime SyncLastModified =JiraSalesforceDetail__c.getValues('SyncJiraAttachmentsToSalesforce').LastModifiedDate; 
                                                    for(ContentVersion cv:[SELECT Id,ContentDocumentId, JIRA_Attachment_Id__c FROM ContentVersion WHERE JIRA_Attachment_Id__c!=null and ContentDocumentId IN :ContentDocid  and createddate>=:SyncLastModified]){
                                                        SFAttachmentIdToContent.put(String.valueof(cv.JIRA_Attachment_Id__c),cv.ContentDocumentId);
                                                    }
                                                } 
                                            }
                                            
                                            
                                            system.debug('attachmntidtocontentdocid '+SFAttachmentIdToContent);
                                            if(!SFAttachmentIdToContent.isempty()){
                                                for(String attid : SFAttachmentIdToContent.keyset()){
                                                    if(!jiraAttachmentId.contains(attid)){
                                                        ContentDocIdsToDelete.add(SFAttachmentIdToContent.get(attid));
                                                    }
                                                }
                                            } 
                                            if(!jiraAttachmentId.isempty()){
                                                for(String attid : jiraAttachmentId){
                                                    if(!SFAttachmentIdToContent.containsKey(attid)){
                                                        JiraAttachmentIdToInsert.add(attid);
                                                    }
                                                }
                                            }
                                            system.debug('attachId '+JiraAttachmentIdToInsert);
                                            if(ContentDocument.sObjectType.getDescribe().isAccessible() ){
                                                if(!ContentDocIdsToDelete.isempty() && ContentDocument.sObjectType.getDescribe().isDeletable() ){
                                                    System.debug('del----'+ContentDocIdsToDelete);
                                                    delete [SELECT Title, Id FROM ContentDocument WHERE Id IN:ContentDocIdsToDelete];
                                                }
                                            }
                                            
                                            
                                            datetime dt = system.now().addSeconds(15); 
                                            String day = string.valueOf(dt.day());
                                            String month = string.valueOf(dt.month());
                                            String hour = string.valueOf(dt.hour());
                                            String minute = string.valueOf(dt.minute());
                                            String second = string.valueOf(dt.second());
                                            String year = string.valueOf(dt.year());
                                            String strSchedule = second+' ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
                                            
                                            
                                            if(!JiraAttachmentIdToInsert.isempty()){
                                                for(String att : JiraAttachmentIdToInsert){
                                                    finalmap.put(att,JiraAttachmentIdToContent.get(att));
                                                }
                                                System.debug('final----'+finalmap);
                                                BatchtoInsertJiraAttachments jiraatt = new BatchtoInsertJiraAttachments(finalmap,ji.id);
                                                System.schedule('Jira_Attachments '+Integer.valueof(math.random()*10000), strSchedule, jiraatt);
                                                
                                            }
                                        }
                                    } 
                                } 
                            }
                        } 
                    }
                    
                }
            } 
        }
        
    }
    
    @future 
    public static void updateJiraFromWebhookInFuture(Decimal jiraId,String commentId,String bodyString){
        
        updateJiraFromWebhook(jiraId,commentId,bodyString);
    }
    
    
    /**
* Helper function responsible to update project and jira issue keys 
*/
    
    @future(callout=true)
    public static void reIndexIssues(String projectId, String projectKey, String projectName){  
        try{
            if(JiraIssue__c.sObjectType.getDescribe().isAccessible() && JiraIssue__c.sObjectType.getDescribe().isUpdateable()){
                Jira_Project__c projectMappingInstance = [select Id, Name, ProjectId__c, ProjectKey__c from Jira_Project__c where ProjectId__c = :projectId];
                if(projectMappingInstance!=null){
                    projectMappingInstance.ProjectKey__c = projectKey;
                    projectMappingInstance.Name = projectName;
                    if(schema.sObjectType.Jira_Project__c.isupdateable()){
                        update projectMappingInstance;
                    }
                    List<JiraIssue__c> jiraIssueList = new  List<JiraIssue__c>([select Id, IssueKey__c, Project__c FROM JiraIssue__c where Project_Id__c = :Decimal.valueOf(projectMappingInstance.ProjectId__c)]);
                    for(Integer index = 0;index<jiraIssueList.size();index++){
                        JiraIssue__c issue = jiraIssueList.get(index);
                        if(!issue.IssueKey__c.contains(projectMappingInstance.ProjectKey__c) && Schema.sObjectType.Jira_Project__c.fields.ProjectKey__c.isAccessible()){
                            String issueIndex = issue.IssueKey__c.subString(issue.IssueKey__c.indexOf('-'));
                            issue.IssueKey__c = projectMappingInstance.ProjectKey__c+issueIndex;
                            issue.name = projectMappingInstance.ProjectKey__c+issueIndex;
                            issue.Project__c = projectMappingInstance.ProjectKey__c;
                        }else{
                            jiraIssueList.remove(index);
                        }
                    }
                    if(jiraIssueList.size()>0){
                        
                        if(schema.sObjectType.JiraIssue__c.isupdateable()){
                            update jiraIssueList;
                        }
                        
                    }
                }
                
            }
        }catch(Exception ex){
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('JIRASalesforceSyncRestAPI',null, null, null,null,null, null , null, null, 'reIndexIssues', Error);
            
        }
    }
    
    
    
}