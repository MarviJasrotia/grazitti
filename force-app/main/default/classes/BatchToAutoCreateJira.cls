Global class BatchToAutoCreateJira implements Database.Batchable<String>,Database.AllowsCallouts,Database.Stateful{
    List<String> SobjectId_Project_Type;
    public List<JiraErrorLogs__c> JiraErrorLogs ;
    GLobal BatchToAutoCreateJira(List<String> SobjectId_Project_Type){
        this.SobjectId_Project_Type = new List<String>();
        this.SobjectId_Project_Type =SobjectId_Project_Type;
        this.JiraErrorLogs = new List<JiraErrorLogs__c>();
    }
    
    Global List<String> start(Database.BatchableContext BC) {
        
        return SobjectId_Project_Type;
    }
    Global void execute(Database.BatchableContext BC, List<String> JiraCreationDetails){
        this.JiraErrorLogs = new List<JiraErrorLogs__c>();
        
        Map<String,JiraIssue__c> JiraToInsert= new Map<String,JiraIssue__c>();
        
        for(String value:JiraCreationDetails){
            String SobjectId;
            String ProjectName;  
            String IssueType;
            List<String> metadat=value.split('_');
            if(!metadat.isEmpty() && metadat.size()>=1){
                SobjectId=metadat[0];
            }
            if(!metadat.isEmpty() && metadat.size()>=2){
                ProjectName=metadat[1];
            }
            if(!metadat.isEmpty() && metadat.size()>=3){
                IssueType=metadat[2];
            }
            //Assuming one chunk will process on jira for on sf record at a time
            JiraIssue__c Jira = CreateJiraData(SobjectId,ProjectName,IssueType);
            JiraToInsert.put(SobjectId ,Jira);
            
            
            
        }
        
        if(!JiraToInsert.isEmpty()){
            if(JiraIssue__c.sObjectType.getDescribe().isCreateable() && 
               JiraIssue__c.sObjectType.getDescribe().isUpdateable()){
                   Database.SaveResult[] ResultList = Database.insert(JiraToInsert.values(),false);
                   for (Database.SaveResult sr : ResultList) {
                       if (sr.isSuccess()) {
                           
                       }
                       else {
                           // Operation failed, so get all errors  
                           String errorMessage='';         
                           for(Database.Error err : sr.getErrors()) {
                               errorMessage=err.getStatusCode() + ': ' + err.getMessage();
                               JiraErrorLogs.add(GenerateJiraLogs.CreateJiraLog('automatedJiraIssueCreation',null, null, null, null, null, null, null,null, 'createJira', errorMessage));
                           }
                       }
                   }
                   
                   Map<String,SobjectType> SchemaMap=Schema.getGlobalDescribe();
                   //Namespace removed Grz_Sf__JiraRelationship__c to JiraRelationship__c
                   Map<String,SobjectField> relationshipfieldMap=SchemaMap.get('JiraRelationship__c').getDescribe().Fields.getMap();
                   Map<String,Schema.DescribeFieldResult> fieldDescribeMethod=new Map<String,Schema.DescribeFieldResult>();
                   for(Schema.SObjectField field:relationshipfieldMap.values()){
                       Schema.DescribeFieldResult result= field.getDescribe();
                       fieldDescribeMethod.put(String.valueof(field).toLowerCase(),result);
                   }
                   List<JiraRelationship__c> JiraRelationships = new List<JiraRelationship__c>();
                   String NameSpace='';
                   List<Organization> ThisOrg = [SELECT NameSpacePrefix FROM Organization Limit 1];
                   if(!ThisOrg.isEmpty() && ThisOrg[0].NameSpacePrefix!= null){
                       NameSpace = ThisOrg[0].NameSpacePrefix.toLowerCase();
                   }
                   for(String SobjId :JiraToInsert.keySet()){
                       
                       
                       
                       String RelationFieldName='';
                       JiraIssue__c jiraIssue=JiraToInsert.get(SobjId);
                       RelationFieldName=ID.Valueof(SobjId).getSObjectType().getDescribe().getName();
                       if(RelationFieldName.contains('Grz_Sf__')) {
                           RelationFieldName=RelationFieldName.remove('Grz_Sf__');
                       }
                       if(RelationFieldName.containsIgnoreCase('__c')){
                           RelationFieldName= RelationFieldName.remove('__c');
                       }      
                       
                       if(RelationFieldName.contains('__'))RelationFieldName=RelationFieldName.substring(RelationFieldName.indexof('__')+2,RelationFieldName.length() );
                       
                       RelationFieldName=RelationFieldName.ToLowerCase()+'relation__c';
                       //Namespace removed Grz_Sf
                       if(fieldDescribeMethod.containskey(''+RelationFieldName)){RelationFieldName=''+RelationFieldName;} 
                       
                       if(fieldDescribeMethod.containskey(NameSpace+'__'+RelationFieldName)){RelationFieldName=NameSpace+'__'+RelationFieldName; } 
                       
                       JiraRelationship__c   gJiraIssue = new JiraRelationship__c();
                       
                       if(!(Schema.sObjectType.JiraRelationship__c.fields.Jira_Issue_Link__c.isAccessible() &&
                            Schema.sObjectType.JiraRelationship__c.fields.Jira_Issue_Link__c.isCreateable())){ return;}
                       else{
                           gJiraIssue.Jira_Issue_Link__c = jiraIssue.Jira_Link__c;
                       }
                       if(!(Schema.sObjectType.JiraRelationship__c.fields.JiraIssue__c.isAccessible() &&
                            Schema.sObjectType.JiraRelationship__c.fields.JiraIssue__c.isCreateable())){ return;}
                       else{
                           gJiraIssue.JiraIssue__c = jiraIssue.Id;
                       }
                       if(!(Schema.sObjectType.JiraRelationship__c.fields.JiraIssueId__c.isAccessible()
                            && Schema.sObjectType.JiraRelationship__c.fields.JiraIssueId__c.isCreateable())){return;}
                       else{
                           gJiraIssue.JiraIssueId__c = jiraIssue.IssueId__c;
                       }
                       
                       if(fieldDescribeMethod.get(RelationFieldName).Accessible==false){ return; }
                       else{
                           gJiraIssue.put(RelationFieldName,SobjId);
                           
                       }
                       JiraRelationships.add(gJiraIssue);
                       
                   }
                   if(!JiraRelationships.isEmpty()){
                       if(JiraRelationship__c.sObjectType.getDescribe().isAccessible() 
                          && JiraRelationship__c.sObjectType.getDescribe().iscreateable()){
                              
                              insert JiraRelationships;
                          }
                   }
                   if(!JiraErrorLogs.isEmpty()){
                       if(JiraErrorLogs__c.sObjectType.getDescribe().isAccessible() 
                          && JiraErrorLogs__c.sObjectType.getDescribe().iscreateable()){
                              insert JiraErrorLogs;
                          }
                   }
                   
               }
            
        }
        
    }
    
    Global void finish(Database.BatchableContext BC) {
    }
    
    //Deprecated
    Global static void CreateJira(ID SobjectId, String ProjectName, String IssueType){}
    Global  JiraIssue__c CreateJiraData(ID SobjectId, String ProjectName, String IssueType)
    {
        String SobjectName='';
        if(SobjectId!=NULL){
            SobjectName=SobjectId.getSObjectType().getDescribe().getName();
        }
        
        if(!Jira_Project__c.sObjectType.getDescribe().isAccessible()||
           !Jira_login__c.sObjectType.getDescribe().isAccessible()||
           !JiraIssue__c.sObjectType.getDescribe().isAccessible()||
           !Jira_ProjectFieldsMapping__c.sObjectType.getDescribe().isAccessible()){
               return null;
           }
        
        Jira_Project__c JiraProject= new Jira_Project__c();
        //have to convert ruleset for sobjects
        if (ProjectName==null ||ProjectName==''){
            ProjectName=RuleSetProject.getProjectName(SobjectId);
        }
        JiraIssue__c JiraIssue = new JiraIssue__c();
        Jira_login__c  setting = [SELECT Id,Default_Jira_Project__c 
                                  from Jira_login__c
                                  where name='jira' limit 1];
        
        map<String,String> jiraProjectskeymap=new map<String,String>();
        if(Schema.sObjectType.Jira_login__c.fields.Default_Jira_Project__c.isAccessible()){
            if((projectName==null||projectName=='') &&
               setting.Default_Jira_Project__c!=NULL && setting.Default_Jira_Project__c!=''){
                   projectName = setting.Default_Jira_Project__c;    
               }
        }
        List<Jira_Project__c>jiraProjectList= new List<Jira_Project__c>();
        
        if(projectName!=null && projectName!=''){
            jiraProjectList=[select id,Name,ProjectKey__c,ProjectId__c,Read__c, DefaultIssueType__c, IssueType__c, Write__c,Subtask__c 
                             from Jira_Project__c 
                             where ProjectKey__c =:projectName limit 1];
            if(!jiraProjectList.isEmpty()){
                jiraProjectskeymap.put(jiraProjectList[0].ProjectKey__c,jiraProject.id);
                if(IssueType==null ||IssueType==''){
                    if(Schema.sObjectType.Jira_Project__c.fields.DefaultIssueType__c.isAccessible() &&
                       Schema.sObjectType.JiraIssue__c.fields.IssueType__c.isCreateable()){
                           jiraIssue.IssueType__c = jiraProjectList[0].DefaultIssueType__c;
                       }
                }else if((jiraProjectList[0].DefaultIssueType__c!=null && jiraProjectList[0].DefaultIssueType__c.contains(IssueType))||
                         (jiraProjectList[0].IssueType__c!=null && jiraProjectList[0].IssueType__c.contains(IssueType))){
                             if(Schema.sObjectType.JiraIssue__c.fields.IssueType__c.isCreateable()){
                                 jiraIssue.IssueType__c=IssueType;
                             }
                         }else{
                             if(Schema.sObjectType.Jira_Project__c.fields.DefaultIssueType__c.isAccessible() &&
                                Schema.sObjectType.JiraIssue__c.fields.IssueType__c.isCreateable ()){
                                    jiraIssue.IssueType__c = jiraProjectList[0].DefaultIssueType__c;
                                }                         
                         }
                if(Schema.sObjectType.Jira_Project__c.fields.ProjectKey__c.isAccessible() &&
                   Schema.sObjectType.JiraIssue__c.fields.Project__c.isCreateable ()){
                       jiraIssue.Project__c = jiraProjectList[0].ProjectKey__c;
                   }    
            }else{
                return null;
            }
            
        }
        
        list<DynamicFieldWrapper> DynamicFieldWrapperList = new list<DynamicFieldWrapper>();
        Set<string> SobjectFieldList = new Set<string>();
        
        
        list<Jira_ProjectFieldsMapping__c> dynamicFieldsDataquery =[SELECT Id,IsStatic__c, Name,ReqInIssueTypeData__c, RequiredInSF__c,IssueTypeData__c, Case_Field_Name__c,  IsRequired__c, 
                                                                    IsArray__c,  DataType__c, order__c,Default_Value_long__c, JIRA_Field_Api_Name__c,ViewMode__c ,RelatedProjectIdSet__c,  ProjectissueTypeData__c, 
                                                                    ReadOnly__c,  Released__c,  Jira_Project__c,Jira_Project__r.Projectkey__c,  Jira_Field_Name__c , section__c,
                                                                    Jira_Project__r.IssueType__c,Jira_Project__r.DefaultIssueType__c, section__r.column__c,
                                                                    section__r.name,jira_Project__r.Subtask__c 
                                                                    FROM  Jira_ProjectFieldsMapping__c 
                                                                    where Jira_Project__r.Projectkey__c=:projectName 
                                                                    and Salesforce_Object__c =:SobjectName ];
        list<Jira_ProjectFieldsMapping__c> FinaldynamicFieldsDataquery =new  list<Jira_ProjectFieldsMapping__c>();
        for (Jira_ProjectFieldsMapping__c jp:dynamicFieldsDataquery){
            if(!Schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.IssueTypedata__c.isAccessible()){
                return null;
            }  
            list<String> IssueTypeList =jp.IssueTypedata__c.split(',');
            
            Set<String> IssyeTypeSet = new Set<String>();
            for(String IssueString:IssueTypeList){
                IssyeTypeSet.add('--'+IssueString+'--');
            }
            if(!IssyeTypeSet.contains('--'+jiraIssue.IssueType__c+'--') && !IssyeTypeSet.contains('--All--')){
                continue;
            }else{
                FinaldynamicFieldsDataquery.add(jp);
            }
            if(Schema.sObjectType.Jira_Project__c.fields.ProjectKey__c.isAccessible() &&
               Schema.sObjectType.JiraIssue__c.fields.Project__c.isCreateable ()){
                   jiraIssue.Project__c = jiraProjectList[0].ProjectKey__c;
               }  
            if(Schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.Case_Field_Name__c.isAccessible()){
                if (jp.Case_Field_Name__c != null && jp.Case_Field_Name__c != ''){
                    SobjectFieldList.add(jp.Case_Field_Name__c);
                }
            }
        }
        Sobject dynamicObjectType = Schema.getGlobalDescribe().get(SobjectName).newSObject(); 
        
        if(!SobjectFieldList.isEmpty()){
            SobjectFieldList.add('Id');
            list<String> QueryFieldsList = new List<String>();
            QueryFieldsList.addAll(SobjectFieldList);
            string SobjectDataQuery = '';
            SobjectDataQuery=String.join(QueryFieldsList, ',');
            SobjectDataQuery='Select '+ SobjectDataQuery +' From '+SobjectName+' Where Id =\''+SobjectId+'\'';
            List<Sobject> genericSobjectList=new List<Sobject>();
            if(Schema.getGlobalDescribe().get(SobjectName).getDescribe().isAccessible()){
                genericSobjectList=Database.Query(SobjectDataQuery);
            }
            if(!genericSobjectList.isEmpty()){
                if(Schema.getGlobalDescribe().get(SobjectName).getDescribe().isCreateable()){
                    dynamicObjectType=genericSobjectList[0];
                }
            }else{
                return null;
            }
        }
        Boolean ObjectMapValue=false;
        JSONGenerator JiraJsonGen = JSON.createGenerator(false);  
        JiraJsonGen.writeStartObject();
        JiraJsonGen.writeFieldName('fields');
        JiraJsonGen.writeStartObject();
        JiraJsonGen.writeFieldName('project');
        JiraJsonGen.writeStartObject();
        JiraJsonGen.writeObjectField('id',jiraProjectList[0].ProjectId__c);
        JiraJsonGen.writeObjectField('key',jiraProjectList[0].ProjectKey__c);
        JiraJsonGen.writeObjectField('name',jiraProjectList[0].Name);
        JiraJsonGen.writeEndObject();
        for(Jira_ProjectFieldsMapping__c Jp: FinaldynamicFieldsDataquery){ 
            String Value;
            if(jp.Case_Field_Name__c!=null){
                Value= string.valueof(dynamicObjectType.get(jp.Case_Field_Name__c));
                ObjectMapValue=true;
            }else if(jp.Default_Value_long__c!=null){
                Value =jp.Default_Value_long__c;
                ObjectMapValue=false;
            }else if(jp.JIRA_Field_Api_Name__c=='issuetype'){
                Value=  jiraIssue.IssueType__c;
            }
            
            if(value==Null || Value ==''){
                continue;
            }
            DynamicFieldWrapper dynamicWrapper =new  DynamicFieldWrapper(jp,'');
            JiraJsonGen =CreateFieldJson(Value,dynamicWrapper,JiraJsonGen,ObjectMapValue);
            
            
        }
        JiraJsonGen.writeEndObject();
        JiraJsonGen.writeEndObject();
        String FinalJsonData=JiraJsonGen.getAsString();
        
        if (FinalJsonData!=null){
            JiraIssue__c Jira = save(jiraProject,SobjectId,jiraIssue,projectName,jiraProjectskeymap,FinalJsonData);
            return Jira;
        }
        return null;
    } 
    public  JiraIssue__c save(Jira_Project__c jiraProject,Id SobjectId,jiraIssue__c jiraIssue,string projectName, map<string,string> jiraProjectskeymap,String FieldJson){ 
        
        String EndPoint = Jira_login__c.getValues('JIRA')!= null? Jira_login__c.getValues('JIRA').End_Point__c!= null ? Jira_login__c.getValues('JIRA').End_Point__c+'/browse/' : '' : '';
        string errorMessage='';
        String dynamicData = '';
        String TempValue= '';
        String IssyeTypeJsonData='';
        //string caseNumberApi=CaseNumberField__c.getValues('FieldApi')!=Null?CaseNumberField__c.getValues('FieldApi').JiraFieldApi__c:'';
        
        try{
            Http http = new Http();
            HttpRequest req = new HttpRequest(); 
            req = CreateJIRAWrapper.CreateRequest('/rest/api/2/issue' ,'POST','application/json');
            req.setBody(FieldJson); 
            HTTPResponse res = new HttpResponse(); 
            if(!Test.isRunningTest() ){
                res = http.send(req);
            }
            if(res.getStatusCode()==201 ||Test.isRunningTest()){
                
                if( Schema.sObjectType.JiraIssue__c.fields.Status__c.isUpdateable() && Schema.sObjectType.JiraIssue__c.fields.Status__c.isCreateable() ) {
                    jiraIssue.Status__c = '';
                }
                if( Schema.sObjectType.JiraIssue__c.fields.Project__c.isUpdateable() && Schema.sObjectType.JiraIssue__c.fields.Project__c.isCreateable() ) {
                    jiraIssue.Project__c=projectName;
                }
                if( Schema.sObjectType.JiraIssue__c.fields.Project_Id__c.isUpdateable() && Schema.sObjectType.JiraIssue__c.fields.Project_Id__c.isCreateable() ) {
                    jiraIssue.Project_Id__c =  jiraIssue.Project__c!=null && String.IsnotEmpty(jiraIssue.Project__c) && JiraProject.ProjectId__c!=null?
                        Decimal.valueOf(JiraProject.ProjectId__c):null;
                }
                Map<String, Object> responseMap;
                
                String response=res.getBody();
                response=response.removeEnd('}');
                response=response+','+FieldJson.removeStart('{');
                String JsonResponse= res.getBody();
                if(Test.isRunningTest()){
                    JsonResponse='{"key":"GC-1044","id":"10000"}';
                }
                responseMap = (Map<String, Object>)JSON.deserializeUntyped(JsonResponse);
                if( Schema.sObjectType.JiraIssue__c.fields.IssueId__c.isUpdateable() && Schema.sObjectType.JiraIssue__c.fields.IssueId__c.isCreateable() ){
                    jiraIssue.IssueId__c = Decimal.valueOf((String)responseMap.get('id'));
                }
                
                if( Schema.sObjectType.JiraIssue__c.fields.IssueKey__c.isUpdateable() && Schema.sObjectType.JiraIssue__c.fields.IssueKey__c.isCreateable() ){
                    jiraIssue.IssueKey__c = (String)responseMap.get('key');
                }
                
                if( Schema.sObjectType.JiraIssue__c.fields.name.isUpdateable() && Schema.sObjectType.JiraIssue__c.fields.name.isCreateable() ){ 
                    jiraIssue.name = (String)responseMap.get('key');
                }
                
                if( Schema.sObjectType.JiraIssue__c.fields.Jira_Link__c.isUpdateable() && Schema.sObjectType.JiraIssue__c.fields.Jira_Link__c.isCreateable() ){
                    jiraIssue.Jira_Link__c = EndPoint +jiraIssue.IssueKey__c;
                }
                
                if( Schema.sObjectType.JiraIssue__c.fields.Updated__c.isUpdateable() && Schema.sObjectType.JiraIssue__c.fields.Updated__c.isCreateable() ){
                    jiraIssue.Updated__c = DateTime.now();
                }
                
                if(jiraIssue.Created__c==null){
                    if( Schema.sObjectType.JiraIssue__c.fields.Created__c.isUpdateable() && Schema.sObjectType.JiraIssue__c.fields.Created__c.isCreateable() ) {
                        jiraIssue.Created__c = DateTime.now();
                    }
                }
                if( Schema.sObjectType.JiraIssue__c.fields.JsonData__c.isUpdateable() && Schema.sObjectType.JiraIssue__c.fields.JsonData__c.isCreateable() ) {
                    jiraIssue.JsonData__c = response;
                }
                return jiraIssue;
                //------------------------------------------------------------------------------
            }else{
                errorMessage = res.getStatusCode()+'--'+res.getBody();
                JiraErrorLogs.add(GenerateJiraLogs.CreateJiraLog('automatedJiraIssueCreation',req.getEndPoint(), req.getMethod(), String.valueof(res.getStatusCode()), res.getBody(),res.getStatus(), req.getBody(), null, SobjectId, 'createJira', errorMessage));
            }
            
            
        }catch(Exception ex){
            errorMessage ='Cause: '+ex.getCause()+'\n'+'LineNumber: '+ex.getLineNumber()+'\n'+'Message: '+ex.getMessage();
            JiraErrorLogs.add(GenerateJiraLogs.CreateJiraLog('automatedJiraIssueCreation',null,null, null, null,null,null, null, SobjectId, 'createJira', errorMessage));
        }
        return null; 
    }     
    //cascadingselect,labels,Non Array Version,radiobuttons,select,user,userpicker,multiuserpicker,Array Version,multiversion,component,multicheckboxes,multiselect,textarea,textfield,url,datetime,datepicker,long,decimal,integer ,float
    public static JSONGenerator CreateFieldJson(String Value,DynamicFieldWrapper Dynamic,JSONGenerator JsonObj,Boolean ObjectMapValue){
        String  DataType=Dynamic.mappedField.DataType__c;
        if(dynamic.mappedField.IsArray__c || DataType=='version'){
            
            if(DataType.toLowerCase()=='cascadingselect' ){
                dynamic.masterFieldValue=dynamic.clubMasterMapRev.get(value);
                if(value.contains('_child_')){
                    list<String> DepValue=value.split('_child_');
                    String MasterValue=DepValue[0];
                    String ChildValue=DepValue[1];
                    
                    JsonObj.writeFieldName(dynamic.mappedField.JIRA_Field_Api_Name__c);
                    JsonObj.writeStartObject();
                    JsonObj.writeObjectField('id',MasterValue);
                    JsonObj.writeFieldName('child');
                    JsonObj.writeStartObject();
                    JsonObj.writeObjectField('id',ChildValue);
                    JsonObj.writeEndObject();
                    JsonObj.writeEndObject();
                    
                }
                
            }
            
            if(DataType.toLowerCase()=='labels'||dynamic.mappedField.JIRA_Field_Api_Name__c=='labels'){
                value=value.replaceAll(',',' ');
                list<string> SelectedValue= value.split(' ');
                jsonObj.writeFieldName(dynamic.mappedField.JIRA_Field_Api_Name__c);
                JsonObj.writeStartArray();
                for(string val:SelectedValue){
                    JsonObj.writeString(val);
                }
                JsonObj.writeEndArray();
                
            }
            
            if((DataType.toLowerCase()=='version' && !dynamic.mappedField.IsArray__c)||
               DataType.toLowerCase()=='select'|| DataType.toLowerCase()=='radiobuttons'){
                   value=value.removeEnd(',');
                   for(String key:dynamic.selectValueMap.keySet()){
                       if(key.toLowerCase().equals(value.toLowerCase())){
                           JsonObj.writeFieldName(dynamic.mappedField.JIRA_Field_Api_Name__c);
                           JsonObj.writeStartObject();
                           JsonObj.writeObjectField('id',dynamic.selectValueMap.get(key));
                           JsonObj.writeObjectField('value',key);
                           JsonObj.writeEndObject();
                       }
                   }
               }
            
            if((DataType.toLowerCase()=='userpicker'||
                DataType.toLowerCase()=='user') && value != null && value != ''){
                    if(ObjectMapValue){
                        String UserSearch=Value;
                        
                        HttpResponse res = new HttpResponse();
                        Http http = new Http();
                        HttpRequest req = new HttpRequest();
                        String jsonInput;
                        req = CreateJIRAWrapper.CreateRequest('/rest/api/2/user/search?username='+EncodingUtil.urlEncode(usersearch, 'UTF-8'), 'GET', 'application/json');
                        if(!Test.isRunningTest() ){
                            res = http.send(req);
                            jsonInput = res.getBody();
                        }else{
                            jsonInput='[{"accountId": "59f87c4350d3594d73a7cc72","accountType": "atlassian","emailAddress": "sandeep.s@grazitti.com","displayName": "Sandeep Supehia"}]';
                        }
                        if(res.getStatusCode()==200||Test.isRunningTest()){
                            
                            List<Object>userlist = (List<Object>)JSON.deserializeUntyped(jsonInput);
                            if(!userlist.isEmpty()){
                                for(object obj : userlist){
                                    Map<String, Object> UserMapobject = (Map<String, Object>)obj;
                                    JsonObj.writeFieldName(dynamic.mappedField.JIRA_Field_Api_Name__c);
                                    JsonObj.writeStartObject();
                                    if(UserMapobject.containsKey('accountId')){
                                        String  AccountId =String.valueof(UserMapobject.get('accountId'));
                                        JsonObj.writeObjectField('accountId',AccountId);
                                    }
                                    if(UserMapobject.containsKey('displayName')){
                                        String  DisplayName =String.valueof(UserMapobject.get('displayName'));
                                        JsonObj.writeObjectField('displayName',DisplayName);
                                        
                                    }
                                    if(UserMapobject.containsKey('name')){
                                        String Username =String.valueof(UserMapobject.get('name'));
                                        JsonObj.writeObjectField('name',Username);
                                    }
                                    JsonObj.writeEndObject();
                                    break;
                                    
                                }
                            }
                        }
                    }else{
                        
                        Map<String, Object> UserMapobject = (Map<String, Object>)Json.deserializeUntyped(Value);
                        JsonObj.writeFieldName(dynamic.mappedField.JIRA_Field_Api_Name__c);
                        JsonObj.writeStartObject();
                        if(UserMapobject.containsKey('accountId')){
                            String  AccountId =String.valueof(UserMapobject.get('accountId'));
                            JsonObj.writeObjectField('accountId',AccountId);
                        }
                        if(UserMapobject.containsKey('displayName')){
                            String  DisplayName =String.valueof(UserMapobject.get('displayName'));
                            JsonObj.writeObjectField('displayName',DisplayName);
                            
                        }
                        if(UserMapobject.containsKey('name')){
                            String Username =String.valueof(UserMapobject.get('name'));
                            JsonObj.writeObjectField('name',Username);
                        }
                        JsonObj.writeEndObject();
                    }
                }
            
            if(DataType.toLowerCase()=='multiuserpicker' && value != null && value != ''){
                if(ObjectMapValue){
                    list<String> UserSearchList=Value.split(',');
                    HttpResponse res = new HttpResponse();
                    Http http = new Http();
                    HttpRequest req = new HttpRequest();
                    String jsonInput;
                    Boolean ObtStarted =false;
                    for (string userSearch:UserSearchList ){
                        req = CreateJIRAWrapper.CreateRequest('/rest/api/2/user/search?username='+EncodingUtil.urlEncode(usersearch, 'UTF-8'), 'GET', 'application/json');
                        if(!Test.isRunningTest()){
                            res = http.send(req);
                            jsonInput = res.getBody();
                            
                        }else{
                            jsonInput='[{"accountId": "59f87c4350d3594d73a7cc72","accountType": "atlassian","emailAddress": "sandeep.s@grazitti.com","displayName": "Sandeep Supehia"}]';
                        }
                        if(res.getStatusCode()==200||Test.isRunningTest()){
                            
                            List<Object>userlist = (List<Object>)JSON.deserializeUntyped(jsonInput);
                            if(!userlist.isEmpty()){
                                for(object obj : userlist){
                                    Map<String, Object> UserMapobject = (Map<String, Object>)obj;
                                    if(!ObtStarted){
                                        JsonObj.writeFieldName(dynamic.mappedField.JIRA_Field_Api_Name__c);
                                        JsonObj.writeStartArray();
                                        ObtStarted=true;
                                    }
                                    JsonObj.writeStartObject();
                                    if(UserMapobject.containsKey('accountId')){
                                        String  AccountId =String.valueof(UserMapobject.get('accountId'));
                                        JsonObj.writeObjectField('accountId',AccountId);
                                    }
                                    if(UserMapobject.containsKey('displayName')){
                                        String  DisplayName =String.valueof(UserMapobject.get('displayName'));
                                        JsonObj.writeObjectField('displayName',DisplayName);
                                        
                                    }
                                    if(UserMapobject.containsKey('name')){
                                        String Username =String.valueof(UserMapobject.get('name'));
                                        JsonObj.writeObjectField('name',Username);
                                    }
                                    JsonObj.writeEndObject();
                                    
                                }
                            }
                        }
                        
                    }
                    if(ObtStarted){
                        JsonObj.writeEndArray();
                    }
                }else{
                    Map<String, Object> Userobject = (Map<String, Object>)JSON.deserializeUntyped(value);
                    if(Userobject.get('users')==null){
                        return JsonObj ;
                    }
                    List<Object>userlist = (List<Object>)(Userobject.get('users'));
                    if(!userlist.isEmpty()){
                        JsonObj.writeFieldName(dynamic.mappedField.JIRA_Field_Api_Name__c);
                        JsonObj.writeStartArray();
                        for(object obj : userlist){
                            Map<String, Object> UserMapobject = (Map<String, Object>)obj;
                            JsonObj.writeStartObject();
                            if(UserMapobject.containsKey('accountId')){
                                String  AccountId =String.valueof(UserMapobject.get('accountId'));
                                JsonObj.writeObjectField('accountId',AccountId);
                            }
                            if(UserMapobject.containsKey('displayName')){
                                String  DisplayName =String.valueof(UserMapobject.get('displayName'));
                                JsonObj.writeObjectField('displayName',DisplayName);
                                
                            }
                            if(UserMapobject.containsKey('name')){
                                String Username =String.valueof(UserMapobject.get('name'));
                                JsonObj.writeObjectField('name',Username);
                            }
                            JsonObj.writeEndObject();
                        }
                        JsonObj.writeEndArray();
                    }
                }
                
            }
            
            
            if(dynamic.mappedField.IsArray__c && 
               (DataType.toLowerCase()=='multiversion'||
                DataType.toLowerCase()=='multiselect'||
                DataType.toLowerCase()=='multicheckboxes'||
                DataType.toLowerCase()=='version'||
                DataType.toLowerCase()=='component')){
                    list<String> ValueList = new list<String>(); 
                    if(Value.contains(';')){
                        ValueList= Value.split(';');
                    }else{
                        ValueList= Value.split(',');
                    }
                    JsonObj.writeFieldName(dynamic.mappedField.JIRA_Field_Api_Name__c);
                    JsonObj.writeStartArray();
                    for(String Temp: ValueList){     
                        
                        for(String Selectvalue:dynamic.selectValueMap.keyset()){
                            if(Temp.trim()==Selectvalue.trim()){
                                Selectvalue=Selectvalue.trim();
                                JsonObj.writeStartObject();
                                JsonObj.writeObjectField('id', dynamic.selectValueMap.get(Selectvalue));
                                JsonObj.writeObjectField('value', Selectvalue);
                                JsonObj.writeEndObject();
                            }
                            
                        }
                        
                    }
                    JsonObj.writeEndArray();
                }
            
        } 
        else{ 
            
            if(DataType.toLowerCase()=='float'||
               DataType.toLowerCase()=='double'||
               DataType.toLowerCase()=='integer'||
               DataType.toLowerCase()=='decimal'||
               DataType.toLowerCase()=='long'){
                   Decimal Val = Decimal.valueOf(Value);
                   JsonObj.writeNumberField(dynamic.mappedField.JIRA_Field_Api_Name__c, Val);
               }
            if(DataType.toLowerCase()=='datetime'){
                if(!value.contains('T')){
                    DateTime dt=DateTime.valueOf(value);
                    value=String.valueOf(dt.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
                }
                JsonObj.writeStringField(dynamic.mappedField.JIRA_Field_Api_Name__c, value);
            }
            if(DataType.toLowerCase()=='datepicker'){
                JsonObj.writeStringField(dynamic.mappedField.JIRA_Field_Api_Name__c, value);
            }
            if(DataType.toLowerCase()=='url'||
               DataType.toLowerCase()=='textfield'||
               DataType.toLowerCase()=='textarea'||
               DataType.toLowerCase()=='string'){
                   JsonObj.writeStringField(dynamic.mappedField.JIRA_Field_Api_Name__c, value);
               }
        }
        return JsonObj;
    }
    
    
}