global with sharing class Jira_ProjectFieldMappingGateway implements Database.Batchable<sObject> ,Database.AllowsCallouts  {
    Map<String,set<String>> ProjecttoJiraApiNamesMap= new Map<String,set<String>>();
    public List<JiraErrorLogs__c> JiraLogsToInsert = new List<JiraErrorLogs__c>();
    String query='';
    String selectedObject='';
    List<String> ProjectIdList=new List<String>();
    
    public Jira_ProjectFieldMappingGateway(Map<String,set<String>> ProjecttoJiraApiNamesMap,String sfObject){
        this.ProjecttoJiraApiNamesMap=ProjecttoJiraApiNamesMap;
        this.selectedObject=sfObject;
        
        for(String key: ProjecttoJiraApiNamesMap.keyset()){
            ProjectIdList.add(key);
        }
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        query = 'select id , ProjectKey__c from Jira_Project__c  where id in :ProjectIdList';
        return Database.getQueryLocator(query);
    }
    
    //public static void updateJiraFieldData(String ProjectId, Set<String> FieldApiNames,String selectedObject){
    global void execute(Database.BatchableContext BC, List<Jira_Project__c> ProjectIdList){
        
        Set<String> FieldApiNames=new Set<String>();
        Set<String> ContentDocId= new Set<String>();
        ProjectsJson Finaljsondata;
        Boolean  CreateIssueLinkSection = false;
        //Jira_Project__c  Project =[Select id , ProjectKey__c from Jira_Project__c where id =:ProjectId];
        List<Jira_ProjectFieldsMapping__c> UserTypeFieldList = new  List<Jira_ProjectFieldsMapping__c>();
        List<Jira_ProjectFieldsMapping__c> LinkedIssuesFieldList = new  List<Jira_ProjectFieldsMapping__c>();
        List<Jira_ProjectFieldsMapping__c> FieldToUpdate = new  List<Jira_ProjectFieldsMapping__c>();
        List<Jira_ProjectFieldsMapping__c> FieldToInsert = new  List<Jira_ProjectFieldsMapping__c>();
        List<Jira_ProjectFieldsMapping__c> FieldTodelete = new  List<Jira_ProjectFieldsMapping__c>();
        List<Jira_ProjectFieldsMapping__c> defaultList = new List<Jira_ProjectFieldsMapping__c>();
        List<Jira_ProjectFieldsMapping__c> FdList = new List<Jira_ProjectFieldsMapping__c>();
        
        Id SectionId;
        if(!ContentVersion.sObjectType.getDescribe().isAccessible() || !Jira_FieldSection__c.sObjectType.getDescribe().isAccessible() || !Jira_ProjectFieldsMapping__c.sObjectType.getDescribe().isAccessible()){
            return;
        }
        For(Jira_FieldSection__c Section:[select id , name, column__c,order__c from Jira_FieldSection__c where name='Jira Fields' Limit 1]){
            SectionId=Section.id;
        }
        if(SectionId==null){
            jira_FieldSection__c section1 = new Jira_FieldSection__c(name='Jira Fields',column__c='2',order__c=1 );
            try{
                if(Schema.sObjectType.jira_FieldSection__c.isCreateable()){
                    insert section1;
                }
            }catch(Exception ex){
                String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                GenerateJiraLogs.CreateLogRealTime('Jira_ProjectFieldMappingGateway',null, null, null,null,null, null , null, null, 'Insert Section', Error);
                
                
            }
            SectionId=section1.id;
            
        }
        
        for(Jira_Project__c objProjectId : ProjectIdList){
            
            String ProjectId=objProjectId.id;
            
            if(ProjecttoJiraApiNamesMap.containsKey(ProjectId))
                FieldApiNames=ProjecttoJiraApiNamesMap.get(ProjectId);
            
            for(ContentDocumentLink ContentLink:[SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink where LinkedEntityId =: ProjectId]){
                ContentDocId.add(ContentLink.ContentDocumentId);
            }
            for(ContentVersion cv: [SELECT Id,Title, versiondata FROM Contentversion where ContentDocumentid in:ContentDocId and (not title like '%NotAllowedJson.txt')]){
                string jiraMetadataJson =  EncodingUtil.base64Decode(EncodingUtil.base64Encode(cv.VersionData)).toString();
                if (jiraMetadataJson != null) {
                    Map<String, Object> Main = (Map<String, Object>) JSON.deserializeUntyped(jiraMetadataJson);
                    Object JsonObj=Main.get('projects');
                    String JsonString = JSON.serialize(JsonObj);
                    JSONParser parser = JSON.createParser(JsonString);
                    while (parser.nextToken() != null) {
                        if(parser.getCurrentToken()==JSONToken.START_OBJECT ){ 
                            Finaljsondata=(ProjectsJson)parser.readValueAs(ProjectsJson.class);
                        }    
                    }
                }
            }
            Set<String> AllJiraFieldApi =new set<String>();
            
            set<String> staticfield= new Set<String>();
            
            staticfield.add('link');
            staticfield.add('key');
            staticfield.add('status');
            staticfield.add('resolution');
            staticfield.add('resolutiondate');
            staticfield.add('issuetype');
            
            
            
            
            
            defaultList=  [SELECT Id, Name, DataType__c, Jira_Project__c, JIRA_Field_Api_Name__c, ProjectIdSet__c, Section__c, IssueTypedata__c, ReqInIssueTypeData__c,RelatedProjectIdSet__c, IsReportingEnabled__c, IsRequired__c, Order__c, RequiredInSF__c,Salesforce_Object__c FROM Jira_ProjectFieldsMapping__c where Jira_Project__c =:ProjectId and Jira_Field_Api_Name__c in:staticfield and Salesforce_Object__c =: selectedObject];
            
            if(defaultList.isEmpty()){
                for(String inkey:staticfield){
                    Jira_ProjectFieldsMapping__c SfField = new Jira_ProjectFieldsMapping__c();
                    String Issuejsondata;
                    for( ProjectsJson.IssueType Issues:Finaljsondata.issuetypes){
                        map<String,ProjectsJson.FieldJson>  fields=Issues.fields;
                        if(fields.get(inkey)!=null){
                            ProjectsJson.FieldJson FieldJson=fields.get(inkey);
                            if(Issuejsondata==null){
                                Issuejsondata='{"'+Issues.id +'":"'+Issues.name.escapejava() +'"}';
                            }else{
                                Issuejsondata+=',{"'+Issues.id +'":"'+Issues.name.escapejava() +'"}';
                            }
                            
                            if( SfField.IssueTypeData__c==null && schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.IssueTypeData__c.isCreateable()){
                                
                                SfField.IssueTypeData__c=Issues.name;  
                            }else{
                                if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.IssueTypeData__c.isCreateable()){
                                    SfField.IssueTypeData__c+=','+Issues.name;
                                }
                            }
                            if(FieldJson.required){
                                if(SfField.ReqInIssueTypeData__c==null && schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.ReqInIssueTypeData__c.isCreateable()){
                                    SfField.ReqInIssueTypeData__c=Issues.name;
                                }else{
                                    if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.ReqInIssueTypeData__c.isCreateable()){
                                        SfField.ReqInIssueTypeData__c+=','+Issues.name;
                                    }
                                }
                            }
                            if(FieldJson.schema.custom!=Null){
                                SfField.DataType__c =FieldJson.schema.custom.substring(FieldJson.schema.custom.lastIndexOf(':')+1,FieldJson.schema.custom.length()) ;
                            }else if(FieldJson.schema.items!=Null && schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.DataType__c.isCreateable()){
                                SfField.DataType__c =FieldJson.schema.items;
                            } else{
                                if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.DataType__c.isCreateable()){
                                    SfField.DataType__c =FieldJson.schema.type; 
                                }
                            }
                            if(SfField.DataType__c =='date' && schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.DataType__c.isCreateable()){
                                SfField.DataType__c ='datepicker';
                            }
                            
                            if(FieldJson.schema.type=='array' && schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.IsArray__c.isCreateable()){
                                SfField.IsArray__c=true;
                            }
                            if(FieldJson.allowedValues!=null && FieldJson.allowedValues.size()>0){
                                SfField.IsArray__c=true;
                                String jsonformulti='';
                                String childjson='';
                                for(ProjectsJson.allowedValuesobj  all:FieldJson.allowedValues){
                                    if(all.value!=Null){
                                        jsonformulti= jsonformulti+'{"'+ all.id + '":"'+(all.value).escapeJava()+'"},';
                                    }else if(all.name!=null){
                                        jsonformulti= jsonformulti+'{"'+ all.id + '":"'+(all.name).escapeJava()+'"},';
                                    }
                                    
                                    if(all.children!=null && !all.children.isEmpty()){
                                        childjson='';
                                        for(ProjectsJson.Children  ch:all.children){
                                            childjson+='{"'+ch.id +'":"' + (ch.value).escapejava()+'"},';
                                        }
                                        jsonformulti=jsonformulti.removeEnd('},');
                                        childjson=childjson.removeEnd(',');
                                        childjson=',"Children":['+childjson +']},';
                                        jsonformulti +=childjson;
                                    }
                                }
                                jsonformulti=jsonformulti.removeEnd(',');
                                jsonformulti='{"allowedValues":['+jsonformulti+']}';
                                if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.ProjectissueTypeData__c.isCreateable()){
                                    SfField.ProjectissueTypeData__c=jsonformulti;   
                                }
                            }
                            
                            
                            if(FieldJson.name!=null && schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.Jira_Field_Name__c.isCreateable() ){
                                SfField.Jira_Field_Name__c=FieldJson.name;
                            }else if(FieldJson.key!=null && schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.Jira_Field_Name__c.isCreateable()){
                                SfField.Jira_Field_Name__c=FieldJson.key;
                            }
                        }
                    }
                    if( SfField.Jira_Field_Name__c==null && schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.Jira_Field_Name__c.isCreateable()){
                        SfField.Jira_Field_Name__c=inkey;
                    }
                    if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.JIRA_Field_Api_Name__c.isCreateable()){
                        SfField.JIRA_Field_Api_Name__c=inkey;  
                    }
                    if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.Jira_Project__c.isCreateable()){
                        SfField.Jira_Project__c=ProjectId;
                    }
                    if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.RelatedProjectIdSet__c.isCreateable()){
                        SfField.RelatedProjectIdSet__c=ProjectId;
                    }
                    if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.Order__c.isCreateable()){
                        SfField.Order__c=1;
                    }
                    if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.IsStatic__c.isCreateable()){
                        SfField.IsStatic__c=true;
                    }
                    if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.Section__c.isCreateable()){
                        SfField.Section__c=SectionId;
                    }
                    
                    if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.Salesforce_Object__c.isCreateable()){
                        SfField.Salesforce_Object__c = selectedObject;
                    }
                    if(inkey=='resolutiondate'){
                        if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.IssueTypeData__c.isCreateable()){
                            SFField.IssueTypeData__c='All';
                        }
                        if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.Name.isCreateable()){
                            SFField.Name='Resolutiondate';
                        }
                        if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.DataType__c.isCreateable()){
                            SFField.DataType__c='string';
                        }
                        if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.ViewMode__c.isCreateable()){
                            SfField.ViewMode__c=true;
                        }
                    }else if(inkey=='issuetype'){
                        if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.Name.isCreateable()){
                            SFField.Name='Issue Type';
                        }
                        if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.ProjectissueTypeData__c.isCreateable()){
                            SFField.ProjectissueTypeData__c ='{"allowedValues":['+Issuejsondata+']}';
                        }
                        if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.DataType__c.isCreateable()){
                            SFField.DataType__c='select';
                        }
                        if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.IsArray__c.isCreateable()){
                            SFField.IsArray__c=true;
                        }
                    }else if(inkey=='resolution'){
                        if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.Name.isCreateable()){
                            SFField.Name='Resolution';
                        }
                        if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.IssueTypeData__c.isCreateable()){
                            SFField.IssueTypeData__c='All';
                        }
                        if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.DataType__c.isCreateable()){
                            SFField.DataType__c='select';
                        }
                        if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.IsArray__c.isCreateable()){
                            SFField.IsArray__c=true;
                        }
                        if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.ViewMode__c.isCreateable()){
                            SfField.ViewMode__c=true;
                        }
                    }else if(inkey=='status'){
                        if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.IssueTypeData__c.isCreateable()){
                            SFField.IssueTypeData__c='All';
                        }
                        if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.Name.isCreateable()){
                            SFField.Name='Status';
                        }
                        if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.DataType__c.isCreateable()){
                            SFField.DataType__c='select';
                        }
                        if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.IsArray__c.isCreateable()){
                            SFField.IsArray__c=true;
                        }
                        if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.ViewMode__c.isCreateable()){
                            SfField.ViewMode__c=true;
                        }
                    }else if(inkey=='key'){
                        if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.Name.isCreateable()){
                            SFField.Name='Jira Issue Number';
                        }
                        if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.ViewMode__c.isCreateable()){
                            SfField.ViewMode__c=true;
                        }
                        if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.IssueTypeData__c.isCreateable()){
                            SFField.IssueTypeData__c='All';
                        }
                        if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.DataType__c.isCreateable()){
                            SFField.DataType__c='string';
                        }
                    }else if(inkey=='link'){
                        if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.Name.isCreateable()){
                            SFField.Name='Jira Issue Link';
                        }
                        if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.ViewMode__c.isCreateable()){
                            SfField.ViewMode__c=true;
                        }
                        if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.DataType__c.isCreateable()){
                            SFField.DataType__c='string';
                        }
                        if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.IssueTypeData__c.isCreateable()){
                            SFField.IssueTypeData__c='All';
                        }
                    }
                    if(schema.sObjectType.Jira_ProjectFieldsMapping__c.isCreateable())
                        FdList.add(SFField);
                    
                }
            }
            
            
            /* *********************** */     
            List<Jira_ProjectFieldsMapping__c> jpmList = [SELECT Id, Name, DataType__c, Jira_Project__c, JIRA_Field_Api_Name__c, ProjectIdSet__c, Section__c, IssueTypedata__c, ReqInIssueTypeData__c,RelatedProjectIdSet__c,Salesforce_Object__c, IsReportingEnabled__c, IsRequired__c, Order__c, RequiredInSF__c FROM Jira_ProjectFieldsMapping__c where Jira_Project__c =:ProjectId and Jira_Field_Api_Name__c in:FieldApiNames and Salesforce_Object__c =: selectedObject];
            
            for(Jira_ProjectFieldsMapping__c SfField: jpmList){
                
                if(Schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.IssueTypeData__c.isUpdateable()){
                    SfField.IssueTypeData__c = null;
                }
                if(Schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.ReqInIssueTypeData__c.isUpdateable()) {
                    SfField.ReqInIssueTypeData__c = null;
                }
                String inkey=SfField.Jira_Field_Api_Name__c;
                
                for( ProjectsJson.IssueType Issues:Finaljsondata.issuetypes){
                    
                    map<String,ProjectsJson.FieldJson>  fields=Issues.fields;
                    if(fields.get(inkey)!=null){
                        AllJiraFieldApi.add(inkey);
                        
                        ProjectsJson.FieldJson FieldJson=fields.get(inkey);
                        if( SfField.IssueTypeData__c==null){
                            if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.IssueTypeData__c.isCreateable()){
                                SfField.IssueTypeData__c=Issues.name;  
                            }
                        }else{
                            if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.IssueTypeData__c.isCreateable()){
                                SfField.IssueTypeData__c+=','+Issues.name; 
                            }
                        }
                        if(FieldJson.required){
                            if(SfField.ReqInIssueTypeData__c==null ){
                                if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.ReqInIssueTypeData__c.isCreateable()){
                                    SfField.ReqInIssueTypeData__c=Issues.name;
                                }
                            }else{
                                if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.ReqInIssueTypeData__c.isCreateable()){
                                    SfField.ReqInIssueTypeData__c+=','+Issues.name;
                                }
                            }
                        }
                        if(FieldJson.schema.custom!=Null){
                            SfField.DataType__c =FieldJson.schema.custom.substring(FieldJson.schema.custom.lastIndexOf(':')+1,FieldJson.schema.custom.length()) ;
                        }else if(FieldJson.schema.items!=Null && Schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.DataType__c.isUpdateable()){
                            SfField.DataType__c =FieldJson.schema.items;
                        } else{
                            if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.DataType__c.isUpdateable()){
                                SfField.DataType__c =FieldJson.schema.type; 
                            }
                        }
                        if(SfField.DataType__c =='date' && schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.DataType__c.isUpdateable()){
                            SfField.DataType__c ='datepicker';
                        }
                        if(SfField.DataType__c.toLowerCase() =='userpicker'||SfField.DataType__c.toLowerCase() =='multiuserpicker'||SfField.DataType__c.toLowerCase() =='user' ){
                            //UserTypeFieldList.add(SfField);
                            if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.IsArray__c.isUpdateable()){
                                SFField.IsArray__c=true;
                            }
                        }
                        if(SfField.DataType__c.toLowerCase() =='issuelinks'){
                            LinkedIssuesFieldList.add(SfField);
                        }
                        if(FieldJson.schema.type=='array' && Schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.IsArray__c.iscreateable() && Schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.IsArray__c.isUpdateable()){
                            SfField.IsArray__c=true;
                        }
                        
                        if(FieldJson.allowedValues!=null && FieldJson.allowedValues.size()>0){
                            if(FieldJson.schema.items!='version'){
                                if(Schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.IsArray__c.iscreateable()){
                                    SfField.IsArray__c=true;
                                }
                            }
                            String jsonformulti='';
                            String childjson='';    
                            
                            for(ProjectsJson.allowedValuesobj  all:FieldJson.allowedValues){
                                if(all.value!=Null){
                                    jsonformulti= jsonformulti+'{"'+ all.id + '":"'+(all.value).escapejava()+'"},';
                                }else if(all.name!=null){
                                    jsonformulti= jsonformulti+'{"'+ all.id + '":"'+(all.name).escapejava()+'"},';
                                }
                                
                                if(all.children!=null && !all.children.isEmpty()){
                                    childjson='';
                                    for(ProjectsJson.Children  ch:all.children){
                                        childjson+='{"'+ch.id +'":"' + (ch.value).escapejava()+'"},';
                                    }
                                    jsonformulti=jsonformulti.removeEnd('},');
                                    childjson=childjson.removeEnd(',');
                                    childjson=',"Children":['+childjson +']},';
                                    jsonformulti +=childjson;
                                }
                            }
                            jsonformulti=jsonformulti.removeEnd(',');
                            jsonformulti='{"allowedValues":['+jsonformulti+']}';
                            if(jsonformulti!=NULL && Schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.ProjectissueTypeData__c.isUpdateable()){
                                SfField.ProjectissueTypeData__c=jsonformulti.replace('\t','');  
                            }   
                        }
                        if(SfField.Jira_Field_API_Name__c =='issuetype'){
                            if(Schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.datatype__c.iscreateable()){
                                SfField.datatype__c='select';
                            }
                        }
                        if(SfField.Jira_Field_API_Name__c =='priority' || SfField.datatype__c=='securitylevel'){
                            if(Schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.datatype__c.iscreateable()){
                                SfField.datatype__c='select';
                            }
                        }
                        if(FieldJson.name!=null && Schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.Jira_Field_Name__c.iscreateable() && Schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.Jira_Field_Name__c.isUpdateable()){
                            SfField.Jira_Field_Name__c=FieldJson.name;
                        }else if(FieldJson.key!=null && Schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.Jira_Field_Name__c.iscreateable() && Schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.Jira_Field_Name__c.isUpdateable()){
                            SfField.Jira_Field_Name__c=FieldJson.key;
                        }
                    }
                    
                }
                if(SfField.DataType__c.toLowerCase() == 'gh-epic-link'){
                    if(SfField.IssueTypeData__c!= null && SfField.IssueTypeData__c.contains('Epic')){
                        if(Schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.IssueTypeData__c.iscreateable()){
                            SfField.IssueTypeData__c= SfField.IssueTypeData__c.remove('Epic'); 
                            SfField.IssueTypeData__c= SfField.IssueTypeData__c.removeEnd(','); 
                        }
                    }
                    if(SfField.ReqInIssueTypeData__c!= null && SfField.ReqInIssueTypeData__c.contains('Epic')){
                        if(Schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.ReqInIssueTypeData__c.iscreateable()){
                            SfField.ReqInIssueTypeData__c=SfField.ReqInIssueTypeData__c.remove('Epic'); 
                            
                            SfField.ReqInIssueTypeData__c=SfField.ReqInIssueTypeData__c.removeEnd(',');
                        }						
                    }
                    
                }
                if(AllJiraFieldApi.contains(inkey) || SfField.DataType__c.toLowerCase() =='issuelinks'){
                    FieldToUpdate.add(SfField); 
                    
                    if(SfField.DataType__c.toLowerCase() =='issuelinks'){
                        CreateIssueLinkSection= true;
                    }
                }else{
                    
                    FieldTodelete.add(SfField);
                    
                }
                
            }
            
            
            //String AssigneeData='';
            String LinkedIssuesData='';
            if(!LinkedIssuesFieldList.isEmpty()){
                HttpRequest req = new HttpRequest();
                if(!LinkedIssuesFieldList.isEmpty()){
                    req = CreateJIRAWrapper.CreateRequest('/rest/api/2/issueLinkType', 'GET', 'application/json');
                }
                HttpResponse res = new HttpResponse();
                Http http = new Http();
                try {
                    String jsonInput;
                    res = http.send(req);
                    jsonInput = res.getBody();
                    if(res.getStatusCode()==200){
                        
                        Map<String,Object> MainLinkedIssues = (Map<String, Object>) JSON.deserializeUntyped(jsonInput);
                        For(String IssueLinkTypes : MainLinkedIssues.Keyset()){
                            List<Object> Final_list = (List<Object>)MainLinkedIssues.get(IssueLinkTypes);
                            For(Object finalobj : Final_list){
                                Map<String,object> AllowedvaluesMap = (Map<String,object>) finalobj;
                                String Allowedvalues=String.valueof(AllowedvaluesMap.get('name'));
                                LinkedIssuesData +='{"'+AllowedvaluesMap.get('id')+'":"'+Allowedvalues.escapeJava()+'"},'; 
                            }
                            LinkedIssuesData = LinkedIssuesData.removeEnd(',');
                        }
                        //} 
                    }else{
                        JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('Jira_ProjectFieldMappingGateway',req.getEndpoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), req.getbody() , objProjectId.ProjectKey__c!= null ? objProjectId.ProjectKey__c : objProjectId.Id, null, 'update Jira Field Data', res.getBody()));
                        
                    }
                }catch(Exception ex){
                    String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                    JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('Jira_ProjectFieldMappingGateway',req.getEndpoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(), req.getbody() , objProjectId.ProjectKey__c!= null ? objProjectId.ProjectKey__c : objProjectId.Id, null, 'update Jira Field Data', Error));
                    
                }
            }
            list<Jira_FieldSection__c> FieldSections = new List<Jira_FieldSection__c>();
            try{
                if(CreateIssueLinkSection){
                    FieldSections= [select id ,name from Jira_FieldSection__c where name='Issue Links' limit 1];
                    if(FieldSections.isEmpty()){
                        Jira_FieldSection__c LinkSection = new Jira_FieldSection__c();
                        if(schema.sObjectType.Jira_FieldSection__c.fields.Name.isCreateable()){
                            LinkSection.Name='Issue Links';
                        }
                        if(schema.sObjectType.Jira_FieldSection__c.fields.Column__c.isCreateable()){
                            LinkSection.Column__c='1';
                        }
                        if(schema.sObjectType.Jira_FieldSection__c.fields.Order__c.isCreateable()){
                            LinkSection.Order__c=3;
                        }
                        FieldSections.add(LinkSection);
                        if(schema.sObjectType.Jira_FieldSection__c.isCreateable()){
                            insert FieldSections;
                        }
                    }
                }
                if(!FieldToUpdate.isEmpty()){
                    for(Jira_ProjectFieldsMapping__c Field: FieldToUpdate){
                        if(LinkedIssuesData!='' && Field.DataType__c.toLowerCase() =='issuelinks'){
                            Field.isArray__c=true;
                            Field.ProjectissueTypeData__c='{"allowedValues":['+LinkedIssuesData.replace('\t','')+']}';
                            Field.Section__c=FieldSections[0].id;
                        }
                    }
                    if(schema.sObjectType.Jira_ProjectFieldsMapping__c.isUpdateable()){
                        update FieldToUpdate;  
                    }
                }        
                if(!FieldTodelete.isEmpty()){
                    if(schema.sObjectType.Jira_ProjectFieldsMapping__c.isDeletable()){
                        delete FieldTodelete; 
                    }
                }
                if(!FdList.isEmpty() && schema.sObjectType.Jira_ProjectFieldsMapping__c.isCreateable() ){
                    
                    insert FdList;
                }  
            }catch(Exception ex){
                String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('Jira_ProjectFieldMappingGateway',null, null, null,null,null, null , null, null, 'DML inside execute', Error));
                
                
            }
        }
        
    }
    
    global void finish(Database.BatchableContext BC){
        if(!JiraLogsToInsert.isEmpty()){
            Insert JiraLogsToInsert;
        }
    }
}