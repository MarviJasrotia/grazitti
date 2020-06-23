public class BatchtoInsertJiraAttachments implements schedulable, Database.Batchable<String>, Database.AllowsCallouts,Database.Stateful {
    Map<String,String> jiraattachmap;
    Map<String,String> attachidtocontentdocid;
    Set<Decimal> attids = new  Set<Decimal>();
    String jiraId;
    public String errorMessage;
    Set<String> attachmentids = new Set<String>();
    public BatchtoInsertJiraAttachments(Map<String,String> jiraattachmap,String jiraId){
        this.jiraattachmap = jiraattachmap;
        this.jiraId = jiraId;
    }
    
    public List<String> start(Database.BatchableContext BC) {
        List<String> attachmentid= new List<String>();
        attachmentid.addAll(jiraattachmap.keySet());
        for(String att:attachmentid){
            attids.add(Decimal.valueOf(att));
        }
        return attachmentid;
    }
    
    public void execute(Database.BatchableContext BC, List<String> attachmentid) {
        if(ContentVersion.sObjectType.getDescribe().isAccessible()){
            for(ContentVersion cvv:[SELECT Id, JIRA_Attachment_Id__c,ContentDocumentId FROM ContentVersion WHERE JIRA_Attachment_Id__c IN :attids]){
                attachmentids.add(String.valueOf(cvv.JIRA_Attachment_Id__c));
            }
        }
        for(String attid:attachmentid){
            System.debug('attid '+attid);
            System.debug('attachmentids '+attachmentids);
            
            if(!attachmentids.isEmpty() && attachmentids.contains(attid)){
                continue;
            }else if( attachmentids.isEmpty() || (!attachmentids.isEmpty() && !attachmentids.contains(attid))){
                System.debug('attid'+attid);
                Jira_login__c loginSettings = Jira_login__c.getValues('JIRA');
                String contenturl= jiraattachmap.get(attid).remove(loginSettings.End_Point__c);
                HTTP h = new HTTP();
                HTTPRequest r = new HTTPRequest();
                HttpResponse response;
                r=CreateJIRAWrapper.CreateRequest(contenturl,'GET','application/json');
                
                Integer maxsize=13107;
                Integer resbody;
                try{
                    response = h.send(r);
                    if((response.getBody()).length()<maxsize){
                        resbody=(response.getBody()).length();
                    }else{
                        resbody=maxsize;
                    }
                    if(response.getStatusCode() == 200){
                        ContentVersion cvv;
                        String conturl = jiraattachmap.get(attid).substring(jiraattachmap.get(attid).lastIndexOf('/')+1);
                        if(ContentVersion.sObjectType.getDescribe().isAccessible() && Schema.sObjectType.ContentVersion.isCreateable() ){
                            ContentVersion cv=new Contentversion();
                            cv.title=conturl;
                            cv.pathonclient=conturl;
                            cv.JIRA_Attachment_Id__c=Decimal.valueof(attid);
                            cv.versiondata=response.getBodyAsBlob();
                            insert cv;
                            cvv=[SELECT Id, JIRA_Attachment_Id__c,ContentDocumentId FROM ContentVersion WHERE ID = :cv.ID ];
                            
                        }
                        if(ContentDocumentLink.sObjectType.getDescribe().isAccessible() && Schema.sObjectType.ContentDocumentLink.isCreateable() ){
                            ContentDocumentLink  cd = new ContentDocumentLink ();
                            cd.LinkedEntityId=jiraId;
                            cd.ContentDocumentId=cvv.ContentDocumentId;
                            
                            insert cd;
                            system.debug('ss'+response.getStatusCode());
                            
                            if(JiraSalesforceDetail__c.sObjectType.getDescribe().isAccessible() && JiraSalesforceDetail__c.getValues('Sync_Jira_attachments_to_case').value__c != null){
                                if(JiraSalesforceDetail__c.getValues('Sync_Jira_attachments_to_case').value__c.toLowerCase()=='yes'){
                                    List<ContentDocumentLink> contentdoclinkstoinsert = new List<ContentDocumentLink>();
                                    for(JiraRelationship__c jr : [SELECT Id, Name, CaseRelation__c, JiraIssue__c FROM JiraRelationship__c WHERE JiraIssue__c=: jiraId and CaseRelation__c!=null]){
                                        ContentDocumentLink  cd1 = new ContentDocumentLink ();
                                        cd1.LinkedEntityId=jr.CaseRelation__c;
                                        cd1.ContentDocumentId=cvv.ContentDocumentId;
                                        contentdoclinkstoinsert.add(cd1) ;  
                                    }
                                    if(!contentdoclinkstoinsert.isEmpty()){
                                        insert contentdoclinkstoinsert;
                                    }
                                }
                            }
                        }
                    }else if(response.getStatusCode() == 302){
                        system.debug('ss'+response.getStatusCode());
                        String loc = response.getHeader('Location');
                        system.debug('loc '+loc);
                        r = new HttpRequest();
                        r.setEndpoint(loc);
                        r.setMethod('GET');
                        response = h.send(r);
                        if(response.getStatusCode() == 200){
                            ContentVersion cvv;
                            if(ContentVersion.sObjectType.getDescribe().isAccessible() && Schema.sObjectType.ContentVersion.isCreateable() ){
                                String conturl = jiraattachmap.get(attid).substring(jiraattachmap.get(attid).lastIndexOf('/')+1);
                                ContentVersion cv=new Contentversion();
                                cv.title=conturl;
                                cv.pathonclient=conturl;
                                cv.JIRA_Attachment_Id__c=Decimal.valueof(attid);
                                cv.versiondata=response.getBodyAsBlob();
                                insert cv;
                                cvv=[SELECT Id, JIRA_Attachment_Id__c,ContentDocumentId FROM ContentVersion WHERE JIRA_Attachment_Id__c = :Decimal.valueOf(attid) ];
                                
                            }
                            if(ContentDocumentLink.sObjectType.getDescribe().isAccessible() && Schema.sObjectType.ContentDocumentLink.isCreateable() ){
                                ContentDocumentLink  cd = new ContentDocumentLink ();
                                cd.LinkedEntityId=jiraId;
                                cd.ContentDocumentId=cvv.ContentDocumentId;
                                insert cd;
                                system.debug('ss'+response.getStatusCode());
                                
                                if(JiraSalesforceDetail__c.sObjectType.getDescribe().isAccessible() && JiraSalesforceDetail__c.getValues('Sync_Jira_attachments_to_case').value__c != null){
                                    if(JiraSalesforceDetail__c.getValues('Sync_Jira_attachments_to_case').value__c.toLowerCase()=='yes'){
                                        List<ContentDocumentLink> contentdoclinkstoinsert = new List<ContentDocumentLink>();
                                        for(JiraRelationship__c jr : [SELECT Id, Name, CaseRelation__c, JiraIssue__c FROM JiraRelationship__c WHERE JiraIssue__c=: jiraId and CaseRelation__c!=null]){
                                            ContentDocumentLink  cd1 = new ContentDocumentLink ();
                                            cd1.LinkedEntityId=jr.CaseRelation__c;
                                            cd1.ContentDocumentId=cvv.ContentDocumentId;
                                            contentdoclinkstoinsert.add(cd1) ;  
                                        }
                                        if(!contentdoclinkstoinsert.isEmpty()){
                                            insert contentdoclinkstoinsert;
                                        }
                                    }
                                }
                            }
                        }
                    }else{
                        GenerateJiraLogs.CreateLogRealTime('BatchToInsertAttachments',null, r.getMethod(), String.valueof(response.getstatusCode()),null,response.getstatus(),null , null, jiraId, 'Insert Attachment', '');
                    }
                }
                catch(System.calloutException e){ 
                    System.debug('fgh'+(response.getbody()).length());
                    errorMessage = e.getMessage();
                    GenerateJiraLogs.CreateLogRealTime('BatchToInsertAttachments',null, r.getMethod(), String.valueof(response.getstatusCode()),null,response.getstatus(),null , null, jiraId, 'Insert Attachment', Errormessage);
                }  
                catch(Exception e){ 
                    System.debug('fgh'+resbody);
                    errorMessage = e.getMessage();
                    GenerateJiraLogs.CreateLogRealTime('BatchToInsertAttachments',null, r.getMethod(), String.valueof(response.getstatusCode()),r.getbody(),response.getstatus(),null , null, jiraId, 'Insert Attachment', Errormessage);
                } 
            }
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        for(CronTrigger cronTrig:[SELECT State, Id FROM CronTrigger WHERE CronJobDetail.Name like 'Jira_Attachments%' AND State='DELETED' LIMIT 100]){
            System.abortJob(cronTrig.Id);  
        }    
    }
    public void execute(SchedulableContext cc) {
        Database.executeBatch(new BatchtoInsertJiraAttachments(jiraattachmap,jiraId),1);
        
    }
    
}