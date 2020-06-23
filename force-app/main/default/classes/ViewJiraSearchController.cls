/**
* This is a ViewJiraSearchController Class. It is used to fetch the detail data of a Jira Ticket from the Jira Instance and data is shown 
on the page according to the field configuration section 
* Latest modification done to this class on 28/01/2020 By Ashish Thakur 
**/

public with sharing Class ViewJiraSearchController{
        public String lang{get;set;}
    public List<JiraErrorLogs__c> JiraLogsToInsert;
    public string abc;
    public string jiraIssue;
    public map<String,String> jiraProjectskeymap{get;set;}
    public list<DynamicFieldWrapper> DynamicFieldWrapperList{get;set;}
    public Sobject genericObject{get;set;}
    public string mode{get;set;}
    public string ErrorMessage{get;set;}
    public String linkType{get;set;}
    public JiraIssue__c jira{get;set;}
    public map<String,Jira_Project__c> JiraProjectKey{get;set;} 
    public List<string> sectionorder{get; set;}
    public map<String,list<DynamicFieldWrapper>>sectionToDynamicFieldWrapperListMap{get; set;}
    public set<String> creatableProjects{get; set;}
    public Boolean projectIsCreatable{get; set;}
    public String epicName { get;set;}
    Jira_ProjectFieldsMapping__c jiraField = new Jira_ProjectFieldsMapping__c();
    public Map<String,List<FieldJsonHelper.LinkedIssues>> IssuelinksMap {get;set;}
    public Integer SizeOfMapLI {get;set;}
    Jira_ProjectFieldsMapping__c issueLinkField = new Jira_ProjectFieldsMapping__c();
    public Jira_login__c setting{get;set;}
    public String NameSpace='';
    string tasktype='';
    public ID genericObjectId{get;set;}
    String genericObjectName;
    String projectKey='';
    public list<SelectOption> Languages {get;set;}
    /**
*On the ViewSearchjira load, This constructor is called
**/
    public ViewJiraSearchController(){
        lang=userinfo.getLanguage();
        Languages = JiraService.LanguageOptions();
        String Pagelng= ApexPages.currentPage().getParameters().get('lg');
        if(Pagelng!=null && Pagelng!=''){
            lang=Pagelng;
        }
        SizeOfMapLI = 0;
        creatableProjects=new set<String>();
        sectionorder = new List<string>();
        projectIsCreatable=true;
        sectionToDynamicFieldWrapperListMap = new  map<String,list<DynamicFieldWrapper>>();
        List<Organization> ThisOrg = [SELECT NameSpacePrefix FROM Organization LIMIT 1];
        
        if(!ThisOrg.isEmpty() && ThisOrg[0].NameSpacePrefix!= null)
            NameSpace = ThisOrg[0].NameSpacePrefix.toLowerCase();
        
        if(Jira_ProjectFieldsMapping__c.sObjectType.getDescribe().isAccessible()){
            
            for (Jira_ProjectFieldsMapping__c jiraFields : [SELECT Id, JIRA_Field_Api_Name__c FROM Jira_ProjectFieldsMapping__c where Jira_Field_Name__c ='Epic Name' and DataType__c ='gh-epic-label' limit 1]) {
                jiraField = jiraFields;
            }
            
            for (Jira_ProjectFieldsMapping__c issueLinkFields : [SELECT Id, JIRA_Field_Api_Name__c FROM Jira_ProjectFieldsMapping__c where JIRA_Field_Api_Name__c ='issuelinks' and DataType__c ='issuelinks' limit 1]) {
                
                issueLinkField = issueLinkFields;
            }
        }
        
        mode = Apexpages.currentPage().getParameters().get('mode');
        
        //jira Issue-Key is passed as Id
        jiraIssue = ApexPages.currentPage().getParameters().get('id');
        // here id means jira issue number i.e id=GC-168
        
        if(jiraIssue!=NULL && jiraissue!='')
            projectKey=jiraIssue.substring(0,jiraIssue.indexof('-'));
        
        //Fetch the id of generic Object
        genericObjectId=ApexPages.CurrentPage().getParameters().get('Objectid');
        
        //Fetch the Type
        linkType = Apexpages.currentPage().getParameters().get('type');
        
        //New Instance of Jira Issue
        jira= new JiraIssue__c();
        
        jiraProjectskeymap=new map<String,String>();
        JiraProjectKey= new map<String,Jira_Project__c>();
        
        //Fetch the Jira projects
        if(Jira_Project__c.sObjectType.getDescribe().isAccessible()){
            for(Jira_Project__c project:[select id,Name,ProjectKey__c,SubTask__c,ProjectId__c,DefaultIssueType__c, IssueType__c, write__c from Jira_Project__c LIMIT 1000]){
                if(Schema.sObjectType.Jira_Project__c.fields.ProjectKey__c.isAccessible()){
                    JiraProjectKey.put(project.ProjectKey__c,project);
                }
                if(Schema.sObjectType.Jira_Project__c.fields.ProjectKey__c.isAccessible() && Schema.sObjectType.Jira_Project__c.fields.id.isAccessible()){
                    jiraProjectskeymap.put(project.ProjectKey__c,project.id);
                }
                if(project.write__c && Schema.sObjectType.Jira_Project__c.fields.ProjectKey__c.isAccessible()){
                    creatableProjects.add(project.ProjectKey__c);
                }
            }
        }
        //Fetch the jira End Point
        if(Jira_login__c.sObjectType.getDescribe().isAccessible()){
            setting = [select id,End_Point__c,Default_Jira_Project__c from Jira_login__c where name = 'JIRA' LIMIT 1];
        }
        //pass the jira Issue-Key
        ViewJiraData(jiraIssue);      
    }
    
    /**
*The method is called from the constructor to fetch the Jira Issue data from the Jira instance in real time.
*All the Jira data is shown on the viewSearchJira Page as per the mapping done on the Admin Setting page under field Configuration section.
*@Param - the Jira issue key E.g JC-300 is passed and data is retrieved from jira for the fields sent with the Rest API
*@Return - NULL 
**/
    public  void ViewJiraData(String jiraKey){
        Set<String> ApiNameSet=new  Set<String>();
        map<String,Jira_Project__c> ProjectkeyToObjectmap = new  map<String,Jira_Project__c>();
        Map<String,String> FieldNameByDataType = New Map<String,String>();
        JiraLogsToInsert = new List<JiraErrorLogs__c>();
        String EndPoint = Jira_login__c.getValues('JIRA')!= null? Jira_login__c.getValues('JIRA').End_Point__c!= null ? Jira_login__c.getValues('JIRA').End_Point__c : '' : '';        
        string apiName='';
        
        //FIND OUT THE OBJECT NAME 
        genericObjectName=genericObjectID.getSObjectType().getDescribe().getName();
        
        list<JiraIssue__c> jiralist= new list<JiraIssue__c>();
        
        //Fetch the Jira Issue based on issue-key
        if(JiraIssue__c.sObjectType.getDescribe().isAccessible()){
            jiralist =[select id,Name,Description__c ,IssueKey__c ,IssueId__c,IssueType__c,Jira_Link__c ,Priority__c,Project_Id__c,Project__c,Reporter__c,Status__c,Summary__c,Assignee__c,JsonData__c, CaseNos__c,Creator__c,Created__c,Resolution__c,ResolutionDate__c from JiraIssue__c where IssueKey__c=:jirakey];
        }
        
        List<Jira_ProjectFieldsMapping__c> dynamicFieldsData=new List<Jira_ProjectFieldsMapping__c>();
        if(Jira_ProjectFieldsMapping__c.sObjectType.getDescribe().isAccessible()){
            if(jiralist.size()>0 && jiralist !=NULL){
                dynamicFieldsData=[SELECT Id,IsStatic__c, Jira_Project__r.Subtask__c,Name,ReqInIssueTypeData__c, RequiredInSF__c,IssueTypeData__c, Case_Field_Name__c,  IsRequired__c,  IsArray__c,  DataType__c,  JIRA_Field_Api_Name__c,ViewMode__c ,RelatedProjectIdSet__c,  ProjectissueTypeData__c,  ReadOnly__c,  Released__c,  Jira_Project__c,Jira_Project__r.Projectkey__c,  Jira_Field_Name__c , section__c,Jira_Project__r.IssueType__c,Jira_Project__r.DefaultIssueType__c, section__r.column__c, section__r.name FROM  Jira_ProjectFieldsMapping__c where Jira_Project__r.Projectkey__c=:jiralist[0].Project__c AND Salesforce_Object__c=:genericObjectName order by section__r.order__c,order__c Asc nulls last  limit 1000];
                
            }else{
                dynamicFieldsData=[SELECT Id,IsStatic__c,Jira_Project__r.Subtask__c, Name,ReqInIssueTypeData__c, RequiredInSF__c,IssueTypeData__c, Case_Field_Name__c,  IsRequired__c,  IsArray__c,  DataType__c,  JIRA_Field_Api_Name__c,ViewMode__c ,RelatedProjectIdSet__c,  ProjectissueTypeData__c,  ReadOnly__c,  Released__c,  Jira_Project__c,Jira_Project__r.Projectkey__c,  Jira_Field_Name__c , section__c,Jira_Project__r.IssueType__c,Jira_Project__r.DefaultIssueType__c, section__r.column__c, section__r.name FROM  Jira_ProjectFieldsMapping__c where  Salesforce_Object__c=:genericObjectName AND  Jira_Project__r.Projectkey__c=:projectKey order by section__r.order__c,order__c Asc nulls last  limit 1000];        
            }
        }
        //Fetch the Jira projects MAP(JC,ProjectRecord)
        if(Jira_Project__c.sObjectType.getDescribe().isAccessible()){
            for(Jira_Project__c project:[select id,Name,ProjectKey__c,ProjectId__c from Jira_Project__c LIMIT 1000]){
                ProjectkeyToObjectmap.put(project.ProjectKey__c,project);
            }
        }
        //JiraService is a Class that returns Project Field Mapping Map(jiraProjectFieldMap,DataType)
        for(Jira_ProjectFieldsMapping__c s:dynamicFieldsData){
            FieldNameByDataType.put(s.JIRA_Field_Api_Name__c , s.DataType__c);
            ApiNameSet.add(s.JIRA_Field_Api_Name__c);
        }
        //Make a Dynamic query withfield.JIRA_Field_Api_Name__c  the JiraFieldAPIName from jira Project Field Mapping
        ApiNameSet.add('id');
        ApiNameSet.add('issuetype');
        ApiNameSet.add('status');
        ApiNameSet.add('summary');
        ApiNameSet.add('description');
        ApiNameSet.add('priority');
        ApiNameSet.add('project');
        ApiNameSet.add('reporter');
        ApiNameSet.add('assignee');
        ApiNameSet.add('components');
        ApiNameSet.add('fixVersions');
        ApiNameSet.add('created');
        ApiNameSet.add('creator'); 
        
        List<String>Apinameslist= new List<String>();
        Apinameslist.addAll(ApiNameSet);
        apiName=String.join(Apinameslist, ',');
        
        
        
        if(!jiralist.isEmpty()){
            jira=jiralist[0];
        }else{ 
            
            try{
                
                HttpResponse res = new HttpResponse();
                Http http = new Http();
                String jsonInput;
                HttpRequest req = new HttpRequest();
                apiName=EncodingUtil.urlEncode(apiName, 'UTF-8');
                req=CreateJIRAWrapper.CreateRequest('/rest/api/2/issue/' + jiraKey+'?fields='+apiName, 'GET', 'application/json');
                res = http.send(req);
                jsonInput = res.getBody();    
                
                if(res.getStatusCode()==200){
                    
                    Map<String, Object> projectResponseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
                    Map<String, Object> issueTypesMap = new Map<String, Object>();                                 
                    Object FieldObj=projectResponseMap.get('fields');
                    String FieldJson = JSON.serialize(FieldObj); 
                    
                    Map<String, Object> FieldSet = (Map<String, Object>)JSON.deserializeUntyped(FieldJson);  
                    if(Schema.sObjectType.JiraIssue__c.fields.Name.isCreateable() && projectResponseMap.get('key')!=null && projectResponseMap.get('key')!='' ){
                        jira.Name= String.valueOf(projectResponseMap.get('key'));
                    }
                    if(Schema.sObjectType.JiraIssue__c.fields.Description__c.isCreateable() && FieldSet.get('description')!=null && FieldSet.get('description')!='') {
                        String val=String.valueOf(FieldSet.get('description'));
                        jira.Description__c=val.stripHtmlTags();
                    }
                    if(Schema.sObjectType.JiraIssue__c.fields.IssueId__c.isCreateable() && projectResponseMap.get('id')!=null && projectResponseMap.get('id')!=''){
                        jira.IssueId__c=Decimal.valueOf(String.valueOf(projectResponseMap.get('id')));
                    }
                    if(Schema.sObjectType.JiraIssue__c.fields.IssueKey__c.isCreateable() && projectResponseMap.get('key')!=null && projectResponseMap.get('key')!=''){
                        jira.IssueKey__c=String.valueOf(projectResponseMap.get('key'));
                    }
                    
                    //String issuetypedata= JSON.serialize(FieldSet.get('issuetype'));
                    
                    if(FieldSet.containskey('issuetype') && FieldSet.get('issuetype')!=null && FieldSet.get('issuetype')!=''){
                        
                        Map<String, Object> Issuetype = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(FieldSet.get('issuetype')));
                        if(Schema.sObjectType.JiraIssue__c.fields.IssueType__c.isCreateable() && Issuetype.get('name')!=null && Issuetype.get('name')!=''){
                            jira.IssueType__c=String.valueof(Issuetype.get('name'));
                        }
                    }
                    
                    //jira.Jira_Link__c=JiraService.fetchDomain(String.valueOf(projectResponseMap.get('self')))+'/browse/'+jira.IssueKey__c;
                    if(Schema.sObjectType.JiraIssue__c.fields.Jira_Link__c.isCreateable()){
                        jira.Jira_Link__c = EndPoint != '' ? EndPoint+ '/browse/' + jira.issueKey__c : '';
                    }
                    
                    if(FieldSet.containskey('priority') && FieldSet.get('priority')!=null && FieldSet.get('priority')!=''){
                        Map<String, Object> PriorityMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(FieldSet.get('priority')));
                        if(Schema.sObjectType.JiraIssue__c.fields.Priority__c.isCreateable() && PriorityMap.get('name')!=null && PriorityMap.get('name')!=''){
                            jira.Priority__c=String.valueOf(PriorityMap.get('name'));
                        }
                    }
                    
                    if(FieldSet.containskey('project')){
                        Map<String, Object> ProjectMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(FieldSet.get('project')));
                        if(Schema.sObjectType.JiraIssue__c.fields.Project_Id__c.isCreateable() ){
                            jira.Project_Id__c=Decimal.valueOf(String.valueOf(ProjectMap.get('id')));
                        }
                        
                        if(Schema.sObjectType.JiraIssue__c.fields.Project__c.isCreateable()){
                            jira.Project__c=String.valueOf(ProjectMap.get('key'));
                        }
                    }
                    
                    if(FieldSet.containskey('reporter') && FieldSet.get('reporter')!=null && FieldSet.get('reporter')!=''){
                        Map<String, Object> ReporterMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(FieldSet.get('reporter')));
                        if(Schema.sObjectType.JiraIssue__c.fields.Reporter__c.isCreateable() && ReporterMap.get('displayName')!=null && ReporterMap.get('displayName')!=''){
                            jira.Reporter__c=String.valueOf(ReporterMap.get('displayName'));
                        }
                    }
                    
                    if(FieldSet.containskey('status') && FieldSet.get('status')!=null && FieldSet.get('status')!=''){
                        Map<String, Object> StatusMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(FieldSet.get('status')));
                        if(Schema.sObjectType.JiraIssue__c.fields.Status__c.isCreateable() && StatusMap.get('name')!=null && StatusMap.get('name')!=''){
                            jira.Status__c=String.valueOf(StatusMap.get('name'));
                        }
                    }
                    
                    if(Schema.sObjectType.JiraIssue__c.fields.Summary__c.isCreateable() && FieldSet.get('summary')!=null && FieldSet.get('summary')!=''){
                        String Subject=String.valueof(FieldSet.get('summary'));
                        jira.Summary__c=Subject.stripHtmlTags();
                    }
                    
                    string resolutionDate = FieldJsonHelper.getFieldData('resolutiondate',projectResponseMap)!='' ? 
                        EditAddJiraIssueController.ConvertDate(FieldJsonHelper.getFieldData('resolutiondate',projectResponseMap)) : '';
                    if(resolutionDate!='' && Schema.sObjectType.JiraIssue__c.fields.ResolutionDate__c.isCreateable()){
                        jira.ResolutionDate__c= DateTime.Parse(resolutionDate);
                    }
                    if(Schema.sObjectType.JiraIssue__c.fields.Resolution__c.isCreateable()){
                        jira.Resolution__c = FieldJsonHelper.getFieldDataForReporting('resolution',projectResponseMap);
                    }
                    if(Schema.sObjectType.JiraIssue__c.fields.Creator__c.isCreateable()){
                        jira.Creator__c = FieldJsonHelper.getFieldDataForReporting('creator',projectResponseMap);
                    }
                    
                    string created = FieldJsonHelper.getFieldData('created',projectResponseMap)!='' ? 
                        EditAddJiraIssueController.ConvertDate(FieldJsonHelper.getFieldData('created',projectResponseMap)) : '';
                    if(created!='' && Schema.sObjectType.JiraIssue__c.fields.Created__c.isCreateable()){
                        jira.Created__c = DateTime.Parse(created);
                    }
                    if(FieldSet.get('assignee')!=null){
                        Map<String, Object> assigneeMap =new   Map<String, Object>();
                        assigneeMap= (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(FieldSet.get('assignee')));
                        if(Schema.sObjectType.JiraIssue__c.fields.Assignee__c.isCreateable()){
                            jira.Assignee__c=assigneeMap.containsKey('displayName')?String.valueof(assigneeMap.get('displayName')):''; 
                        }
                    }
                   
                    Map<String,String> ReportingFieldsMap=new Map<String,String>();
                    if(ProjectkeyToObjectmap.containsKey(jira.Project__c)){
                        ReportingFieldsMap =   ReportingData.getReportingFieldsMap(
                            String.ValueOf(ProjectkeyToObjectmap.get(jira.Project__c).Id));
                    }
                    
                    if(ReportingFieldsMap!=NULL && !ReportingFieldsMap.isEmpty()){
                        Set<String> IssueFields = New Set<String>();
                        //NameSpace removed Grz_Sf__jiraIssue__c to jiraIssue__c
                        Map<String,Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('jiraIssue__c').getDescribe().fields.getMap();
                        
                        for(String sfield: fieldMap.Keyset()) {
                            if(NameSpace!=''){
                                sfield= sfield.toLowerCase().replace(NameSpace.toLowerCase()+'__','');
                            }else{
                                sfield=  sfield.toLowerCase().replace('Grz_Sf__',''); 
                            }
                            
                            String temp=sfield;
                            temp=temp.replaceAll('__c','');
                            temp=temp.replaceAll('__C','');
                            
                            if(temp.contains('__'))sfield=sfield.substring(sfield.indexof('__')+2,sfield.length() );
                            
                            IssueFields.add(sfield.toLowerCase());
                        }
                        
                        For(String fieldApi : ReportingFieldsMap.keySet()){
                            String val = fieldApi.toLowerCase() + '__c';
                            if(!IssueFields.isEmpty() && IssueFields.contains(val)){
                                
                                String field_val = FieldJsonHelper.getFieldDataForReporting(fieldApi , projectResponseMap);
                                if(field_val!= null && field_val!= ''){
                                    if(FieldNameByDataType.get(fieldApi).toLowerCase() == 'float'){
                                        jira.put(val , Decimal.ValueOf(field_val));
                                    }else if(FieldNameByDataType.get(fieldApi).toLowerCase() == 'datetime'){
                                        jira.put(val , DateTime.ValueOf(field_val.replace('T',' ')));
                                    }else if(FieldNameByDataType.get(fieldApi).toLowerCase() == 'date' ||
                                             FieldNameByDataType.get(fieldApi).toLowerCase() == 'datepicker'){
                                                 jira.put(val , Date.valueOf(field_val));
                                             }
                                    else{
                                        jira.put(val , field_val);
                                        
                                    }
                                }else{
                                     jira.put(val , null);
                                }
                            }
                        }
                    }
                    if(Schema.sObjectType.JiraIssue__c.fields.JsonData__c.isCreateable()){
                        jira.JsonData__c=jsonInput; 
                    }
                }else{
                    JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('ViewJiraSearchController',req.getEndPoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), null , null, null,'ViewJiraData', res.getBody()));
                    String Error=System.label.ViewJiraSearchController_Label6 +res.getStatusCode()+ System.label.ViewJiraSearchController_Label7 +res.getStatus()+ System.label.ViewJiraSearchController_Label8 +res.getBody();
                    ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR, Error);
                    ApexPages.addMessage(msg);
                    return; 
                }       
            }catch(Exception ex){
                String Errormsg=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('ViewJiraSearchController',null, null, null, null,null, null , null, null, 'ViewJiraData', Errormsg));
                ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR, Errormsg);
                ApexPages.addMessage(msg);
                return; 
            }
        }
        
        //check if the certain Project Exist as returned by jira Issue Record  
        if(JiraProjectKey.get(jira.Project__c)!=null && JiraProjectKey.get(jira.Project__c).IssueType__c!=null &&
           JiraProjectKey.get(jira.Project__c).IssueType__c!=''){
               
               
               
               Set<String> TempIssueSet= new Set<String>();
               List<String> TempIssueList= new List<String>();
               //Split all Issue Types that Project belongs to And add it to the Set
               TempIssueList= JiraProjectKey.get(jira.Project__c).IssueType__c.split(',');
               TempIssueSet.addAll(TempIssueList);
               
               
               if(JiraProjectKey.get(jira.Project__c).subtask__c!=NULL && JiraProjectKey.get(jira.Project__c).subtask__c!='')
                   TempIssueSet.addAll(JiraProjectKey.get(jira.Project__c).subtask__c.split(','));
               
               //Also Add the Default Issue type of the Project
               if(JiraProjectKey.get(jira.Project__c).DefaultIssueType__c!=null && JiraProjectKey.get(jira.Project__c).DefaultIssueType__c!='')
                   TempIssueSet.add(JiraProjectKey.get(jira.Project__c).DefaultIssueType__c);
               
               TempIssueSet.remove(null);
               TempIssueSet.remove('');
               
               //Prompt This Error if the Issue Type of JIra Issue Record is not present in jira Project then this error will be thrown 
               if(!TempIssueSet.contains(jira.IssueType__c)){
                   ErrorMessage=System.label.ViewJiraSearchController_Label1 +jira.IssueType__c+ System.label.ViewJiraSearchController_Label2;
                   return;  
               }
           }
        
        //Prompt This Error If the jira Issue Project is not synced with salesforce 
        if(!JiraProjectKey.containsKey(jira.Project__c)){
            String ProjectName = jirakey.Substring(0 , jirakey.IndexOf('-'));            
            ErrorMessage= System.label.ViewJiraSearchController_Label3 +ProjectName+ System.label.ViewJiraSearchController_Label4 + jirakey+ System.label.ViewJiraSearchController_Label5;
        }
        
        try{
            
            DynamicFieldWrapperList =new list<DynamicFieldWrapper>();
            
            Map<String,Jira_ProjectFieldsMapping__c> dynamicFieldsDataMap=new Map<String,Jira_ProjectFieldsMapping__c>();
            
            //create a set of Jira Project Field Mapping 
            for(Jira_ProjectFieldsMapping__c  field : dynamicFieldsData){
                
                if(!dynamicFieldsDataMap.KeySet().contains(field.JIRA_Field_Api_Name__c)){
                    dynamicFieldsDataMap.put(field.JIRA_Field_Api_Name__c,field);
                }
            }
            
            for(Jira_ProjectFieldsMapping__c field : dynamicFieldsData){
                if(JiraProjectKey.containsKey(jira.Project__c) && field.Jira_Project__c==JiraProjectkey.get(jira.Project__c).id ){
                    DynamicFieldWrapperList.add(new DynamicFieldWrapper(field,tasktype));
                }
            }
            
            if(jira!=Null && jira.JsonData__c!=Null){
                
                projectIsCreatable = creatableProjects.contains(jira.Project__c);
                Map<String, Object> JsonData = (Map<String, Object>) JSON.deserializeUntyped(jira.JsonData__c);
                
                for(DynamicFieldWrapper dynamic:DynamicFieldWrapperList){
                    String Jsonfield=dynamic.mappedField.JIRA_Field_Api_Name__c;
                    String Value= FieldJsonHelper.getFieldData(Jsonfield,JsonData);
                    
                    String issue_Key= FieldJsonHelper.getFieldData('key',JsonData);
                    if((Value!=Null && Value !='' && Value !='null' ) || Jsonfield=='issuelinks'){
                        //try{
                        String FieldType=dynamic.mappedField.DataType__c;
                        
                        if(dynamic.mappedField.IsArray__c || dynamic.mappedField.DataType__c=='version'){
                            if(FieldType.toLowerCase()=='cascadingselect' ){
                                dynamic.masterFieldValue=dynamic.clubMasterMapRev.get(value);
                                if(value.contains('_child_')){
                                    list<String> DepValue=value.split('_child_');
                                    dynamic.childFieldValue=DepValue[1];
                                    dynamic.masterFieldValue=DepValue[0];
                                }
                            }
                            else if(FieldType.toLowerCase()=='labels'||FieldType.toLowerCase()=='string' ||FieldType.toLowerCase()=='textarea' ||FieldType.toLowerCase()=='textfield'){
                                value=value.replace(',',' ');
                                dynamic.fieldValue=value;
                            }else if((FieldType.toLowerCase()=='version' && !dynamic.mappedField.IsArray__c)||FieldType.toLowerCase()=='select'||FieldType.toLowerCase()=='radiobuttons'){
                                value=value.removeEnd(',');
                                dynamic.fieldValue=value;
                            }else if( FieldType.toLowerCase()=='userpicker'||
                                     FieldType.toLowerCase()=='user'){
                                         map<String, Object> JsonToFieldMap=(map<String, Object>)JsonData.get('fields');
                                         
                                         if(JsonToFieldMap.get(dynamic.mappedField.jira_field_api_name__c)!=null){
                                             Map<String,Object> MapofUserdetail = (Map<String,Object>)JsonToFieldMap.get(dynamic.mappedField.jira_field_api_name__c);
                                             dynamic.username =(String)MapofUserdetail.get('displayName')+' - '+(String)MapofUserdetail.get('emailAddress')+' ('+(String)MapofUserdetail.get('key')+')';
                                             dynamic.usermapFinal.put(dynamic.username,String.valueof(MapofUserdetail.get('displayName')));
                                         }
                                         dynamic.fieldValue=value;
                                         if(dynamic.mappedField.jira_field_api_name__c=='assignee' && (value ==null ||value=='')){
                                             dynamic.fieldValue='Unassigned';
                                         }else{
                                             value=value.removeEnd(',');
                                             
                                             dynamic.fieldValue=value;
                                         }
                                     }else if(FieldType.toLowerCase()=='multiuserpicker'){
                                         
                                         map<String, Object> JsonToFieldMap=(map<String, Object>)JsonData.get('fields');
                                         dynamic.fieldValue='';
                                         if(JsonToFieldMap.get(dynamic.mappedField.jira_field_api_name__c)!=null){
                                             List<Object> ListOFuserObject=(List<Object>) JsonToFieldMap.get(dynamic.mappedField.jira_field_api_name__c);
                                             for(Object UserObj:ListOFuserObject){
                                                 Map<String,Object> MapofUserdetail  = (Map<String,Object>)UserObj;
                                                 String Mapkey=(String)MapofUserdetail.get('displayName')+' - '+(String)MapofUserdetail.get('emailAddress')+' ('+(String)MapofUserdetail.get('key')+')';
                                                 dynamic.usermapFinal.put(Mapkey,String.valueof(MapofUserdetail.get('displayName')));
                                                 
                                                 dynamic.fieldValue=dynamic.fieldValue==''?(String)MapofUserdetail.get('displayName'):(dynamic.fieldValue+', '+(String)MapofUserdetail.get('displayName'));
                                                     
                                                     }
                                         } 
                                     }else if(FieldType.toLowerCase()=='multiversion'||FieldType.toLowerCase()=='multiselect'||FieldType.toLowerCase()=='multicheckboxes'||FieldType.toLowerCase()=='version'||FieldType.toLowerCase()=='component'){
                                         
                                         list<String> ValueList= Value.split(',');
                                         
                                         Value='';
                                         for(String Temp: ValueList){
                                             for(String Selectvalue:dynamic.selectValueMap.keyset()){
                                                 if(Temp==(dynamic.selectValueMap.get(Selectvalue).toLowerCase())){
                                                     dynamic.multiselectvalues.add(Selectvalue);
                                                     if(jira.Project__c !=Null){
                                                         dynamic.mappedField.RelatedProjectIdSet__c =jiraProjectskeymap.get(jira.Project__c);
                                                     }
                                                 }
                                             }
                                         }
                                         value=value.removeEnd(';');
                                         dynamic.fieldValue=value;
                                     }
                            else if(FieldType.toLowerCase()=='issuelinks'){
                                IssuelinksMap = New Map<String,List<FieldJsonHelper.LinkedIssues>>();    
                                HttpRequest req = new HttpRequest(); 
                                Http http = new Http();
                                HTTPResponse res;
                                if(issueLinkField.JIRA_Field_Api_Name__c != null){
                                    req= CreateJIRAWrapper.CreateRequest('/rest/api/2/issue/'+issue_Key+'?fields='+issueLinkField.JIRA_Field_Api_Name__c, 'GET', 'application/json');
                                    res =http.send(req); 
                                    if(res.getStatusCode()==200){
                                        Map<String, Object> EpicJsonData = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                                        IssuelinksMap = FieldJsonHelper.getIssueLinkData(issueLinkField.JIRA_Field_Api_Name__c,EpicJsonData);
                                        dynamic.fieldValue= null;
                                        SizeOfMapLI = IssuelinksMap.size();
                                    }else{
                                        JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('ViewJiraSearchController',req.getEndPoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), null , null, null,'ViewJiraData', res.getBody()));
                                        
                                    }
                                }
                            }
                            
                        }else{
                            
                            if(FieldType.toLowerCase()=='gh-epic-label'||FieldType.toLowerCase()=='gh-epic-link'||FieldType.toLowerCase()=='float'||FieldType.toLowerCase()=='textfield'||FieldType.toLowerCase()=='string'||FieldType.toLowerCase()=='textarea'){
                                if(dynamic.mappedField.Jira_Field_api_Name__c.toLowerCase()=='resolutiondate'){
                                    dynamic.fieldValue=EditAddJiraIssueController.ConvertDate(value);
                                    
                                }else{
                                    dynamic.fieldValue=Value; 
                                }
                                
                                if(FieldType.toLowerCase() == 'gh-epic-link'){
                                    HttpRequest req = new HttpRequest(); 
                                    Http http = new Http();
                                    HTTPResponse res;
                                    
                                    if(jiraField.JIRA_Field_Api_Name__c != null){
                                        req= CreateJIRAWrapper.CreateRequest('/rest/api/2/issue/'+Value+'?fields='+jiraField.JIRA_Field_Api_Name__c, 'GET', 'application/json');
                                        res =http.send(req); 
                                        if(res.getStatusCode()==200){
                                            Map<String, Object> EpicJsonData = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                                            epicName = FieldJsonHelper.getFieldData(jiraField.JIRA_Field_Api_Name__c,EpicJsonData);
                                            dynamic.fieldValue= Value;
                                        }else{
                                            JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('ViewJiraSearchController',req.getEndPoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), null , null, null,'ViewJiraData', res.getBody()));
                                            
                                        }
                                    }
                                }
                            }else if(FieldType.toLowerCase()=='datepicker'){
                                if(FieldJsonHelper.getFieldData(Jsonfield,JsonData)!=null){
                                    dynamic.fieldValue=Value;
                                }
                            }else if(FieldType.toLowerCase()=='datetime'){
                                String dt='';
                                dt= Value;
                                dt=dt.replace('T',' ');
                                dynamic.fieldValue=String.valueof(DateTime.valueOf(dt));
                            }                                    
                        } 
                        
                        /* }catch(Exception ex){
String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR, Error);
ApexPages.addMessage(msg);
return;
}*/
                    }  
                }
            }
            
            for(DynamicFieldWrapper Dfield : DynamicFieldWrapperList){
                if(sectionToDynamicFieldWrapperListMap.containsKey(Dfield.mappedField.Section__r.Name)){
                    sectionToDynamicFieldWrapperListMap.get(Dfield.mappedField.Section__r.Name).add(Dfield);
                }else{
                    sectionToDynamicFieldWrapperListMap.put(Dfield.mappedField.Section__r.Name,new list<DynamicFieldWrapper>{Dfield});
                    SectionOrder.add(Dfield.mappedField.Section__r.Name);
                }
                if(Dfield.mappedField.name=='Issue Type' && Dfield.mappedField.Jira_Project__r.Projectkey__c==jira.Project__c ){
                    map<String,String> issuemap=Dfield.selectValueMap;
                    if(!issuemap.isEmpty() && jira !=null && jira.IssueType__c ==null){
                        for(String key: issuemap.keyset()){
                            
                            jira.IssueType__c=key;
                            break;
                        }
                    }
                }
                /*if(Dfield.mappedField.JIRA_Field_Api_Name__c==caseNumberApi && jiraIssue!=null){
Dfield.fieldValue= jira.CaseNos__c;
}*/
            }
            
        }catch(Exception ex){ 
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('ViewJiraSearchController',null, null, null,null,null, null , null, null, 'ViewJiraData', Error));
            ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR, Error);
            ApexPages.addMessage(msg);
            return;
        }     
    } 
    
    
    /**
*When a Jira ticked is searched and viewed then it can be cloned and if this Jira does not exist in salesforce already then it is inserted 
and the mode is set as 'Cloneout' else 'clonein'
*@Return NULL 
*Redirects to EditAddjiraissue page 
**/
    public PageReference save(){
        try {
            if(jira.id==null && schema.sObjectType.JiraIssue__c.isCreateable()){
                insert jira;
                mode='cloneout';
            }else{
                mode='clonein';
                
            }
        }
        catch(Exception ex){ 
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('ViewJiraSearchController',null, null, null,null,null, null , null, null, 'Save Jira', Error);
            ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR, Error);
            ApexPages.addMessage(msg);
            return null;
        }
        return null;
    }
    
    /**
*To link a jira ticket with a record after searching the jira ticket from search page and pressing the link option from viewSearchJira Page
*The Jira tiket is binded with the record and inseted in salesforce if it does not exist in salesforce already and the information is fetch from the Jira Instance
*@Return NULL 
*Redirects to object record detail page 
**/
    public PageReference link(){
        try {
            String returnData;
            if(jira.id==null && schema.sObjectType.JiraIssue__c.isCreateable()){
                insert jira;
            } 
            //call the class to link the Issue with the Object
            returnData=EditAddJiraIssueController.linkIssue(jira.IssueKey__c, genericObjectId,genericObjectName);
            if(returnData!=null && returnData!='' ){
                PageReference PgRef = new PageReference('/'+genericObjectID);
                //return PgRef;
                return null;
            }
        }catch(Exception ex){ 
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('ViewJiraSearchController',null, null, null,null,null, null , null, null, 'Link Jira', Error);
            ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR, Error);
            ApexPages.addMessage(msg);
            return null;
        }
        return null;
    }
    
    
    public PageReference RedirectToCaseRecord(){
       
        PageReference PgRef = new PageReference('/'+genericObjectID);
        return pgRef;
    }
    
    
    
    
    /**
*To delete a jira ticket on Jira instance.
*This method is not in use as of now
*@Returns Null
**/
    public void deleteLink(){
        String keytoDelete = ApexPages.currentPage().getParameters().get('key');
        String LinkType = ApexPages.currentPage().getParameters().get('linktype');
        HttpRequest req = new HttpRequest(); 
        req = CreateJIRAWrapper.CreateRequest('/rest/api/2/issueLink/'+ keytoDelete,'DELETE','application/json');   
        Http http = new Http();
        HTTPResponse res=new HTTPResponse();
        try {
            
            res = http.send(req);
            
            
            if(res.getStatusCode()== 204 && !IssuelinksMap.isEmpty() && 
               IssuelinksMap.ContainsKey(LinkType) && IssuelinksMap.get(LinkType)!= null){
                   list<FieldJsonHelper.LinkedIssues> ListoPut = New List<FieldJsonHelper.LinkedIssues>();
                   List<FieldJsonHelper.LinkedIssues> LiList = IssuelinksMap.get(LinkType);
                   if(!LiList.isEmpty()){
                       For(FieldJsonHelper.LinkedIssues LI : LiList){
                           If(LI!= null && LI.Id != keytoDelete){
                               ListoPut.add(LI);
                           }
                       }
                   }
                   if(!IssuelinksMap.get(LinkType).isEmpty() && LiList.size() == 1){
                       IssuelinksMap.remove(LinkType);
                   }
                   else{
                       IssuelinksMap.put(LinkType,ListoPut);
                   } 
               }
            if(!IssuelinksMap.isEmpty()){
                SizeOfMapLI = IssuelinksMap.size();
            }else{
                SizeOfMapLI = 0;
            }
            
        }catch(Exception ex){ 
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('ViewJiraSearchController',req.getEndpoint(), req.getMethod(),String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), null, res.getbody(), keytoDelete, 'Delete Link', Error);
            ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR, Error);
            ApexPages.addMessage(msg);
            return;
        }
        
    }
    
    public void InsertJiraLogs(){
        if(!JiraLogsToInsert.isEmpty()){
            Insert JiraLogsToInsert;
        }
    }
}