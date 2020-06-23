public with sharing class FieldsSettingController {
    public String usersearchtext{get;set;}
    public List<SelectOption>userlistbyname{get;set;} 
    Map<String,String> UserMapDetails;
    
    public String username{get;set;}   
    public String ProjectIdkey{get;set;}
    public Map < String, Jira_Project__c > ProjectIdMap;
    public Boolean showAlert{get;set;}
    public Boolean AllJobCompleted{get;set;}
    public String displayError{get;set;}
    public String selectpro{get;set;}
    public String selectproject{get;set;}
    public String SectionId{get;set;}
    public map<String,ProjectAndFieldWrapper> ProjectFieldmaps{get;set;}
    public map<String,set<string>> dataTypeMap{get;set;}
    public Map < String,Projects.Fieldmeta > jiraFieldsMapReq;
    public Map < String,Projects.Fieldmeta > jiraFieldsMapOp;
    public map<String,Jira_FieldSection__c> sectionMap;
    //public  CaseNumberField__c caseNumberSetting{get;set;}
    public Map < String, Jira_Project__c > jiraProjectMap{get;set;}
    public map<String,Jira_Project__c> projectIdKeyMap;
    public string caseNumberSettingValue;
    public List < SelectOption > caseFields {get;set;}
    private static Map < String, Schema.SObjectField > fieldMap;
    public Map<string,string> sfDataTypeMap{get;set;}
    public Set < String > DEFAULT_MAPPED_JIRA_FEILDS = new Set < String > {'project','IssueType'};
        public List<SelectOption> fieldsToMap {get;set;}
    public  Map<id,Jira_ProjectFieldsMapping__c> jiraFieldsFromSf;
    Map<String,String> ExistingaMap;
    Map<String,String> ExistingcaseFields;
    
    public Map<String,String> caseFieldValueToLabel = new Map<String,String>();
    public map<string,string> jiraDataTypeMap{get;set;}
    public map<string ,list<SelectOption>> reqSFJiraDataType{get;set;}
    public map<string ,list<SelectOption>> opSFJiraDataType{get;set;}
    public  List<SelectOption> jiraprojectlist{get;set;}
    
    //checked and addedd per need
    public List<SelectOption> SObjectList{get;set;}
    public Boolean deleteoperation{get;set;}
    public String selectedObjectName{get;set;}
    public String selectedObject{get;set;}
    public string jirafieldsToMapVal{get; set;}
    public List < SelectOption > salesForceFields {get;set;}
    public map<string,string> mappedSalesforceObjects{get;set;}
    public Boolean ObjectLimitExceed{get;set;}
    public Boolean ObjectLimit;
    public Integer delObjCount{get;set;}
    
    public List<SelectOption> jirafieldsToMap {get;set;}
    public DefaultValueWrapper DefaultWrapper{get;set;}
    public String jiraFieldApiForDefault{get;set;}
    public string objectToBeDeleted{get;set;}
    public String jobname{get;set;}
    public Boolean projectSuccess{get;set;}
    public Boolean Fieldsuccess{get;set;}
    public Boolean loginSuccess{get;set;}
    public Integer SizeOfList { get { return mappedSalesforceObjects.size(); } }
    public string deletevar{get;set;}
    public Set<String> JiraIssueFields{get;set;}
    
    public FieldsSettingController(){
        init();
    }
    
    /*
* initialize all the variables
*/
    public void init(){
        
        JiraIssueFields = new Set<String>();
        JiraIssueFields.add('status');
        JiraIssueFields.add('reporter');
        JiraIssueFields.add('summary');
        JiraIssueFields.add('description');
        JiraIssueFields.add('priority');
        JiraIssueFields.add('labels');
        JiraIssueFields.add('assignee');
        
        SectionId='';
        showAlert = false;
        AllJobCompleted =false;
        UserMapDetails = new Map<String,String>();
        
        dataTypeMap = new map<String,set<string>>();
        jiraFieldsMapReq=new Map < String, Projects.Fieldmeta >();
        jiraFieldsMapOp=new Map < String, Projects.Fieldmeta >();
        SObjectList=new List<SelectOption> ();
        caseFields = new List < SelectOption > ();
        fieldstomap =new List<SelectOption>();
        jiraFieldsFromSf = new Map<id,Jira_ProjectFieldsMapping__c>();
        ExistingaMap= new Map<String,String>();
        ExistingcaseFields= new Map<String,String>();
        jiraDataTypeMap = new map<string,string>();
        jiraDataTypeMap.put(null,''); 
        reqSFJiraDataType = new map<string,list<selectoption>>();
        reqSFJiraDataType.put('',new list<selectoption>{new SelectOption('','')});
        opSFJiraDataType = new map<string, list<selectoption>>();
        opSFJiraDataType.put('',new list<selectoption>());
        salesForceFields=new List < SelectOption > ();
        mappedSalesforceObjects=new map<string,string> ();
        jirafieldsToMap=new List<SelectOption> ();
        DefaultWrapper = new DefaultValueWrapper();
        jiraFieldApiForDefault='';
        objectToBeDeleted='';
        deletevar = '';
        deleteoperation=false;
        projectSuccess=true;
        userlistbyname = new List<SelectOption>();
        
    }
    
    public PageReference fetchfieldsInitial(){
        init();
        fieldsData();
        fetchfields();
        return null;
    } 
    /*
* Fills the Project maps using Jira Projects.
* Fetch the project of last updated Field Mapping.
* Fetch available Jira sections 
*/
    public void fieldsData(){
        ProjectFieldmaps=new map<string,ProjectAndFieldWrapper>();
        sectionMap=  new map<String,Jira_FieldSection__c>();
        jiraProjectMap = new Map < String, Jira_Project__c >();
        ProjectIdMap = new Map < String, Jira_Project__c >();
        projectIdKeyMap = new map<String,Jira_Project__c>(); 
        jiraprojectlist = new List<SelectOption>();
        
        List<Jira_ProjectFieldsMapping__c> jpmList = new List<Jira_ProjectFieldsMapping__c>();
        
        for (Jira_Project__c projectInstance:[SELECT id,Name,ProjectKey__c,Subtask__c ,ProjectId__c,Write__c,IssueType__c,DefaultIssueType__c ,Read__c 
                                              FROM Jira_Project__c Limit 1000]) {
                                                  projectSuccess=true;
                                                  ProjectIdMap.put(projectInstance.id,projectInstance);
                                                  jiraProjectMap.put(projectInstance.ProjectKey__c, projectInstance);
                                                  projectIdKeyMap.put(projectInstance.ProjectId__c, projectInstance);
                                                  jiraprojectlist.add(new SelectOption(projectInstance.ProjectKey__c,projectInstance.Name));    
                                                  
                                              }  
        
        jiraprojectlist.sort();
        
        for(Jira_ProjectFieldsMapping__c JW:[SELECT Name, Id, Jira_Project__r.name,Jira_Project__r.ProjectKey__c, LastModifiedDate FROM Jira_ProjectFieldsMapping__c order by LastModifiedDate DESC LIMIT 1]){
            selectproject=JW.Jira_Project__r.ProjectKey__c;
            selectpro=selectproject;
            ProjectFieldmaps.put(selectpro,new ProjectAndFieldWrapper());
        }
        if(selectpro==null || selectpro=='')
            return ;
        
        ProjectIdkey=JSON.serialize(ProjectIdMap);
        /*For(Jira_FieldSection__c Section:[select id , name, column__c,order__c from Jira_FieldSection__c]){
sectionMap.put(Section.name,Section);
}*/
        
    }
    
    /*
* Fetches all the Objects in System excluding the sinergify objects
*/ 
    public PageReference fetchfields(){ 
        
        SObjectList=FetchSalesforceObject();
        selectpro= selectproject;
        if(selectpro==null || selectpro==''){
            return null;
        }
        showAlert = false;
        dataTypeMap = new map<String,set<string>>();
        jiraFieldsMapReq=new Map < String, Projects.Fieldmeta >();
        jiraFieldsMapOp=new Map < String, Projects.Fieldmeta >();
        ProjectFieldmaps=new map<string,ProjectAndFieldWrapper>();
        //ProjectFieldmaps.put('All',new ProjectAndFieldWrapper());
        sectionMap=  new map<String,Jira_FieldSection__c>();
        
        dataTypeMap = fetchDataTypeMap(); //map of SF Datatype to Jira Fields Datatype
        if(Jira_FieldSection__c.sObjectType.getDescribe().isAccessible()){
            For(Jira_FieldSection__c Section:[select id , name, column__c,order__c from Jira_FieldSection__c LIMIT 1000]){
                sectionMap.put(Section.name,Section);
                SectionId= Section.id;
                SectionId=SectionId.substring(0, 3);
            }
        }
        
        
        Set<Id> ContentDocId =new Set<Id>();
        Set<Id> ContentLinkId =new Set<Id>();
        
        ContentLinkId.add(jiraProjectMap.get(selectpro).id);
        if(!ContentLinkId.isEmpty() && ContentDocumentLink.sObjectType.getDescribe().isAccessible()){
            
            for(ContentDocumentLink ContentLink:[SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink where LinkedEntityId in:ContentLinkId]){
                ContentDocId.add(ContentLink.ContentDocumentId);
            }
        }         
        salesForceFields=fetchSalesForceFields(selectedObject);
        
        if(fieldMap!= null){
            // map of Saleforce object field name and its datatype 
            sfDataTypeMap = new map<string,string>();
            for (String fieldName: fieldMap.keySet()) {
                
                sfDataTypeMap.put(fieldMap.get(fieldName).getDescribe().getName(),String.ValueOf(fieldMap.get(fieldName).getDescribe().getType()).tolowerCase());
            }
            sfDataTypeMap.put('','');
            sfDataTypeMap.put('none','none');
        }
        
        if(!ContentDocId.IsEmpty() && ContentVersion.sObjectType.getDescribe().isAccessible()){
            for(ContentVersion cv: [SELECT Id,Title, versiondata FROM Contentversion where ContentDocumentid in:ContentDocId and title like '%NotAllowedJson%']){
                string jiraMetadataJson =  EncodingUtil.base64Decode(EncodingUtil.base64Encode(cv.VersionData)).toString();
                if (jiraMetadataJson != null) {
                    fetchJiraFields(jiraMetadataJson,DEFAULT_MAPPED_JIRA_FEILDS); 
                } 
            }
        }
        
        mappedSalesforceObjects = FetchMapedSfObject();
        
        if(ObjectLimit == true){
            SObjectList = new List<SelectOption>();
            for(String obj : mappedSalesforceObjects.keyset()){
                SObjectList.add(new SelectOption(obj,mappedSalesforceObjects.get(obj)));
            }
        }
        fillsfJiraFieldsWrapper();
        setJiraField();
        return null; 
    }
    
    public void setJiraField(){
        jirafieldsToMap = new List<selectOption>();
        set<string> jirafields = new set<string>();
        
        set<String> staticfield= new Set<String>();
        staticfield.add('link');
        staticfield.add('key');
        staticfield.add('status');
        staticfield.add('resolution');
        staticfield.add('resolutiondate');
        staticfield.add('issuetype');
        
        
        set<string> dataType = new set<string>();
        dataType.add('string');
        dataType.add('textarea');
        dataType.add('label');
        dataType.add('textfield');
        dataType.add('labels');
        List<Jira_ProjectFieldsMapping__c> jpmnewpList=new List<Jira_ProjectFieldsMapping__c> ();
        if(Jira_ProjectFieldsMapping__c.sObjectType.getDescribe().isAccessible()){
            jpmnewpList= [SELECT Id,JIRA_Field_Api_Name__c, Name, Jira_Project__c, Salesforce_Object__c, Jira_Field_Name__c FROM Jira_ProjectFieldsMapping__c where DataType__c IN : dataType and Salesforce_Object__c =: selectedObject and JIRA_Field_Api_Name__c NOT IN : staticfield and Case_Field_Name__c =: ''];
        }
        for(Jira_ProjectFieldsMapping__c jpm : jpmnewpList){
            jirafields.add(jpm.Name);
        }
        for (String ji : jirafields) {
            jirafieldsToMap.add(new SelectOption(ji, ji));
        }
        
    }
    
    public void fillsfJiraFieldsWrapper (){
        
        //set<string> fieldslabel = new set<String>();
        map <String, Jira_ProjectFieldsMapping__c > sfJiraFields = new   map <String,  Jira_ProjectFieldsMapping__c > ();
        map <String, Jira_ProjectFieldsMapping__c > requiredsfJiraFields=new  map <String,  Jira_ProjectFieldsMapping__c > ();
        
        ExistingaMap= new Map<String,String>();
        ExistingcaseFields= new Map<String,String>();
        
        if(Jira_ProjectFieldsMapping__c.sObjectType.getDescribe().isAccessible()){
            jiraFieldsFromSf= new Map<id,Jira_ProjectFieldsMapping__c>([SELECT Id,Salesforce_Object__c,IsReportingEnabled__c, IsStatic__c, Name,ReqInIssueTypeData__c, RequiredInSF__c,IssueTypeData__c, Case_Field_Name__c,  IsRequired__c,  IsArray__c,  DataType__c,  JIRA_Field_Api_Name__c,ViewMode__c ,RelatedProjectIdSet__c,  ProjectissueTypeData__c,  ReadOnly__c,  Released__c,  Jira_Project__c,Jira_Project__r.Projectkey__c, Jira_Project__r.DefaultIssueType__c, Jira_Project__r.IssueType__c  ,Jira_Field_Name__c , section__c, section__r.column__c, section__r.name FROM  Jira_ProjectFieldsMapping__c
                                                                        Where Salesforce_Object__c= :selectedObject and
                                                                        Jira_Project__r.ProjectKey__c=:selectproject  
                                                                        order by section__r.order__c,order__c Asc nulls last  limit 1000]);
        }
        List<Jira_ProjectFieldsMapping__c> JiraFieldMappingToDelete= new List<Jira_ProjectFieldsMapping__c>();
        for (Jira_ProjectFieldsMapping__c instance: jiraFieldsFromSf.values()) {
            ExistingaMap.put(instance.JIRA_Field_Api_Name__c+'_'+instance.Jira_Project__c,instance.id);
            ExistingcaseFields.put(instance.Case_Field_Name__c+'_'+instance.Jira_Project__c,instance.id);

            
            if((jiraFieldsMapOp.containsKey(instance.JIRA_Field_Api_Name__c)
                ||(jiraFieldsMapReq.containsKey(instance.JIRA_Field_Api_Name__c)))
               && !instance.IsStatic__c 
               && instance.Salesforce_Object__c == selectedobject){
                   String prokey='';
                   if(instance.RelatedProjectIdSet__c!=null){
                       list<id> proidlist= new list<id>();
                       set<id> proidset= new set<id>();
                       for(String ids:instance.RelatedProjectIdSet__c.split(',')){
                           if(ids!='') proidlist.add(ids);
                       }
                       proidlist.sort();
                       proidset.addAll(proidlist);
                       
                       for(String ids:proidset){
                           
                           if(ids!='')prokey+=ProjectIdMap.containsKey(ids)?ProjectIdMap.get(ids).ProjectKey__c:'';
                       }
                   }
                   if(instance.IsRequired__c && jiraFieldsMapReq.get(instance.JIRA_Field_Api_Name__c).Fieldjsondata.required ){
                       requiredsfJiraFields.put(instance.JIRA_Field_Api_Name__c,instance);
                   }else { 
                       sfJiraFields.put(instance.JIRA_Field_Api_Name__c,instance);
                   }
               } 
        }
        
        for(String key:ProjectFieldmaps.keySet()){
            
            ProjectAndFieldWrapper PAFW=ProjectFieldmaps.get(key);
            Integer reqno=0;
            Integer opno=0;
            Integer otherno=0;
            list<Jira_ProjectFieldsMapping__c > reqlist = new   list<Jira_ProjectFieldsMapping__c > ();
            list<Jira_ProjectFieldsMapping__c > oplist = new   list<Jira_ProjectFieldsMapping__c > ();
            
            
            
            for(Jira_ProjectFieldsMapping__c Pfield:PAFW.ReqJiraFieldList){
                
                if(!requiredsfJiraFields.containskey(Pfield.JIRA_Field_Api_Name__c)){
                    reqlist.add(Pfield);
                }
            }
            reqList.addAll(requiredsfJiraFields.values());
            oplist.addAll(sfJiraFields.values());
            if(!oplist.isEmpty())
                oplist.add(0,new Jira_ProjectFieldsMapping__c());
            
            
            PAFW.ReqJiraFieldList=reqlist;
            PAFW.OpJiraFieldList=oplist;
            ProjectFieldmaps.put(key, PAFW);
        }
        
    }    
    
    public map<String,string> FetchMapedSfObject(){
        set<string> MappedSfObjectList= new set<string>();
        map<string,string> mappedSalesforceObjects = new map<string,string>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        if(Jira_ProjectFieldsMapping__c.sObjectType.getDescribe().isAccessible()){
           
            for (AggregateResult ar : [SELECT Salesforce_Object__c   FROM Jira_ProjectFieldsMapping__c where Salesforce_Object__c!=null group by  Salesforce_Object__c ]){
                //NameSpace removed Grz_Sf__Salesforce_Object__c to Salesforce_Object__c
                if(ar.get('Salesforce_Object__c')!=null){
                    MappedSfObjectList.add(String.valueof(ar.get('Salesforce_Object__c')));
                }
            }
        }
        if(!MappedSfObjectList.isEmpty()){
            for(String mappedSfObj : MappedSfObjectList){
                
                Schema.DescribeSObjectResult targetType = Schema.getGlobalDescribe().get(mappedSfObj).getDescribe() ;
                mappedSalesforceObjects.put(targetType.getName(),targetType.getLabel());
            }
        }
        
        Integer mappedObjCount = MappedSfObjectList.size();
        //Integer getLicenceObjcount = FeatureManagement.checkPackageIntegerValue('Object_Count');
        //Integer getCurrentObjcount = FeatureManagement.checkPackageIntegerValue('Current_Object_Count'); 
        Integer getLicenceObjcount =1;
        Integer getCurrentObjcount=0;
        if(mappedObjCount!=getCurrentObjcount){
            UpdateCurrentObjectcount(mappedObjCount);
        }
        
        ObjectLimitExceed = false; 
        ObjectLimit = false;
        if(mappedObjCount >= getLicenceObjcount){
            ObjectLimit = true;
        }
        if(mappedObjCount > getLicenceObjcount){
            ObjectLimitExceed = true;
            delObjCount=mappedObjCount-getLicenceObjcount;
        }
        
        return mappedSalesforceObjects; 
    }
    
    @future
    public static void UpdateCurrentObjectcount(Integer Count){
        FeatureManagement.setPackageIntegerValue('Current_Object_Count', Count); 
    }
    
    public List<SelectOption> FetchSalesforceObject(){
        List<SelectOption> SobjList= new List<SelectOption>();
        for(Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values()){
            String name = objTyp.getDescribe().getName();
            string label = objTyp.getDescribe().getLabel();
            if(!objTyp.getDescribe().isCustomSetting() && objTyp.getDescribe().isCreateable()
               && !name.containsignorecase('history') && !name.containsignorecase('tag')&&
               !name.containsignorecase('share') && !name.containsignorecase('feed') && !name.containsignorecase('JiraRelationship__c') &&
               !name.containsignorecase('JiraIssueComments__c') && !name.containsignorecase('CaseJiraHelper__c') && !name.containsignorecase('Child_Rule_Set__c')
               && !name.containsignorecase('Jira_Project__c') && !name.containsignorecase('JiraCommentController__c') && !name.containsignorecase('JiraErrorLogs__c')
               && !name.containsignorecase('JiraIssue__c')  && !name.containsignorecase('Jira_FieldSection__c') && !name.containsignorecase('Jira_ProjectFieldsMapping__c') 
               && !name.containsignorecase('Rule_Set__c')){      
                   SobjList.add(new SelectOption(name,label));
               }
        }
        SobjList.sort();
        return SobjList;
        
    }
    
    public map<String,set<string>> fetchDataTypeMap(){
        set<string> SetForPickList = new set<string>();
        SetForPickList.add('priority');
        SetForPickList.add('securitylevel');
        SetForPickList.add('radiobuttons');
        SetForPickList.add('version');
        SetForPickList.add('user');
        SetForPickList.add('userpicker');
        SetForPickList.add('select');
        
        
        set<string> SetForText = new set<string>();
        SetForText.add('string');
        SetForText.add('textarea');
        SetForText.add('label');
        SetForText.add('labels');
        SetForText.add('textfield');
        SetForText.add('url');
        
        
        set<string> SetForMultiPicklist = new set<string>();
        SetForMultiPicklist.add('multicheckboxes');
        SetForMultiPicklist.add('multiselect');
        SetForMultiPicklist.add('multiuserpicker');
        SetForMultiPicklist.add('multiversion');
        SetForMultiPicklist.add('component');
        SetForMultiPicklist.add('version');
        
        
        
        set<string> SetForJiraTypesOnly = new set<string>();
        SetForJiraTypesOnly.add('cascadingselect');
        SetForJiraTypesOnly.add('issuelinks');
        SetForJiraTypesOnly.add('gh-epic-label');
        SetForJiraTypesOnly.add('gh-epic-link');
        SetForJiraTypesOnly.add('issuelink');
        
        dataTypeMap.put('none',SetForJiraTypesOnly);
        dataTypeMap.put('picklist',SetForPickList);  
        dataTypeMap.put('reference',SetForText);  
        dataTypeMap.put('string',SetForText);
        dataTypeMap.put('textarea',SetForText);
        dataTypeMap.put('date', new set<String>{'datepicker','date'});
        dataTypeMap.put('integer' , new set<String>{'float'});
        dataTypeMap.put('double' , new set<String>{'float'});
        dataTypeMap.put('percent' , new set<String>{'float'});
        dataTypeMap.put('currency' , new set<String>{'float'});
        dataTypeMap.put('datetime' , new set<String>{'datetime'});
        // dataTypeMap.put('date' , new set<String>{'datepicker'});
        dataTypeMap.put('multipicklist' ,SetForMultiPicklist);
        dataTypeMap.put('email',SetForText);
        dataTypeMap.put('phone',SetForText);
        dataTypeMap.put('url',SetForText);
        dataTypeMap.put('address',SetForText);
        dataTypeMap.put('id',SetForText);
        return dataTypeMap;
    }
    
    /**
* Methods to fetch jira fields other than fields in set 'DEFAULT_MAPPED_JIRA_FEILDS'.
* @return fields  Map of < String, List < Selectoption >> holds the data type and list of fields.
*  @param jiraMetadataJson json data storing the metadata of jira issue
*/ 
    
    public void fetchJiraFields(String jiraMetadataJson,set<String> DEFAULTFEILDS){
        //Set<String> AllowedDatatypes = new Set<String>{'gh-epic-label','gh-epic-link','radiobuttons','multicheckboxes','multiselect','select','multiuserpicker','multiversion','version','cascadingselect','userpicker','datepicker','datetime','component','user', 'textfield','textarea','float','labels','string'};
        //Set<String> AllowedDatatypes = new Set<String>{'radiobuttons','multicheckboxes','multiselect','select','multiuserpicker','multiversion','version','cascadingselect','userpicker','datepicker','datetime','component','user', 'textfield','textarea','float','labels','string','','issuelinks'};
        Set<String> AllowedDatatypes = new Set<String>{'url','securitylevel','date','issuelink','priority','gh-epic-label','gh-epic-link','radiobuttons','multicheckboxes','multiselect','select','multiuserpicker','multiversion','version','cascadingselect','userpicker','datepicker','datetime','component','user', 'textfield','textarea','float','labels','string','issuelinks'};
            
            map<String,map<String,Projects.Fieldmeta>> ProjectFieldData=JiraService.fetchJIRACustomFields(jiraMetadataJson); 
        
        for(String key:ProjectFieldData.keyset() ){
            
            map<string,Jira_ProjectFieldsMapping__c>  reqjirafieldmapping=new  map<string,Jira_ProjectFieldsMapping__c>();
            map<string,Jira_ProjectFieldsMapping__c>  opjirafieldmapping=new  map<string,Jira_ProjectFieldsMapping__c>();
            
            list<Jira_ProjectFieldsMapping__c> ReqJiraFieldList = new list<Jira_ProjectFieldsMapping__c>();
            list<Jira_ProjectFieldsMapping__c> OpJiraFieldList = new list<Jira_ProjectFieldsMapping__c>();
            
            list<SelectOption> Reqselectoption=new list<SelectOption>();
            list<SelectOption> Opselectoption=new list<SelectOption>();
            
            for(String value:ProjectFieldData.get(key).keyset()){
                
                Jira_ProjectFieldsMapping__c jiraFieldmap= new Jira_ProjectFieldsMapping__c();
                Projects.Fieldmeta PrField= ProjectFieldData.get(key).get(value);
                
                jiraFieldmap.Case_Field_Name__c='';
                //sandeep 
                jiraFieldmap.Name=''+PrField.Fieldjsondata.name;
                
                String Datatype='';
                if(PrField.Fieldjsondata.schema.custom!=Null){
                    Datatype =PrField.Fieldjsondata.schema.custom.substring(PrField.Fieldjsondata.schema.custom.lastIndexOf(':')+1,PrField.Fieldjsondata.schema.custom.length()) ;
                }else if(PrField.Fieldjsondata.schema.items!=Null){
                    Datatype =PrField.Fieldjsondata.schema.items;
                } else{
                    Datatype =PrField.Fieldjsondata.schema.type; 
                }
                if(!DEFAULTFEILDS.contains(PrField.Fieldname)  && AllowedDatatypes.contains(Datatype)){
                    
                    jiraDataTypeMap.put(PrField.Fieldname,Datatype);
                    if(Datatype=='user'||Datatype=='userpicker' ||Datatype=='multiuserpicker'){
                        jiraDataTypeMap.put(PrField.Fieldname,'textarea');
                    }
                    jiraFieldmap.JIRA_Field_Api_Name__c=PrField.Fieldname;
                    jiraFieldmap.Jira_Field_Name__c=PrField.Fieldjsondata.name;
                    if(PrField.Fieldjsondata.required){
                        jiraFieldmap.IsRequired__c=TRUE;
                        jiraFieldsMapReq.put(PrField.Fieldname, PrField);
                        reqjirafieldmapping.put(PrField.Fieldname,jiraFieldmap);
                    }else{
                        jiraFieldmap.IsRequired__c=false;
                        jiraFieldsMapOp.put(PrField.Fieldname, PrField);
                        opjirafieldmapping.put(PrField.Fieldname,jiraFieldmap);
                    }
                    if(PrField.ReqInIssuetype!=null && PrField.ReqInIssuetype!=''){
                        jiraFieldmap.IsRequired__c=true;
                    }
                }
            }
            
            for(String fieldname:reqjirafieldmapping.keySet()){
                ReqJiraFieldList.add(reqjirafieldmapping.get(fieldname));
                Reqselectoption.add(new SelectOption(reqjirafieldmapping.get(fieldname).JIRA_Field_Api_Name__c,reqjirafieldmapping.get(fieldname).Jira_Field_Name__c));
                
            } 
            
            
            /* ************************** */
            for(String fieldname:opjirafieldmapping.keySet()){
                OpJiraFieldList.add(opjirafieldmapping.get(fieldname));
                Opselectoption.add(new SelectOption(opjirafieldmapping.get(fieldname).JIRA_Field_Api_Name__c,opjirafieldmapping.get(fieldname).Jira_Field_Name__c));
                
            } 
            
            ProjectAndFieldWrapper PAFW =new ProjectAndFieldWrapper(projectIdKeyMap.get(key).ProjectKey__c,
                                                                    ReqJiraFieldList,OpJiraFieldList
                                                                    ,Reqselectoption,Opselectoption);
            
            
            ProjectFieldmaps.put(projectIdKeyMap.get(key).ProjectKey__c,PAFW);
            
            /* newdataTypeMap -- > Map of jirafields Datatype to Salesforce object fields datatype*/
            Map<String,set<string>> newdataTypeMap = new Map<String,set<string>>();
            
            for(String SfDataType : dataTypeMap.keySet()){
                for(String jiraDT : dataTypeMap.get(SfDataType)){
                    if(!newdataTypeMap.containsKey(jiraDT)){
                        newdataTypeMap.put(jiraDT,new set<String>{SfDataType});
                    }else{
                        newdataTypeMap.get(jiraDT).add(SfDataType);
                    }
                }                    
            }
            
            
            /* reqSFJiraDataType --> Map of jira Datatype to SF object Fields*/
            reqSFJiraDataType = new map<string,list<selectoption>>();
            reqSFJiraDataType.put('',new list<selectoption>{new SelectOption('','')});
            if(salesForceFields != null){
                
                for(selectoption so : salesForceFields){ 
                    for(String jiDataType : newdataTypeMap.keySet()){
                        if(newdataTypeMap.get(jiDataType).contains(sfDataTypeMap.get(so.getvalue()))){
                            if(!reqSFJiraDataType.containsKey(jiDataType)){
                                reqSFJiraDataType.put(jiDataType,new list<selectoption>{new SelectOption((so.getvalue()),so.getLabel())});
                            }else{
                                List<selectOption> tempList = reqSFJiraDataType.get(jiDataType);
                                List<String> stringValues = new List<String>();
                                for(SelectOption temp: tempList){
                                    stringValues.add(temp.getValue());
                                }
                                if(!stringValues.contains(so.getvalue()))
                                    reqSFJiraDataType.get(jiDataType).add(new  SelectOption((so.getvalue()),so.getLabel()));
                            }
                        }else{
                            if(!reqSFJiraDataType.containsKey(jiDataType)){
                                reqSFJiraDataType.put(jiDataType,new list<selectoption>{new SelectOption('',System.label.NoneLabel)});
                            }
                        }
                    }
                }
            }
            if(!reqSFJiraDataType.isEmpty()){
                for(String req : reqSFJiraDataType.keySet()){
                    List<string> selectOptionList = new List<string>();
                    if(reqSFJiraDataType.get(req) != null){
                        for (selectoption so : reqSFJiraDataType.get(req)){
                            selectOptionList.add(so.getLabel());
                        }
                        if(!selectOptionList.contains('None') && req != ''){
                            
                            reqSFJiraDataType.get(req).add(0,new  SelectOption('',System.label.NoneLabel));
                        }
                    }
                }
                for(string reqsf : reqSFJiraDataType.keySet()){
                    reqSFJiraDataType.get(reqsf).sort();
                }
            }
            /******************************************************************** */
            
            /* opSFJiraDataType --> Map of SF Datatype to Jira Fields*/
            for(selectoption so: Opselectoption){
                for(String sfDatatype : dataTypeMap.keySet()){
                    if(dataTypeMap.get(sfDatatype).contains(jiraDataTypeMap.get(so.getvalue()))){
                        
                        if(!opSFJiraDataType.containsKey(sfDatatype)){
                            opSFJiraDataType.put(sfDatatype,new list<selectoption>{new SelectOption((so.getvalue()),(String)so.getLabel())});
                        }else{
                            List<selectOption> tempList = opSFJiraDataType.get(sfDatatype);
                            List<String> stringValues = new List<String>();
                            for(SelectOption temp: tempList){
                                stringValues.add(temp.getValue());
                            }
                            if(!stringValues.contains(so.getvalue()))
                                opSFJiraDataType.get(sfDatatype).add(new SelectOption((so.getvalue()),(String)so.getLabel()));
                        }
                    }else{
                        if(!opSFJiraDataType.containsKey(sfDatatype)){
                            // opSFJiraDataType.put('none',new list<selectoption>{new SelectOption('none','none')});
                            opSFJiraDataType.put(sfDatatype,new list<selectoption>{new SelectOption('none',System.label.noneLabel1)});
                        }
                    }
                }
            }
            if(!opSFJiraDataType.isEmpty()){
                for(String op : opSFJiraDataType.keySet()){
                    List<string> selectOptionList = new List<string>();
                    if(opSFJiraDataType.get(op) != null){
                        for (selectoption so : opSFJiraDataType.get(op)){
                            selectOptionList.add(so.getLabel());
                        }
                        if(!selectOptionList.contains('None') && op != ''){
                            
                            opSFJiraDataType.get(op).add(0,new  SelectOption('',System.label.NoneLabel));
                        }
                    }
                }
                for(string opsf : opSFJiraDataType.keySet()){
                    opSFJiraDataType.get(opsf).sort();
                }
            }
            /******************************************************************** */
        }        
    }
    
    
    /**
* Methods to fetch object fields .  
* @return objectFields  Map of < String, List < Selectoption >> holds the data type and list of fields.
*/
    public  List < SelectOption > fetchSalesForceFields(String objectName){
        
        if(objectName == null || deleteoperation){
            List<Jira_ProjectFieldsMapping__c> jpmList=new List<Jira_ProjectFieldsMapping__c>();
            if(Jira_ProjectFieldsMapping__c.sObjectType.getDescribe().isAccessible()){
                jpmList = [SELECT Id, Name, Enable_Record_Mapping__c, Salesforce_Object__c FROM Jira_ProjectFieldsMapping__c where Salesforce_Object__c !=Null order by LastModifiedDate desc Limit 1];
            }
            if(jpmList!=NULL && !jpmList.isEmpty()){
                for(Jira_ProjectFieldsMapping__c jpm : jpmList){                
                    
                    if(jpm != null){
                        objectName = jpm.Salesforce_Object__c;
                        selectedObject = objectName;
                        deleteoperation=false;
                    }
                }
            }else{
                
                
                objectName = 'None';
                selectedObject = 'None';
                
                
            }
        }
        if(selectedObject!='None'){
            selectedObjectName=selectedObject;
            if(Organization.sObjectType.getDescribe().isAccessible() && Schema.sObjectType.Organization.fields.NamespacePrefix.isAccessible()){
                
                String OrgNameSpace =[SELECT Id, NamespacePrefix  FROM Organization LIMIT 1].NamespacePrefix;
                if(OrgNameSpace!=null && OrgNameSpace!=''){
                    selectedObjectName=selectedObjectName.replace(OrgNameSpace+'__', '');
                    selectedObjectName=selectedObjectName.replace(OrgNameSpace.toLowerCase()+'__', '');
                }
            }
            if(selectedObjectName.Contains('Grz_Sf__') || selectedObjectName.Contains('grz_sf__'))
            {
                selectedObjectName=selectedObjectName.remove('Grz_Sf__');
                selectedObjectName=selectedObjectName.remove('grz_sf__');
            }
            if(selectedObjectName.contains('__c') || selectedObjectName.contains('__C'))
            {
                selectedObjectName=selectedObjectName.removeEnd('__C');
                selectedObjectName=selectedObjectName.removeEnd('__c');
            }
            if(selectedObjectName.contains('__'))selectedObjectName=selectedObjectName.substring(selectedObjectName.indexof('__')+2,selectedObjectName.length() );
        }
        caseFieldValueToLabel = new Map<String,String>();
        
        List < SelectOption > caseFields = new List < SelectOption > ();
        
        if(objectName != null && objectName != 'None'){
            
            fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
            
            
            //AllFields = new List < SelectOption > ();
            for (Schema.SObjectField sfield: fieldMap.Values()) {
                schema.describefieldresult dfield = sfield.getDescribe();
                String dataType = String.valueOf(dfield.getType());
                if(JiraService.sfJiraDataTypeMapping.get(dataType)!=Null){
                    SelectOption soptionInstance = new SelectOption(dfield.getname(), dfield.getLabel());
                    caseFields.add(soptionInstance);
                    
                }
            } 
            caseFields.sort();
            for(SelectOption so : caseFields){
                caseFieldValueToLabel.put(so.getValue(), so.getLabel());
            }
            caseFields.add(new Selectoption('','None'));
            List<Jira_ProjectFieldsMapping__c> jpmList2=new List<Jira_ProjectFieldsMapping__c> ();
            if(Jira_ProjectFieldsMapping__c.sObjectType.getDescribe().isAccessible()){
                jpmList2 = [SELECT Id, Name, Enable_Record_Mapping__c, Salesforce_Object__c FROM Jira_ProjectFieldsMapping__c where Salesforce_Object__c =: objectName and Enable_Record_Mapping__c =: True order by LastModifiedDate desc Limit 1];
            }
            if(Schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.Name.isAccessible() && jpmList2!=NULL && !jpmList2.isEmpty()){
                jirafieldsToMapVal = jpmList2[0].Name;
            }
            
            return caseFields;
        }
        
        return null; 
        
    } 
    public PageReference DefaultSave(){
        set<Id> enablesfmapping = new Set<Id>();
        set<Jira_ProjectFieldsMapping__C> jpmSet = new set<Jira_ProjectFieldsMapping__C>();
        list<Jira_ProjectFieldsMapping__C> jpmlistttt = new list<Jira_ProjectFieldsMapping__C>();
        List<Jira_ProjectFieldsMapping__C> jiraProjectMapList=new List<Jira_ProjectFieldsMapping__C>();
        for(DynamicFieldWrapper dynamic : DefaultWrapper.JiraFields){
            if(dynamic.mappedfield.datatype__c=='cascadingselect'){ 
                if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.Default_Value_long__c.isUpdateable()){
                    dynamic.mappedfield.Default_Value_long__c=dynamic.masterFieldValue+'_child_'+dynamic.childFieldValue; 
                }
            }else if((dynamic.mappedfield.IsArray__c) && 
                     (dynamic.mappedfield.DataType__c=='multicheckboxes' || 
                      dynamic.mappedfield.DataType__c=='multiselect' || 
                      dynamic.mappedfield.DataType__c=='version' || 
                      dynamic.mappedfield.DataType__c=='component' || 
                      dynamic.mappedfield.DataType__c=='multiversion' )){ 
                          
                          String value='';
                          
                          for(String val:dynamic.multiselectvalues){
                              val=val.trim();
                              value=value+','+val;
                              
                          }  
                          value=value.removeStart(',');
                          if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.Default_Value_long__c.isUpdateable()){
                              dynamic.mappedfield.Default_Value_long__c= value;
                          }
                      }
            else if(dynamic.mappedfield.datatype__c=='datepicker'){
                if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.Default_Value_long__c.isUpdateable()){
                    dynamic.mappedfield.Default_Value_long__c=String.valueOf(dynamic.dat);
                }
                
            }else if(dynamic.mappedfield.datatype__c=='datetime'){
                if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.Default_Value_long__c.isUpdateable()){
                    DateTime dt=DateTime.valueOf(dynamic.dattime);
                    String value=String.valueOf(dt.format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
                    dynamic.mappedfield.Default_Value_long__c=value; 
                    
                }                
            }else if(dynamic.mappedfield.datatype__c=='user'||dynamic.mappedfield.datatype__c=='userpicker'){
                if(UserMapDetails.get(dynamic.fieldValue)!=null){
                    if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.Default_Value_long__c.isUpdateable()){
                        dynamic.mappedfield.Default_Value_long__c=UserMapDetails.get(dynamic.fieldValue);
                        UserMapDetails=new Map<String,String>();
                        username='';
                        userlistbyname = new List<SelectOption>();  
                        
                    }                
                }
                
            }else if(dynamic.mappedfield.datatype__c=='multiuserpicker' &&
                     dynamic.fieldValue!=null && dynamic.fieldValue!=''){ 
                         dynamic.fieldValue= dynamic.fieldValue.removeEnd(',');
                         dynamic.fieldValue= dynamic.fieldValue.trim();
                         String Json='';
                         for(String val:dynamic.fieldValue.split(',')){
                             val=val.trim();
                             if(Json==''){
                                 json='{"users": [';
                             }
                             Json+=UserMapDetails.get(val)+',';
                         }
                         Json=Json.removeEnd(',')+']}';
                         dynamic.mappedfield.Default_Value_long__c=Json;
                         UserMapDetails=new Map<String,String>();
                         username='';
                         userlistbyname = new List<SelectOption>();  
                         
                         
                     }else  if(dynamic.mappedfield.datatype__c != null){
                         if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.Default_Value_long__c.isUpdateable()){
                             dynamic.mappedfield.Default_Value_long__c=String.valueOf(dynamic.fieldValue);
                         }
                     }
            jiraProjectMapList.add(dynamic.mappedfield);
            if(dynamic.mappedfield.Enable_Record_Mapping__c){
                enablesfmapping.add(dynamic.mappedfield.id);
            }
        }
        if(!jiraProjectMapList.isEmpty()){
            try{
                if(schema.sObjectType.Jira_ProjectFieldsMapping__c.isUpdateable()){
                    update jiraProjectMapList;
                }
            }catch(Exception ex){
                String Error=System.label.Cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                GenerateJiraLogs.CreateLogRealTime('FieldsSettingController',null, null, null,null,null, null , null, null, 'Save updated jira project field mapping ', Error);
            }
        }
        
        if(!enablesfmapping.isEmpty()){
            updateJiraProjectFieldMapping(enablesfmapping,jiraProjectMap.get(selectproject).id);
        }
        
        return null;
    } 
    public void DefaultSectionDataApex(){
        UserMapDetails = new Map<String,String>();
        
        String SelectedObjectForDefault  = ApexPages.currentPage().getParameters().get('SelectedObjectForDefault');
        jiraFieldApiForDefault = ApexPages.currentPage().getParameters().get('jiraFieldApiForDefault');
        DefaultValueWrapper Wrap = new DefaultValueWrapper(SelectedObjectForDefault,jiraFieldApiForDefault,jiraProjectMap.get(selectproject).id);  
        DefaultWrapper =wrap;
        string data; 
        List<String> lstAlpha = new List<string>();
        for(DynamicFieldWrapper dynamic : DefaultWrapper.JiraFields){
            if(dynamic.mappedfield.Default_Value_long__c == null || 
               (dynamic.mappedfield.Default_Value_long__c != null && dynamic.mappedfield.Default_Value_long__c.trim()=='')){
                   continue;
               }
            if(dynamic.mappedfield.DataType__c=='multicheckboxes' || dynamic.mappedfield.DataType__c=='multiselect' || 
               dynamic.mappedfield.DataType__c=='version' || dynamic.mappedfield.DataType__c=='component' ||
               dynamic.mappedfield.DataType__c=='multiversion'){
                   
                   for(String key : dynamic.mappedfield.Default_Value_long__c.split(',')){
                       dynamic.multiselectvalues.add(key.trim());
                       
                   }
               }
            else if(dynamic.mappedField.datatype__c=='Cascadingselect'){
                String val=dynamic.mappedField.Default_Value_long__c;
                if(val.contains('_child_')){
                    list<String> DepValue=val.split('_child_');
                    dynamic.childFieldValue=DepValue[1]; 
                    dynamic.masterFieldValue=DepValue[0];
                }
            }
            else if(dynamic.mappedfield.datatype__c=='datepicker'){
                String val=dynamic.mappedField.Default_Value_long__c;
                
                dynamic.dat=date.valueOf(val);
            }
            else if(dynamic.mappedfield.datatype__c=='datetime'){
                String val=dynamic.mappedField.Default_Value_long__c.split('\\.')[0];
                val=val.replace('T', ' ');
                dynamic.dattime=datetime.valueOf(val);
            }
            else if(dynamic.mappedfield.datatype__c=='user'||dynamic.mappedfield.datatype__c=='userpicker'){
                UserMapDetails = new Map<String,String>();
                Map<String,Object>UserMap = (Map<String,Object>)JSON.deserializeUntyped(dynamic.mappedfield.Default_Value_long__c);
                String selectval=String.valueOf(UserMap.get('displayName'))+' ('+String.valueOf(UserMap.get('name'))+')';
                UserMapDetails.put(selectval, dynamic.mappedfield.Default_Value_long__c);
                dynamic.fieldValue=selectval;
            }
            else if(dynamic.mappedfield.datatype__c=='multiuserpicker'){
                UserMapDetails = new Map<String,String>();
                dynamic.fieldValue='';
                Map<String,Object>UsersMap = (Map<String,Object>)JSON.deserializeUntyped(dynamic.mappedfield.Default_Value_long__c);
                List<Object>Users = (List<Object>)UsersMap.get('users');
                for(Object us:Users){ 
                    Map<String,Object>UserMap = (Map<String,Object>)us;
                    String selectval=String.valueOf(UserMap.get('displayName'))+' ('+String.valueOf(UserMap.get('name'))+')';
                    UserMapDetails.put(selectval,JSON.serialize(us));
                    dynamic.fieldValue+=selectval+',\n';
                }
                dynamic.fieldValue=dynamic.fieldValue.removeEnd(',');
                
            }
            else if(dynamic.mappedfield.Default_Value_long__c != null){
                dynamic.fieldValue = dynamic.mappedField.Default_Value_long__c;
            }
            
            //dynamic.multiselectvalues.addAll(lstAlpha);
            
        }
        
    }    
    
    public void updateJiraProjectFieldMapping(Set<Id> JiIdSet, String JiraProjectId){
        List<Jira_ProjectFieldsMapping__c> listOfProjectFieldMapping = new List<Jira_ProjectFieldsMapping__c>();
        List<Jira_ProjectFieldsMapping__c> listOfenableRecordMapping = new List<Jira_ProjectFieldsMapping__c>();
        List<Jira_ProjectFieldsMapping__c> delJpmList=new  List<Jira_ProjectFieldsMapping__c> ();
        
        if(Jira_ProjectFieldsMapping__c.sObjectType.getDescribe().isAccessible()){
            delJpmList = [SELECT Id,JIRA_Field_Api_Name__c, Name, Salesforce_Object__c, Enable_Record_Mapping__c 
                          FROM Jira_ProjectFieldsMapping__c 
                          Where Jira_Project__c=:JiraProjectId and Salesforce_Object__c =: SelectedObject and Enable_Record_Mapping__c =: true and id not in :JiIdSet];
        }
        if(!delJpmList.isEmpty()){
            for(Jira_ProjectFieldsMapping__c jpm : delJpmList){
                if(schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.Enable_Record_Mapping__c.isUpdateable()){
                    jpm.Enable_Record_Mapping__c = false;
                }
                listOfenableRecordMapping.add(jpm);
            }
            
            if(!listOfenableRecordMapping.isEmpty()){
                try{
                    if(schema.sObjectType.Jira_ProjectFieldsMapping__c.isUpdateable()){
                        update listOfenableRecordMapping;
                    }
                }catch(Exception ex){
                    String Error=System.label.Cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                    GenerateJiraLogs.CreateLogRealTime('FieldsSettingController',null, null, null,null,null, null , null, null, 'Update jira project field mapping', Error);
                }
            }
        }
        //jirafieldsToMapVal Enable_Record_Mapping__c
    }
    public void updateValue(){
        String updateObj= ApexPages.currentPage().getParameters().get('updateObj');
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.DescribeSObjectResult targetType = Schema.getGlobalDescribe().get(updateObj).getDescribe();
        selectedObject = updateObj;
        fetchfields();
    }
    public void deleteMappingForSelectedObj(){
        
        String delObj= ApexPages.currentPage().getParameters().get('delObj');
        
        try{
            if(Jira_ProjectFieldsMapping__c.sObjectType.getDescribe().isAccessible() && schema.sObjectType.Jira_ProjectFieldsMapping__c.isDeletable()){
                delete [SELECT Id, Name, Jira_Project__c, Salesforce_Object__c, Jira_Field_Name__c FROM Jira_ProjectFieldsMapping__c where Salesforce_Object__c =: delObj ];
            }else{
                return;
            }
            
            if(Validation__c.sObjectType.getDescribe().isAccessible() && schema.sObjectType.Validation__c.isDeletable()){
                delete [SELECT id, Name,Object__c from Validation__c where Object__c=: delObj];
            }
        }catch(Exception ex){
            String Error=System.label.Cause_Label +ex.getCause()+'\n'+System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('FieldsSettingController',null, null, null,null,null, null , null, null, 'Delete mapping for selected object', Error);
        }
        deleteoperation=true;
        
        if(Jira_ProjectFieldsMapping__c.sObjectType.getDescribe().isAccessible()){
            List<Jira_ProjectFieldsMapping__c> jnewpList= [SELECT Id, Name, Jira_Project__c, Salesforce_Object__c, Jira_Field_Name__c FROM Jira_ProjectFieldsMapping__c order by CreatedDate DESC LIMIT 1];
            if(!jnewpList.isEmpty()){
                selectedObject = jnewpList[0].Salesforce_Object__c;
            }else{
                selectedObject = 'None';
                deleteoperation=false;
            }
        }
        fetchfieldsInitial();
    }
    
    public void deleteobjectsMapping(){
        objectToBeDeleted = objectToBeDeleted.removeEnd(',');  
        try{
            if(objectToBeDeleted != '' && objectToBeDeleted != null){
                List<String> delObj = objectToBeDeleted.split(',');
                if(!Jira_ProjectFieldsMapping__c.sObjectType.getDescribe().isAccessible() && !Validation__c.sObjectType.getDescribe().isAccessible())
                {return;}
                List<jira_projectfieldsmapping__c> jpmlist = [SELECT Id,salesforce_object__c from jira_projectfieldsmapping__c where salesforce_object__c IN :delObj ];
                if(!jpmlist.isEmpty()){
                    if(schema.sObjectType.jira_projectfieldsmapping__c.isDeletable()){
                        delete jpmlist;
                    }
                }
                List<Validation__c> valList = [SELECT id, Name,Object__c from Validation__c where Object__c in : delObj];
                if(schema.sObjectType.Validation__c.isDeletable()){
                    delete valList;
                }
            }
        }catch(Exception ex){
            String Error=System.label.Cause_Label +ex.getCause()+'\n'+System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('FieldsSettingController',null, null, null,null,null, null , null, null, 'Delete object mapping', Error);
            
            
        }
        // fetchfields();
        
    }
    public PageReference AsyncJobDone(){
        Integer i=[SELECT  count() FROM AsyncApexJob where MethodName =:jobname and Status in ('Queued','Preparing','Processing')  and jobType='Future' ];
        if(i==0){
            AllJobCompleted=true; 
        }
        return null;
    }
    public PageReference saveFields() {
        Jira_login__c setting=new Jira_login__c();
        if(Jira_login__c.sObjectType.getDescribe().isAccessible()){
            setting=Jira_login__c.getInstance('JIRA');
        }
       
        Boolean delList=false;
        displayError='';
        showAlert=false;
        map<id,id> newMap = new map<id,id>();
        
        List < Jira_ProjectFieldsMapping__c > sfJiraFieldMapping = new List < Jira_ProjectFieldsMapping__c > ();
        list<Jira_ProjectFieldsMapping__c> ListtoUpdate= new list<Jira_ProjectFieldsMapping__c>();
        list<Jira_ProjectFieldsMapping__c> JiraFieldFinal=new list<Jira_ProjectFieldsMapping__c>();
        list<Jira_ProjectFieldsMapping__c> JiraFieldToDelFinal=new list<Jira_ProjectFieldsMapping__c>();
        
        String commonindex= ApexPages.currentPage().getParameters().get('index');
        List<String> commindexval=commonindex.split(',');
        
        try {    
            for(Integer i=0;i<commindexval.size();i++ ){
                String index=commindexval[i];
                if(index!=null&&index!=''){
                    List<String> indexval=index.split('_');
                    Jira_ProjectFieldsMapping__c Prfield = new Jira_ProjectFieldsMapping__c();
                    if(indexval[0]=='req')
                        Prfield=  ProjectFieldmaps.get(indexval[2]).ReqJiraFieldList[Integer.valueOf(indexval[1])]; 

                    if(indexval[0]=='op')
                        Prfield=  ProjectFieldmaps.get(indexval[2]).OpJiraFieldList[Integer.valueOf(indexval[1])]; 
                   
                    if(Schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.Salesforce_Object__c.isCreateable() && Schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.Salesforce_Object__c.isUpdateable()){
                        Prfield.Salesforce_Object__c =selectedObject;
                    }
                    if(Schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.Jira_Project__c.isCreateable() &&
                       Prfield.Jira_Project__c==null ){
                        Prfield.Jira_Project__c =jiraProjectMap.get(selectproject).id;
                    }
                    if(Schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.RelatedProjectIdSet__c.isCreateable()&&
                       Schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.RelatedProjectIdSet__c.isUpdateable()
                       && Prfield.RelatedProjectIdSet__c==null ){
                        Prfield.RelatedProjectIdSet__c =jiraProjectMap.get(selectproject).id;
                    }
                    if(Schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.IsReportingEnabled__c.isCreateable() && 
                       Schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.IsReportingEnabled__c.isUpdateable()){  
                        if(JiraIssueFields.contains(Prfield.JIRA_Field_Api_Name__c) && Prfield.IsReportingEnabled__c!=true){
                            Prfield.IsReportingEnabled__c=true;
                        }
                    }
                    if(Schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.section__c.isCreateable() && Schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.section__c.isUpdateable() &&
                       Schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.order__c.isCreateable() && Schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.order__c.isUpdateable()){
                           if(Prfield.section__c==null && Prfield.JIRA_Field_Api_Name__c!= 'issuelinks'){
                               Prfield.order__c=1;
                               Prfield.section__c=sectionmap.get('Jira Fields')!=null?sectionmap.get('Jira Fields').id:null;
                               
                           }
                           if(Prfield.JIRA_Field_Api_Name__c== 'issuelinks'){
                               Prfield.order__c=1;
                               Prfield.section__c=sectionmap.get('Issue Links')!=null?sectionmap.get('Issue Links').id:null;
                           }
                           
                       }
                    
                    if(Prfield.Jira_Project__c != null){
                        if((ExistingaMap.containskey(Prfield.JIRA_Field_Api_Name__c+'_'+Prfield.Jira_Project__c) &&
                            Prfield.Id!=ExistingaMap.get(Prfield.JIRA_Field_Api_Name__c+'_'+Prfield.Jira_Project__c))){
                                
                                if(jiraFieldsMapReq.containsKey(Prfield.JIRA_Field_Api_Name__c)){
                                    displayError='"'+jiraFieldsMapReq.get(Prfield.JIRA_Field_Api_Name__c).Fieldjsondata.Name+'" already Exist';
                                }else if(jiraFieldsMapOp.containsKey(Prfield.JIRA_Field_Api_Name__c)){
                                    displayError='"'+jiraFieldsMapOp.get(Prfield.JIRA_Field_Api_Name__c).Fieldjsondata.Name+'" already Exist';
                                }
                                if(displayError!=''){
                                    showAlert=true;
                                    return null;
                                }
                            }
                        
                        if(ExistingcaseFields.containskey(Prfield.Case_Field_Name__c+'_'+Prfield.Jira_Project__c) &&
                           Prfield.Id!=ExistingcaseFields.get(Prfield.Case_Field_Name__c+'_'+Prfield.Jira_Project__c)){
                               
                               if(caseFieldValueToLabel.containsKey(Prfield.Case_Field_Name__c)){
                                   displayError='"'+caseFieldValueToLabel.get(Prfield.Case_Field_Name__c)+'"'+ System.label.FieldsSettingController_Label2;
                                   showAlert=true;
                                   return null;
                               }
                               
                           }
                    }
                    JiraFieldFinal.add(Prfield) ;
                }
            }
            
            if (!JiraFieldFinal.IsEmpty()){                
                if(Schema.sObjectType.Jira_ProjectFieldsMapping__c.isUpdateable() && Schema.sObjectType.Jira_ProjectFieldsMapping__c.isCreateable()){
                    upsert JiraFieldFinal;
                }
            }
            Fieldsuccess=true;
            projectSuccess=true;
            loginSuccess=true;
            
            if(Fieldsuccess&& loginSuccess && projectSuccess && !setting.LoginSuccess__c){
                if(Schema.sObjectType.Jira_login__c.fields.LoginSuccess__c.isUpdateable() && Schema.sObjectType.Jira_login__c.fields.LoginSuccess__c.isCreateable()){
                    setting.LoginSuccess__c=true;
                }
                if(Schema.sObjectType.Jira_login__c.isUpdateable() && Schema.sObjectType.Jira_login__c.isCreateable()){
                    upsert setting;
                }
            }
            //caseNumberSettingValue=caseNumberSetting.JiraFieldApi__c;
            
            
            // fillsfJiraFieldsWrapper();
        }catch (Exception ex) {
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('FieldsSettingController','' + ''  + '', '', null, null,null,null,null, '', 'Save Fields', Error);
            String message = ex.getMessage();
            if (message.contains('DUPLICATE_VALUE')) {
                AdminSettingController.ErrorMessage(System.label.FieldsSettingController_Label1);
            }
        }
        return null;
    }
    /**
* method to add new FieldsWrapper in sfJiraFieldsWrapper.this adds the new row to map fields on Fieldsetting page
*/
    public PageReference addJiraSfField() {
        String projectkey=ApexPages.currentPage().getParameters().get('projectkey');
        ProjectAndFieldWrapper PAFW= ProjectFieldmaps.get(projectkey);
        PAFW.OpJiraFieldList.add(new Jira_ProjectFieldsMapping__c());
        return null;
    }
    
    
    public void refreshFieldSettings(){ 
        RefreshFieldConfiguration RefFCong= new RefreshFieldConfiguration();
        RefFCong.FetchProjects();
        //fetchfields();
    }
    /**
* removes the field mapping row from fields setting page
*/
    public PageReference removeJiraSfField() {
        Integer indextodel;
        String indextodelfrom;
        
        list<Jira_ProjectFieldsMapping__c> ListToDel=new list<Jira_ProjectFieldsMapping__c>();
        list<Jira_ProjectFieldsMapping__c> ListToupdate=new list<Jira_ProjectFieldsMapping__c>();
        String index =ApexPages.currentPage().getParameters().get('indexop');
        list<string> optodel=index.split('_');
        
        indextodel=Integer.valueOf(optodel[1]);
        indextodelfrom=String.valueOf(optodel[2]);
        Jira_ProjectFieldsMapping__c jirafieldmapping=new Jira_ProjectFieldsMapping__c();
        if(optodel[0]=='op'){
            jirafieldmapping = ProjectFieldmaps.get(indextodelfrom).OpJiraFieldList.get(indextodel);
        }
        ListToDel.add(jirafieldmapping);
        try{
            if(schema.sObjectType.Jira_ProjectFieldsMapping__c.isDeletable()){
                delete ListToDel;
            }
        }catch(Exception ex){
            String Error=System.label.Cause_Label +ex.getCause()+'\n'+System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('FieldsSettingController',null, null, null,null,null, null , null, null, 'removeJiraSfField', Error);
            
        }try{
            if(schema.sObjectType.Jira_ProjectFieldsMapping__c.isUpdateable()){
                update ListToupdate;
            }
        }catch(Exception ex){
            String Error=System.label.Cause_Label +ex.getCause()+'\n'+System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('FieldsSettingController',null, null, null,null,null, null , null, null, 'removeJiraSfField', Error);
            
        }
        // fillsfJiraFieldsWrapper();
        
        
        return null;
    }
    Public Pagereference GetUserList(){
        userlistbyname = new List<SelectOption>();  
        
        if(usersearchtext!=null && usersearchtext!=''){
            
            list<String> SearchMeta= usersearchtext.trim().split('__');
            if(SearchMeta[0]=='EmptyUser'){
                userlistbyname = new List<SelectOption>();
            }
            if(SearchMeta[0]=='FetchUser'){
                username='';
                HttpResponse res = new HttpResponse();
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                try{
                    req = CreateJIRAWrapper.CreateRequest('/rest/api/2/user/picker?query='+SearchMeta[1], 'GET', 'application/json');
                    res = http.send(req);
                    String jsonInput;
                    jsonInput = res.getBody();   
                    
                    if(res.getStatusCode()==200 || test.isRunningTest()){
                        if(test.isRunningTest()){
                            jsonInput='{"users":[{"accountId":"5c82215b3ae6c605e332b11c","accountType":"atlassian","name":"95d4e080-1db1-44db-97c6-87307a5bc870","key":"95d4e080-1db1-44db-97c6-87307a5bc870","html":"Zylo <strong>Integration</strong> - zylo_integration@yext.com","displayName":"Zylo Integration"}],"total":2,"header":"Showing 2 of 2 matching users"}';
                        }
                        Map<String, Object> UserResponseMap = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
                        List<Object>userlist = (List<Object>)UserResponseMap.get('users');
                        if(!userlist.isEmpty()){
                            userlistbyname.add(new SelectOption('',String.valueOf(UserResponseMap.get('header'))));
                        }
                        for(Object user:userlist){
                            Map<String, Object> UserMap = (Map<String, Object>)User;
                            if(UserMap.get('displayName')!=null && UserMap.get('name')!=null ){
                                String selectval=String.valueOf(UserMap.get('displayName'))+' ('+String.valueOf(UserMap.get('name'))+')';
                                userlistbyname.add(new SelectOption(selectval,selectval));
                                UserMap.remove('html');
                                String MapVal=Json.serialize(UserMap);
                                UserMapDetails.put(selectval,MapVal);
                            }
                        }
                    }else{
                        GenerateJiraLogs.CreateLogRealTime('FieldsSettingController',req.getEndpoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(),req.getbody() , null, null, 'UserList', res.getBody());
                        
                    }
                }catch(Exception ex){
                    String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                    GenerateJiraLogs.CreateLogRealTime('FieldsSettingController',req.getEndpoint(), req.getMethod(), String.valueof(res.getstatusCode()),res.getbody(),res.getstatus(),req.getbody() , null, null, 'UserList', Error);
                    
                }
            }
        }
        
        return null; 
    }
    
}