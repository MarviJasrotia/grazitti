public with Sharing class JiraIssueRelatedListController {
    
    @AuraEnabled
    public Static void unlinkjira(id jiraId,id genericObjectID){
        String objectName='';
        String modifiedName='';
        List<JiraRelationship__c> jiraRelationList=new  List<JiraRelationship__c> ();
        
        if(genericObjectID!=NULL)
            objectName=genericObjectID.getSObjectType().getDescribe().getName();
        
        modifiedName=objectName;
        if(modifiedName.contains('Grz_Sf__')) {
            modifiedName=modifiedName.remove('Grz_Sf__');
        }
        
        if(modifiedName.containsIgnoreCase('__c')){
            modifiedName= modifiedName.remove('__c');
        }  
        if(modifiedName.contains('__'))modifiedName=modifiedName.substring(modifiedName.indexof('__')+2,modifiedName.length() );
        
        
        
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        
        map<String,Schema.SObjectField>  genericFieldMap = new map<String,Schema.SObjectField>();
        map<String,Schema.SObjectField>  NewgenericFieldMap = new map<String,Schema.SObjectField>();  
        //NameSpace removed Grz_Sf__JiraRelationship__c to JiraRelationship__c
        genericFieldMap= schemaMap.get('JiraRelationship__c').getDescribe().fields.getMap();
        
        String nameSpace = '';
        if(Organization.sObjectType.getDescribe().isAccessible() ){
            List<Organization> ThisOrg = [SELECT NameSpacePrefix FROM Organization LIMIT 1];
            
            if(!ThisOrg.isEmpty() && ThisOrg[0].NameSpacePrefix!= null && Schema.sObjectType.Organization.fields.NameSpacePrefix.isAccessible()){nameSpace = ThisOrg[0].NameSpacePrefix;}
        }
        if(nameSpace==null||nameSpace==''){nameSpace='';}else{nameSpace=nameSpace+'__';}
        for(String key:genericFieldMap.keySet()){
            String Inkey=key.tolowerCase();
            Inkey=Inkey.remove('grz_sf__');
            nameSpace=nameSpace.toLowerCase();
            Inkey=Inkey.remove(nameSpace);
            NewgenericFieldMap.put(Inkey,genericFieldMap.get(key));
        }
        String RelationFieldName;
        if(objectName!=NULL && objectName!=''){
            
            if(NewgenericFieldMap.containskey(modifiedName.tolowercase()+'relation__c')){ 
                
                RelationFieldName=String.valueOf(NewgenericFieldMap.get(modifiedName.tolowercase()+'relation__c'));
                
            }
        }
        String query;
      
        if(RelationFieldName!='' && RelationFieldName!=NULL )
            query ='SELECT Id FROM JiraRelationship__c where JiraIssue__c=' +'\''+ String.escapeSingleQuotes(jiraId) +'\' AND '+RelationFieldName+'= '+'\''+ String.escapeSingleQuotes(genericObjectID) +'\' order by createdDate';
       
        if(query!=NULL && query!='' && JiraRelationship__c.sObjectType.getDescribe().isAccessible())
            jiraRelationList=Database.query(query);
        
        try{
            if(jiraRelationList!=NULL && jiraRelationList.size()>0){
                delete jiraRelationList[0];
            }
        }catch(Exception ex){
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('JiraIssueRelatedListController',null, null, null,null,null, null , null, jiraId, 'Unlink Jira', Error);
            
            
        }
    }
    
    @AuraEnabled
    public static DataTableWrapper getjiraissues(ID recordId){
        
        List<JiraWrapper> jiraIssuesList = new List<JiraWrapper>();
        List<Sobject> jiraRelationList = new List<Sobject>();
        DataTableWrapper dtw = new DataTableWrapper();
        List<LabelDescriptionWrapper> labelList = new List<LabelDescriptionWrapper>();
        
        List<String> jiraIssueFieldList=new List<String>(); 
        jiraIssueFieldList.add('Name');
        //NameSpace removed Grz_Sf__
        jiraIssueFieldList.add('Priority__c');
        jiraIssueFieldList.add('Resolution__c');
        jiraIssueFieldList.add('Jira_Link__c');
        jiraIssueFieldList.add('IssueType__c');
        
        jiraIssueFieldList.add('Status__c');
        
        jiraIssueFieldList.add('IssueKey__c');
        jiraIssueFieldList.add('Assignee__c');
        jiraIssueFieldList.add('Reporter__c');
        jiraIssueFieldList.add('Action');
        
        
        String issueKey='';
        String objectName='';
        String RelationFieldName;
        String nameSpace = ''; 
        String modifiedName;
        String query='';
        
        map<String,Schema.SObjectField>  genericFieldMap = new map<String,Schema.SObjectField>();
        map<String,Schema.SObjectField>  NewgenericFieldMap = new map<String,Schema.SObjectField>();
        
        if(RecordId!=NULL){
            objectName=RecordId.getSObjectType().getDescribe().getName();
            modifiedName=objectName;
        }
        
        if(modifiedName.contains('Grz_Sf__')) {
            modifiedName=modifiedName.remove('Grz_Sf__');
        }
        
        if(modifiedName.containsIgnoreCase('__c')){
            modifiedName= modifiedName.remove('__c');
        }  
        if(modifiedName.contains('__'))modifiedName=modifiedName.substring(modifiedName.indexof('__')+2,modifiedName.length() );
        
        
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();   
        //NameSpace removed Grz_Sf__JiraRelationship__c to JiraRelationship__c
        genericFieldMap= schemaMap.get('JiraRelationship__c').getDescribe().fields.getMap();
        //NameSpace removed Grz_Sf__JiraIssue__c to JiraIssue__c
        Map<String,Schema.SObjectField> jiraIssueFieldMap=SchemaMap.get('JiraIssue__c').getDescribe().Fields.getMap();
        
        for(String fieldName : jiraIssueFieldList){
            if(jiraIssueFieldMap.containskey(fieldName)){
                
                labelList.add(new LabelDescriptionWrapper(jiraIssueFieldMap.get(fieldName).getDescribe().getLabel(),
                                                          fieldName,
                                                          jiraIssueFieldMap.get(fieldName).getDescribe().getType().name().toLowerCase(),
                                                          true));
                
            }else if(fieldName=='action'){
                labelList.add(new LabelDescriptionWrapper(fieldName,fieldName,fieldName,false));
            }
        }
        
        
        List<Organization> ThisOrg = [SELECT NameSpacePrefix FROM Organization LIMIT 1];
        
        if(!ThisOrg.isEmpty() && ThisOrg[0].NameSpacePrefix!= null){nameSpace = ThisOrg[0].NameSpacePrefix;}
        if(nameSpace==null||nameSpace==''){nameSpace='';}else{nameSpace=nameSpace+'__';}
        for(String key:genericFieldMap.keySet()){
            String Inkey=key.tolowerCase();
            Inkey=Inkey.remove('grz_sf__');
            nameSpace=nameSpace.toLowerCase();
            Inkey=Inkey.remove(nameSpace);
            NewgenericFieldMap.put(Inkey,genericFieldMap.get(key));
        }
        
        if(modifiedName!=NULL && modifiedName!=''){
            
            if(NewgenericFieldMap.containskey(modifiedName.tolowercase()+'relation__c')){ 
                
                RelationFieldName=String.valueOf(NewgenericFieldMap.get(modifiedName.tolowercase()+'relation__c'));
                
            }
        }
        
        if(RelationFieldName!='' && RelationFieldName!=NULL)
            query ='SELECT Id,JiraIssue__r.Name,JiraIssue__r.Priority__c,JiraIssue__r.Resolution__c,JiraIssue__c,JiraIssue__r.Jira_Link__c,JiraIssue__r.IssueType__c,JiraIssue__r.JsonData__c,JiraIssue__r.Status__c,JiraIssue__r.IssueId__c, JiraIssue__r.IssueKey__c,JiraIssue__r.Assignee__c,JiraIssue__r.Reporter__c,'+RelationFieldName+' FROM JiraRelationship__c where '+RelationFieldName+'= '+'\''+RecordId+'\' order by createdDate';
        
        if(query!='')
            jiraRelationList=Database.query(query);
        
        
        List<JiraIssue__c> jiraIssueRecordList=new List<JiraIssue__c>();
        
        for(Sobject Jrel:jiraRelationList){
            JiraRelationship__c relation=new JiraRelationship__c();
            relation=(JiraRelationship__c)Jrel;
            
            jiraIssueRecordList.add(new JiraIssue__c(id=relation.JiraIssue__C,
                                                             Name=relation.JiraIssue__r.name,
                                                             Priority__c=relation.JiraIssue__r.Priority__c,
                                                             Resolution__c=relation.JiraIssue__r.Resolution__c,
                                                             Jira_Link__c=relation.JiraIssue__r.Jira_Link__c,
                                                             IssueType__c=relation.JiraIssue__r.IssueType__c,
                                                             //JsonData__c=relation.JiraIssue__r.JsonData__c,
                                                             Status__c=relation.JiraIssue__r.Status__c,
                                                             // IssueId__c=relation.JiraIssue__r.IssueId__c,
                                                             IssueKey__c=relation.JiraIssue__r.IssueKey__c,
                                                             Assignee__c=relation.JiraIssue__r.Assignee__c,
                                                             Reporter__c=relation.JiraIssue__r.Reporter__c));
            issueKey+=relation.JiraIssue__r.IssueKey__c+',';
        }
        
        dtw.ldwList = labelList;
        dtw.sobList = jiraIssueRecordList;
        dtw.fieldsList  = jiraIssueFieldList;
        
        Map<String,JiraWrapper> LeftOverdata = new map<String,JiraWrapper>();
        issueKey=issueKey.removeEnd(',');
        HttpRequest req = new HttpRequest(); 
        Http http = new Http();
        HTTPResponse res = new HTTPResponse();
        String data;
        String issueKeyEndcoded='';
        if(issueKey!=''){
            try{
                if(!Test.isRunningTest()){
                    issueKeyEndcoded=  EncodingUtil.urlEncode(issueKey,'UTF-8');
                    req=CreateJIRAWrapper.CreateRequest('/rest/api/2/search?jql=key%20in%20%28'+issueKeyEndcoded+'%29&fields=fixVersions', 'GET', 'application/json');
                    
                    res =http.send(req); 
                    data= res.getbody();
                }else{
                    data ='{"expand":"names,schema","startAt":0,"maxResults":50,"total":1,"issues":[{"expand":"operations,versionedRepresentations,editmeta,changelog,renderedFields","id":"12222","self":"http://45.79.128.241:8080/rest/api/2/issue/12222","key":"GC-1312","fields":{"fixVersions":[{"self":"http://45.79.128.241:8080/rest/api/2/version/10001","id":"10001","description":"","name":"Version 1","archived":false,"released":false}]}}]}';
                }  
                if(res.getStatusCode()==200||Test.isRunningTest()){
                    Map<String, Object> mainData = (Map<String, Object>) JSON.deserializeUntyped(data);
                    if(mainData.containsKey('issues')){
                        list<object> issuesList = (List<object>)(mainData.get('issues'));
                        if(!issuesList.isEmpty()){
                            for(object issue : issuesList){
                                Map<String, Object> issuemap = (Map<String, Object>) issue;
                                Map<String, Object> fieldsmap = (Map<String, Object>)issuemap.get('fields');
                                LeftOverdata.put((String)issuemap.get('key'),new JiraWrapper(new JiraRelationship__c())); 
                                if(fieldsmap!=null){
                                    
                                    if(fieldsmap.containskey('fixVersions') && fieldsmap.get('fixVersions')!=null){
                                        list<object>  FixVersionList = (List<Object>)fieldsmap.get('fixVersions');
                                        for(object Fx:FixVersionList){
                                            Map<String, Object> Fxmap = (Map<String, Object>) Fx;
                                            if(Fxmap!=null && Fxmap.get('name')!=null){
                                                if(LeftOverdata.get((String)issuemap.get('key')).FixVersion!=null){
                                                    LeftOverdata.get((String)issuemap.get('key')).FixVersion+=(String)Fxmap.get('name');
                                                }else{
                                                    LeftOverdata.get((String)issuemap.get('key')).FixVersion=(String)Fxmap.get('name');
                                                }
                                                
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }else{
                    GenerateJiraLogs.CreateLogRealTime('JiraIssueRelatedListController',req.getEndpoint(), req.getMethod(),String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), null, res.getbody(),issueKey , 'Get JiraIssues', res.getBody());
                    
                }
            }catch(Exception ex){
                String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                GenerateJiraLogs.CreateLogRealTime('JiraIssueRelatedListController',req.getEndpoint(), req.getMethod(),String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), null, res.getbody(),issueKey , 'Get JiraIssues', Error);
                
            }
            for(Sobject Jrel:jiraRelationList){
                JiraRelationship__c relation=new JiraRelationship__c();
                relation=(JiraRelationship__c)relation;
                if(LeftOverdata.containskey(relation.JiraIssue__r.IssueKey__c)){
                    JiraWrapper Jw=LeftOverdata.get(relation.JiraIssue__r.IssueKey__c);
                    Jw.jiraIssueRel=relation;
                    
                    if(Jw.FixVersion==null||Jw.FixVersion==''){
                        Jw.FixVersion='---';
                    }
                    jiraIssuesList.add(Jw);
                }
            }
            
            
        }
        return dtw;
    }
    
    public class DataTableWrapper {
        @AuraEnabled
        public List<LabelDescriptionWrapper> ldwList;
        @AuraEnabled
        public List<sObject> sobList;
        @AuraEnabled
        public List<String> fieldsList;
        @AuraEnabled
        public Integer totalCount;
    }
    
    public class LabelDescriptionWrapper {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String fieldName;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public boolean sortable;    
        @AuraEnabled
        public typeAttributes typeAttributes;
        public LabelDescriptionWrapper(String labelTemp, String fieldNameTemp, String typeTemp, boolean sortableTemp) {
            label     = labelTemp;
            fieldName = fieldNameTemp;
            type      = typeTemp;
            //NameSpace removed Grz_Sf__Jira_Link__c to Jira_Link__c
            if(fieldName=='Jira_Link__c'){
                type='url';
                typeAttributes = new typeAttributes();
                typeAttributes.name='View_Jira';
                typeAttributes.label='View';
                typeAttributes.target='_blank';
                typeAttributes.tooltip='Click to visit Jira';
            }  
            
            /*if(fieldName=='Name'){
type='url';
typeAttributes = new typeAttributes();
typeAttributes.name='view_Jiradetails';
typeAttributes.target='_blank';
typeAttributes.tooltip='Click to visit Record';
} */ 
            
            if(fieldName=='action'){
                type='action';
                typeAttributes = new typeAttributes();
                actions ac=new actions();
                ac.name='Show_details';
                ac.label='Show details';
                actions ac1=new actions();
                ac1.name='Unlink_Jira';
                ac1.label='Unlink Jira';
                List<actions> actionList=new List<actions>();
                actionList.add(ac);
                actionList.add(ac1);
                typeAttributes.rowActions=actionList;
            } 
            sortable  = sortableTemp;
        }
        
    }
    public class actions{ 
        @AuraEnabled
        Public String name;
        @AuraEnabled
        Public String label;
        public actions(){
            name='';
            label='';
        }
    }
    public class typeAttributes{ 
        @AuraEnabled
        Public List<actions> rowActions;
        @AuraEnabled
        Public String name;
        @AuraEnabled
        Public String label;
        @AuraEnabled
        Public  String target;
        @AuraEnabled
        Public String tooltip; 
        Public typeAttributes(){
            rowActions=new List<actions>();
            name='';
            label='';
            target='';
            tooltip='';
            
        }
    }
    public class JiraWrapper{
        @auraEnabled
        public JiraRelationship__c jiraIssueRel{get; set;}
        @auraEnabled
        public String FixVersion;
        
        public JiraWrapper(JiraRelationship__c jiraRel){
            this.jiraIssueRel = jiraRel;
            
        }
    }
}