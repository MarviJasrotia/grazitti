public with sharing class StoreJsonFile  implements Database.Batchable<sObject>,  Database.AllowsCallouts {
    
    public List<JiraErrorLogs__c> JiraLogsToInsert = new List<JiraErrorLogs__c>();
    Set<Id> ProjectIdSet = new Set<Id>();
    
    public StoreJsonFile(Set<Id> JiraProjectsMap){
        ProjectIdSet.addAll(JiraProjectsMap);
    }
    public List<Jira_Project__c> start(Database.BatchableContext BC){  
        List<Jira_Project__c> jiraProject=new  List<Jira_Project__c>();
        jiraProject=[SELECT id,Name,IssueType__c,Subtask__c, ProjectKey__c FROM Jira_Project__c WHERE Id in:ProjectIdSet]; 
        
        return jiraProject;
    }
    
    public void execute(Database.BatchableContext info, List<object> scope){
        Jira_Project__c Project=(Jira_Project__c)scope[0];
        String ProjectKey=Project.ProjectKey__c;
        String FinalJson='';
        ProjectsJson Finaljsondata;
        ProjectsJsonWithOutAllowed FinaljsondataNotAllowed;
        set<String> Issuetypes=new  set<String>();
        
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        HTTPResponse res;
        try{
            req = new HttpRequest();
            req = CreateJIRAWrapper.CreateRequest('/rest/api/2/issue/createmeta?projectKeys='+ProjectKey ,'GET' ,'application/json');
            res = http.send(req);
            
            if(res.getStatusCode()==200){
                Map<String, Object> Main = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                
                Object JsonObj=Main.get('projects');
                String JsonString = JSON.serialize(JsonObj);
                ProjectsJson jsondata;
                JSONParser parser = JSON.createParser(JsonString);
                while (parser.nextToken() != null) {
                    if(parser.getCurrentToken()==JSONToken.START_OBJECT ){ 
                        jsondata=(ProjectsJson)parser.readValueAs(ProjectsJson.class);
                    }
                }
                for(ProjectsJson.IssueType IssueType:jsondata.issuetypes){
                    if((Project.IssueType__c!=NULL && Project.IssueType__c.contains(IssueType.Name))|| (Project.Subtask__c!=NULL && Project.Subtask__c.contains(IssueType.Name))){
                        Issuetypes.add(IssueType.id);
                    } 
                }
                
            }else{
                GenerateJiraLogs.CreateLogRealTime('StoreJsonFile ',req.getEndpoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), req.getbody() , null, ProjectKey , 'Create Json For Projects', res.getBody());
                
            }   
        }catch(Exception ex){
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('StoreJsonFile ',req.getEndpoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), req.getbody() , null, ProjectKey , 'Create Json For Projects', Error);
            
        }
        
        
        integer i=0;
        
        for(String Issue:Issuetypes){
            
            String jiraMetadataJson= null;
            req = new HttpRequest();
            http = new Http();
            
            try{
                req = new HttpRequest();
                req = CreateJIRAWrapper.CreateRequest('/rest/api/2/issue/createmeta?projectKeys='+ProjectKey+'&issuetypeIds='+Issue+'&expand=projects.issuetypes.fields' ,'GET' ,'application/json');
                res = http.send(req);
                
                if(res.getStatusCode()==200){
                    Map<String, Object> Main = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    Object JsonObj=Main.get('projects');
                    String JsonString = JSON.serialize(JsonObj);
                    ProjectsJson jsondata;
                    ProjectsJsonWithOutAllowed JsonDataNotAllowed;
                    JSONParser parser = JSON.createParser(JsonString);
                    JSONParser parser1 = JSON.createParser(JsonString);
                    while (parser.nextToken() != null) {
                        if(parser.getCurrentToken()==JSONToken.START_OBJECT ){ 
                            jsondata=(ProjectsJson)parser.readValueAs(ProjectsJson.class);
                            if(Finaljsondata==null){
                                Finaljsondata=jsondata;
                                
                            }else{
                                Finaljsondata.issuetypes.addall(jsondata.issuetypes);
                                
                            }
                        }
                    }
                    
                    while (parser1.nextToken() != null) {
                        if(parser1.getCurrentToken()==JSONToken.START_OBJECT ){ 
                            JsonDataNotAllowed=(ProjectsJsonWithOutAllowed)parser1.readValueAs(ProjectsJsonWithOutAllowed.class);
                            if(FinaljsondataNotAllowed==null){
                                FinaljsondataNotAllowed=JsonDataNotAllowed;
                                
                            }else{
                                FinaljsondataNotAllowed.issuetypes.addall(JsonDataNotAllowed.issuetypes);
                                
                            }
                        }
                    }
                    
                    if(schema.sObjectType.Jira_Project__c.fields.ProjectId__c.isUpdateable()){
                        Project.ProjectId__c=Finaljsondata.Id;
                    }
                    
                }else{
                    JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('StoreJsonFile',req.getEndpoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), req.getbody() , null, ProjectKey , 'UpdateProjectsAndRelatedFieldsInfoAndData', res.getBody()));
                    
                }
            }catch(Exception ex){
                String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('StoreJsonFile',req.getEndpoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), req.getbody() , null, ProjectKey , 'UpdateProjectsAndRelatedFieldsInfoAndData', Error));
                return;
            } 
            
        }  
        
        Id SectionId;
        list<Jira_FieldSection__c> SectionList= new list<Jira_FieldSection__c>();
        if(Jira_FieldSection__c.sObjectType.getDescribe().isAccessible()){
            SectionList = [select id , name, column__c,order__c from Jira_FieldSection__c where name='Jira Fields' Limit 1];
        }
        For(Jira_FieldSection__c Section:SectionList){
            if(Schema.sObjectType.Jira_FieldSection__c.fields.id.isAccessible()){
                SectionId=Section.id;
            }
        }
        if(SectionId==null){
            
            jira_FieldSection__c section1 = new Jira_FieldSection__c();
            if(schema.sObjectType.jira_FieldSection__c.fields.name.isCreateable()){
                section1.name='Jira Fields';
            }
            if(schema.sObjectType.jira_FieldSection__c.fields.column__c.isCreateable()){
                section1.column__c='2';
            }
            if(schema.sObjectType.jira_FieldSection__c.fields.order__c.isCreateable()){
                section1.order__c=1;
            }
            try{
                if(schema.sObjectType.jira_FieldSection__c.isCreateable()){
                    insert section1;
                }
            }catch(Exception ex){
                String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                GenerateJiraLogs.CreateLogRealTime('StoreJsonFile',null, null, null,null,null, null , null, null, 'Insert Section', Error);
                
            }
            SectionId=section1.id;
            
        }
        
        
        if(!ContentVersion.sObjectType.getDescribe().isAccessible()){
            return;
        }
        
        list<ContentVersion> CvList = new list<ContentVersion>();
        String Title=ProjectKey+'_Json.txt';
        String Title1=ProjectKey+'_NotAllowedJson.txt';
        ContentVersion cv = new ContentVersion();
        CvList = [select id ,ContentDocumentId  from contentversion where Title=:Title or Title =:Title1];
        if(!CvList.isEmpty()){
            List<ContentDocument> cdList= new List<ContentDocument>();
            ContentDocument cd= new ContentDocument();
            for(ContentVersion  cv1:CvList){
                ContentDocument cnd= new ContentDocument();
                if(Schema.sObjectType.ContentVersion.fields.ContentDocumentId.isAccessible()){
                    cnd.id=cv1.ContentDocumentId;
                }
                cdList.add(cnd);
            }
            try{ 
                if(schema.sObjectType.ContentDocument.isDeletable()){
                    delete cdList;
                }
                
            }catch(Exception ex){
                String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                GenerateJiraLogs.CreateLogRealTime('StoreJsonFile',null, null, null,null,null, null , null, null, 'Delete ContentDocument', Error);
            }
        }   
        CvList = new list<ContentVersion>();
        ContentVersion cvdata = new ContentVersion();
        try{
            String data='{"projects":['+ Json.serialize(Finaljsondata)+']}';
            Blob b = blob.valueof(data); //decoded string
            if( schema.sObjectType.ContentVersion.fields.VersionData.isCreateable()){
                
                cvdata.VersionData = b;
            }
            if( schema.sObjectType.ContentVersion.fields.Title.isCreateable()){
                
                cvdata.Title = Title;
            }
            if(schema.sObjectType.ContentVersion.fields.PathOnClient.isCreateable()){
                
                cvdata.PathOnClient  =  Title;
            }
            
            CvList.add(cvdata);
            
            ContentVersion cvNotAllowed = new ContentVersion();
            
            String dataNotAllowed='{"projects":['+ Json.serialize(FinaljsondataNotAllowed)+']}'; 
            b = blob.valueof(dataNotAllowed); //decoded string
            if(schema.sObjectType.ContentVersion.fields.VersionData.isCreateable()){
                cvNotAllowed.VersionData = b;
            }
            if(schema.sObjectType.ContentVersion.fields.Title.isCreateable()){
                cvNotAllowed.Title = Title1;
            }
            if(schema.sObjectType.ContentVersion.fields.PathOnClient.isCreateable()){
                cvNotAllowed.PathOnClient  =  Title1;
            }
            CvList.add(cvNotAllowed);
            
            if(schema.sObjectType.ContentVersion.isCreateable() ){
                insert CvList;
            }
        }catch(Exception ex){
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('StoreJsonFile',null, null, null,null,null, null , null, null, 'Delete ContentVersion', Error);
            
        }
        list<ContentDocumentLink> ContentDocumentLinkList= new List<ContentDocumentLink>();
        //list<ContentVersion> CvList2 = new list<ContentVersion>();
        for(ContentVersion cv1 : [SELECT Id, ContentDocumentId FROM ContentVersion where id= :CvList]){
            // CvList2= [SELECT Id, ContentDocumentId FROM ContentVersion where id= :cv.id];
            
            
            ContentDocumentLink Cdl= new ContentDocumentLink();
            if(schema.sObjectType.ContentDocumentLink.fields.LinkedEntityId.isCreateable()){
                cdl.LinkedEntityId=Project.id;
                
            }
            if(schema.sObjectType.ContentDocumentLink.fields.ShareType.isCreateable()){
                cdl.ShareType ='I';
                
            }
            if(schema.sObjectType.ContentDocumentLink.fields.ContentDocumentId.isCreateable()){
                cdl.ContentDocumentId=cv1.ContentDocumentId;
                
            }
            
            ContentDocumentLink CdlOrg= new ContentDocumentLink();
            CdlOrg.LinkedEntityId=UserInfo.getOrganizationId() ;
            CdlOrg.ShareType ='C';
            CdlOrg.ContentDocumentId=cv1.ContentDocumentId;
            ContentDocumentLinkList.add(cdl);
            ContentDocumentLinkList.add(CdlOrg);
            
        }
        if(!ContentDocumentLinkList.IsEmpty()){
            try{
                if(schema.sObjectType.ContentDocumentLink.iscreateable()){
                    insert ContentDocumentLinkList;
                }
                if(Project.id!=null){
                    if(schema.sObjectType.Jira_Project__c.fields.HasJson__c.isUpdateable()){
                        Project.HasJson__c=true;
                    }
                    if(schema.sObjectType.Jira_Project__c.isUpdateable()){
                        update Project;
                    }
                }
                
            }catch(Exception ex){
                String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                GenerateJiraLogs.CreateLogRealTime('StoreJsonFile',null, null, null,null,null, null , null, null, 'ContentDocumentLink', Error);
                
            }
        }
    }
    public void finish(Database.BatchableContext BC){
        if(!JiraLogsToInsert.isEmpty()){
            Insert JiraLogsToInsert;
        }
    } 
}