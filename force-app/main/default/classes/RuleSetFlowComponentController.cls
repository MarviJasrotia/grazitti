public with sharing class RuleSetFlowComponentController {
    
    public List<JiraErrorLogs__c> JiraLogsToInsert;
    public List<SelectOption> allFields {get; set;}
    public String objName { get; set; }
    public List<Child_Rule_Set__c> ruleSetChildList {get; set;}
    public List<Child_Rule_Set__c> ruleSetInsertChildList;
    public Map<String,Child_Rule_Set__c> mapruleSetChild { get; set; }
    public Map<String,Child_Rule_Set__c> mapruleSetChildChange;
    Map<String, Schema.SObjectType> schemaMap=new Map<String, Schema.SObjectType>();
    public List<SelectOption> SObjectListNew{get;set;}
    set<string> MappedSfObjectList= new set<string>();
    
    public Rule_Set__c ruleSet { get; set;}
    public String ed_removefield { get; set; }
    public SObject obj { get; set; }
    
    public List<Rule_Set__c> ruleSetList { get; set; }
    public list<ViewWrapperClass> viewruleSetList{get;set;}
    public List<Rule_Set__c> editruleSetList { get; set; }
    public String cloneId { get; set; }
    public String deleteRuleSetId { get; set; }
    public String editId { get; set; }
    public Rule_Set__c editruleSet { get; set; }
    public Boolean editValidateChild;
    public List<EditwrapperClass> wrapperList { get; set; } 
    // public List<EditwrapperClass> editvalidWrapList;
    public EditwrapperClass wrapper { get; set; }
    public EditWrapperClass wrap;
    Schema.DisplayType ed_fielddataType = null;
    Map<String, Schema.SObjectField> edObjectFields = null;
    /*********** new RuleSet variables ************/
    public Boolean nw_FilterValid {get; set;}
    public Rule_Set__c newruleSet { get; set; }
    public Child_Rule_Set__c newruleSetChild { get; set; }//doubt
    public Map<String, String> disMapFieldLabelToFieldApi {get; set;}
    public ID genericObjectID{get;set;}
    public String newObjName { get; set; }
    public sObject newObj { get; set; }
    public Boolean newValidateChild;
    public List<Child_Rule_Set__c> newruleSetInsertChildList;
    public List<SelectOption> newAllFields {get; set;}
    public String nw_RemoveField { get; set; }
    public Boolean addnewFieldButton;
    Map<String, Schema.SObjectField> newObjectFields = null;
    Schema.SObjectType targetType;
    Schema.SObjectType newTargetType;
    public Boolean deleteRuleSetOnRule { get; set; }
    public List<SelectOption> projOptions;
    
    /***********new RuleSet variables End ************/
    /**************************************** Newly Added Variables *******************************************/
    public List<WrapperClass> nw_WrapperList { get; set; }
    public WrapperClass nw_Wrapper { get; set; } 
    public List<WrapperClass> nw_ValidWrapperList { get; set; }  
    public Map<String,String> nw_MapFieldToType { get; set; }  
    Schema.DisplayType nw_fielddataType = null;
    public Boolean editSection;
    public String edRetainObject;
    public Map<String,Schema.SObjectField> vRulesObjectFields; 
    public Map<String,Schema.SObjectField> vRulesChildObjectFields;
    public String finalParentQuery;
    public String onlyChildQuery;
    public String onlyParentQuery; 
    public String onlyChildQInitial;
    /*************************************Newly Added Variables End********************************************/    
    
    /**
* Constructors
*/
    public RuleSetFlowComponentController (AdminSettingController controller){
        try{
            JiraLogsToInsert = new List<JiraErrorLogs__c>();
            getProjectList();    
            listOfRules();
        }catch(Exception ex){
            String Errormsg=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            JiraLogsToInsert.add(GenerateJiraLogs.CreateJiraLog('RuleSetFlowComponentController',null, null, null, null,null, null , null, null, 'RuleSetFlowComponentController', Errormsg));
            
        }
    }
    public void initial(){
        deleteRuleSetId = null;
        cloneId = null;
        addnewFieldButton = false;
        deleteRuleSetOnRule = false;
        nw_FilterValid = false;
        ruleSetList = new List<Rule_Set__c>();
        viewruleSetList = new list<viewWrapperClass>();
        allFields = new List<SelectOption>();
        mapruleSetChild = new Map<String,Child_Rule_Set__c>();
        mapruleSetChildChange = new Map<String,Child_Rule_Set__c>(); 
        ruleSetInsertChildList = new List<Child_Rule_Set__c>();
        ruleSet = new Rule_Set__c();
        ruleSetChildList = new List<Child_Rule_Set__c>();
        editruleSetList =  new List<Rule_Set__c>();
        editruleSet = new Rule_Set__c();
        editValidateChild = false;
        wrapperList = new List<EditwrapperClass>(); 
        wrapper = new EditWrapperClass(); 
        wrap = new EditWrapperClass();
        edRetainObject = '';
        editSection = true;
        
        /****************** new RuleSet Variables Intialize ***********************/
        newruleSet = new Rule_Set__c();
        newruleSetChild = new Child_Rule_Set__c();
        newruleSetInsertChildList = new List<Child_Rule_Set__c>();
        nw_WrapperList = new List<WrapperClass>();
        nw_ValidWrapperList = new List<WrapperClass>();
        nw_Wrapper = new WrapperClass();
        newAllFields = new List<SelectOption>();
        nw_MapFieldToType = new Map<String,String>();
        disMapFieldLabelToFieldApi = new Map<String,String>();
        newValidateChild = false;
        nw_Removefield = null;
        ed_Removefield = null;
        Wrapper.isUpdateable = true;
        nw_Wrapper.isUpdateable = true;
        
        Wrapper.isRequired = false;
        nw_Wrapper.isRequired = false;
        
    }
    public String getParentQueries(){
        vRulesObjectFields = Rule_Set__c.sObjectType.getDescribe().fields.getMap();
        vRulesChildObjectFields = Child_Rule_Set__c.sObjectType.getDescribe().fields.getMap();
        String parentQuery = 'Select ';
        
        for(String field : vRulesObjectFields.keySet()){
            if(vRulesObjectFields.get(field).getDescribe().isAccessible()){
                parentQuery +=   field + ', ';
            }
        }
        
        onlyParentQuery = parentQuery;
        onlyParentQuery = onlyParentQuery.removeEnd(', ') + ' FROM Rule_Set__c ';
        return parentQuery;
    }
    public String getChildQueries(){
        String childQuery = '(Select ';
        onlyChildQInitial = 'Select ';
        for(String field : vRulesChildObjectFields.keySet()){
            if(vRulesChildObjectFields.get(field).getDescribe().isAccessible()){
                if(field =='contactemail'){
                    
                    childQuery +=   'contact.email, ';
                    onlyChildQInitial += 'contact.email, ';
                }else{                    
                    childQuery +=   field + ', ';
                    onlyChildQInitial += field + ', ';
                }
            }
        }
        childQuery = childQuery.removeEnd(', ');
        onlyChildQuery = onlyChildQInitial.removeEnd(', ') + ' from Child_Rule_Set__c ';
        
        return childQuery;
    }
    public void listOfRules(){
        
        SObjectListNew=new List<SelectOption>();
        
        schemaMap = Schema.getGlobalDescribe();
        
        if(!Jira_ProjectFieldsMapping__c.sObjectType.getDescribe().isAccessible() ){
            return;
        }
        
        for(Jira_ProjectFieldsMapping__c jpfm:[SELECT Id, Name, Salesforce_Object__c FROM Jira_ProjectFieldsMapping__c WHERE Salesforce_Object__c!=NULL]){
            if(Schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.Salesforce_Object__c.isAccessible() && (!MappedSfObjectList.contains(jpfm.Salesforce_Object__c))){
                MappedSfObjectList.add(jpfm.Salesforce_Object__c);
            }
        }
        for(String obj1 : MappedSfObjectList){
            SObjectListNew.add(new SelectOption(obj1,obj1));
        }
        
        String parentQuery=getParentQueries();
        String childQuery=getChildQueries();
        String finalChildQuery = childQuery + ' from Child_Rule_Sets__r)';
        String SNOChildQuery = childQuery + ' from Child_Rule_Sets__r ORDER BY sno__c) ';
        finalParentQuery = parentQuery + finalChildQuery + ' from Rule_Set__c '; 
        String specificParentQuery = parentQuery + SNOChildQuery + ' from Rule_Set__c ORDER BY SNO__c  limit 9500 ';
        initial();
        if( Schema.sObjectType.Child_Rule_Set__c.isAccessible() && Schema.sObjectType.Rule_Set__c.isAccessible()){
            ruleSetList = Database.Query(specificParentQuery);
            fillViewRuleSetList(ruleSetList);
            if(ruleSetList.size() > 0 && !ruleSetList.isEmpty()){
                newObjName = 'None';  
                newAllFields = new List<SelectOption>();
                if(!mapruleSetChild.isEmpty()){
                    ruleSetChildList = mapruleSetChild.values();
                }
            }
        }
        allField();       
    }
    public void fillViewRuleSetList( List<Rule_Set__c> ruleSetList){
        if(ruleSetList.size() > 0 && !ruleSetList.isEmpty()){
            for(Rule_Set__c vP: ruleSetList){
                ViewWrapperClass vwc = new ViewWrapperClass();
                vwc.ruleSet = vP;
                vwc.wrapList = new list<EditWrapperClass>();
                newObjName = vP.ruleSetObject__c;
                Map<String,Schema.SObjectField> disObjectFields = Schema.getGlobalDescribe().get(newObjName).getDescribe().fields.getMap();
                for(String field : disObjectFields.keySet())
                {
                    if(disObjectFields.get(field).getDescribe().isAccessible()   && disObjectFields.get(field).getDescribe().isFilterable() && !disObjectFields.get(field).getDescribe().isCalculated())
                    {
                        disMapFieldLabelToFieldApi.put(field,disObjectFields.get(field).getDescribe().getLabel());         
                    }
                }
                for(Child_Rule_Set__c child : vP.Child_Rule_Sets__r){
                    EditWrapperClass wrap= new EditWrapperClass();
                    wrap.fieldName = child.Field_Name__c; 
                    wrap.fieldValue = child.field_Value__c;
                    wrap.filter = child.filter__c;
                    
                    wrap.objectName = child.object_Name__c;
                    wrap.dataType = child.dataType__c;
                    wrap.vPlayId = child.Rule_Set__c;
                    wrap.sno = Integer.valueof(child.sno__c);
                    wrap.childId = child.Id;
                    Schema.SOBjectType targetType  = Schema.getGlobalDescribe().get(child.object_Name__c);
                    if(targetType != null){
                        edobjectFields = Schema.getGlobalDescribe().get(newObjName).getDescribe().fields.getMap();
                        wrap.editWrapObj = targetType.newSObject();
                        Schema.DisplayType fielddataType  = edObjectFields.get(wrap.fieldName).getDescribe().getType(); 
                        wrap.isRequired = false;
                        if(!edObjectFields.get(wrap.fieldName).getDescribe().isNillable()){
                            wrap.isRequired = true ;
                        }
                        if(edObjectFields.get(wrap.fieldName).getDescribe().isUpdateable())
                        {
                            if(fielddataType == Schema.DisplayType.INTEGER) if(wrap.fieldValue == null || wrap.fieldValue == 'null') wrap.editWrapobj.put(wrap.fieldName,null); else{  wrap.editWrapobj.put(wrap.fieldName,Integer.valueOf(wrap.fieldValue));}
                            else if(fielddataType == Schema.DisplayType.STRING || fielddataType == Schema.DisplayType.PICKLIST || fielddataType == Schema.DisplayType.PHONE || fielddataType == Schema.DisplayType.MULTIPICKLIST || fielddataType == Schema.DisplayType.URL || fielddataType == Schema.DisplayType.REFERENCE) 
                            {
                                if(edObjectFields.get(wrap.fieldName).getDescribe().isDependentPickList())  {ed_fetchDepPickList(wrap,wrap.fieldName);}
                                else {if(wrap.fieldValue == null || wrap.fieldValue == 'null') wrap.editWrapobj.put(wrap.fieldName,null); else wrap.editWrapobj.put(wrap.fieldName,String.valueOf(wrap.fieldValue));}
                            }
                            else if(fielddataType == Schema.DisplayType.DOUBLE) if(wrap.fieldValue == null || wrap.fieldValue == 'null') wrap.editWrapobj.put(wrap.fieldName,null); else{ wrap.editWrapobj.put(wrap.fieldName,Double.valueOf(wrap.fieldValue)); }
                            else if(fielddataType == Schema.DisplayType.BOOLEAN) wrap.editWrapobj.put(wrap.fieldName,Boolean.valueOf(wrap.fieldValue));
                            else if(fielddataType == Schema.DisplayType.PERCENT) if(wrap.fieldValue == null || wrap.fieldValue == 'null') wrap.editWrapobj.put(wrap.fieldName,null); else wrap.editWrapobj.put(wrap.fieldName,Double.valueOf(wrap.fieldValue));
                            else if(fielddataType == Schema.DisplayType.CURRENCY) if(wrap.fieldValue == null || wrap.fieldValue == 'null') wrap.editWrapobj.put(wrap.fieldName,null); else wrap.editWrapobj.put(wrap.fieldName,Integer.valueOf(wrap.fieldValue));
                            else if(fielddataType == Schema.DisplayType.DATETIME){
                                
                                if(wrap.fieldValue != 'null' && wrap.fieldValue != null && wrap.fieldValue != '' ) wrap.editWrapobj.put(wrap.fieldName,DateTime.valueOf(wrap.fieldValue));
                                else wrap.editWrapobj.put(wrap.fieldName,null); 
                            } 
                            else if(fielddataType == Schema.DisplayType.DATE){  if(wrap.fieldValue != 'null' && wrap.fieldValue != null && wrap.fieldValue != '' ){ wrap.editWrapobj.put(wrap.fieldName,Date.valueOf(wrap.fieldValue)); }
                                                                              else wrap.editWrapobj.put(wrap.fieldName,null); }
                            
                            else if(fielddataType == Schema.DisplayType.TIME){  if(wrap.fieldValue != 'null' && wrap.fieldValue != null && wrap.fieldValue != '' ){
                                
                                list<String> TimeData=wrap.fieldValue.split(':');
                                Time fieldTimeValue = Time.newInstance(
                                    Integer.valueOf(TimeData[0]),
                                    Integer.valueOf(TimeData[1]),
                                    Integer.valueOf('00'),
                                    Integer.valueOf('00')) ;
                                
                                wrap.editWrapobj.put(wrap.fieldName,fieldTimeValue); 
                                
                            }
                                                                              else wrap.editWrapobj.put(wrap.fieldName,null); }
                            
                            else wrap.editWrapobj.put(wrap.fieldName,String.valueOf(wrap.fieldValue));
                            
                            wrap.isUpdateable = true;
                        }else
                        {// For Read-only fields
                            if(fielddataType == Schema.DisplayType.DATETIME){
                                String result = '';
                                if(wrap.fieldValue != '' && wrap.fieldValue != 'null' && wrap.fieldValue != null)  result = editSec_DateTimeFormat(String.valueOf(wrap.fieldValue));  
                                if(result != null) wrap.fieldValue = result;      
                                wrap.isUpdateable = false;
                            }    
                        }     
                    }
                    vwc.wrapList.add(wrap);
                    mapruleSetChild.put(child.Id,child); 
                    mapruleSetChildChange.put(child.Id,child);   
                    
                }
                viewruleSetList.add(vwc);
            }  
        }
    }
    public void allField(){
        
        nw_ValidWrapperList = new List<WrapperClass>();
        if(editruleSet.id==null){
            objName=newruleSet.RuleSetObject__c;
        }
        else{
            objName=editruleSet.RuleSetObject__c;
        }
        if(objName != null && objName.trim() != '' && objName != 'None')
        {
            deleteRuleSetOnRule = false;
            allFields = new List<Selectoption>();
            wrap.isRequired = false;
            Wrapper.isUpdateable = true;
            if(edRetainObject != editruleSet.ruleSetObject__c){ 
                editruleSet.filterLogic__c = '1';
                editruleSet.Project__c = '';
                WrapperList = new List<EditWrapperClass>();
                Schema.SObjectType targetType1;
                targetType1  = Schema.getGlobalDescribe().get(objName);
                
                if(targetType1 != null){
                    wrapper.editWrapObj = targetType1.newSObject();
                    obj = targetType1.newSObject();
                }
                editModeAddNewField();
            }
            if(editSection){
                WrapperList = new List<EditWrapperClass>();
                Wrapper = new EditWrapperClass();
                Schema.SObjectType targetType1;
                targetType1  = Schema.getGlobalDescribe().get(objName);
                
                if(targetType1 != null){
                    wrapper.editWrapObj = targetType1.newSObject();
                    obj = targetType1.newSObject();
                }
                editModeAddNewField();
            }
            wrapper.ObjectName = ObjName;
            AllFields = new List<SelectOption>();
            
            targetType  = Schema.getGlobalDescribe().get(objName);
            if(targetType != null){
                wrapper.editWrapObj = targetType.newSObject();
                obj = targetType.newSObject();
            }
            //  objField = null;
            
            
            edobjectFields = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
            allFields.add(new SelectOption('None',System.label.nonelabel2));
            if(!edobjectFields.isEmpty()){
                
                for(String field : edobjectFields.keySet()){
                    
                    if(edobjectFields.get(field).getDescribe().isAccessible() && edobjectFields.get(field).getDescribe().isFilterable() && !edobjectFields.get(field).getDescribe().isCalculated())
                    {
                        Schema.DisplayType fielddataType  = edobjectFields.get(field).getDescribe().getType();
                        if(fielddataType != Schema.DisplayType.ID)
                        {
                            if(field != 'isDeleted' && field != 'CreatedById'    && field != 'LastModifiedById'  && field != 'SystemModstamp' && field != 'ownerId' && field != 'masterRecordId'){
                                allFields.add(new SelectOption(field,edobjectFields.get(field).getDescribe().getLabel()));
                            }   
                        }
                    }
                }
            }
            allFields.sort();
            ruleSetChildList = new List<Child_Rule_Set__c>(); 
            ruleSetChildList.addAll(mapruleSetChildChange.values()); 
            
        }
        /***************************************** For New RuleSet ***********************************************/ 
        newObjName=newruleSet.RuleSetObject__c; 
        if(newObjName != null && newObjName.trim() != '' && newObjName != 'None')
        {
            
            newruleSet = new Rule_Set__c();
            newruleSet.filterLogic__c  = String.valueOf(1);
            nw_WrapperList = new List<WrapperClass>();
            nw_Wrapper = new WrapperClass();
            nw_wrapper.ObjectName = newObjName;
            newAllFields = new List<SelectOption>();
            newTargetType  = Schema.getGlobalDescribe().get(newObjName);
            nw_wrapper.isRequired = false;
            nw_wrapper.isUpdateable = true;
            if(newTargetType != null){
                newObj = newTargetType.newSObject();    
                nw_wrapper.wrapObj = newObj;            
            }
            
            if(Schema.getGlobalDescribe().get(newObjName).getDescribe().isAccessible())
            {
                newObjectFields = Schema.getGlobalDescribe().get(newObjName).getDescribe().fields.getMap();
                
                newAllFields.add(new SelectOption('None',System.label.nonelabel2));
                List<String> controllingField  = new List<String>();
                List<String> dependentField = new List<String>();
                if(!newObjectFields.isEmpty())
                {
                    Integer i=0;
                    
                    for(String field : newObjectFields.keySet())
                    {
                        if(newObjectFields.get(field).getDescribe().isAccessible()   
                           && newObjectFields.get(field).getDescribe().isFilterable() 
                           && !newObjectFields.get(field).getDescribe().isCalculated() )
                        {
                            Schema.DisplayType fielddataType  = newObjectFields.get(field).getDescribe().getType();
                            if(fielddataType != Schema.DisplayType.ID )
                            {
                                if(field != 'isDeleted' && field != 'CreatedById'    && field != 'LastModifiedById'  && field != 'SystemModstamp' && field != 'ownerId'  && field != 'masterRecordId' )
                                {
                                    
                                    newAllFields.add(new SelectOption(field,newObjectFields.get(field).getDescribe().getLabel()));
                                    // newMapFieldLabelToFieldApi.put(field,newObjectFields.get(field).getDescribe().getLabel());
                                    //disMapFieldLabelToFieldApi.put(field,newObjectFields.get(field).getDescribe().getLabel());
                                    nw_MapFieldToType.put(field,String.valueOf(fielddataType));
                                    if(newObjectFields.get(field).getDescribe().isDependentPickList()){ 
                                        //nw_mapFieldToContrlFld.put(field,String.valueOf(newObjectFields.get(field).getDescribe().getController()));
                                    }
                                    
                                }
                                
                            }
                        }  
                        
                    }
                    
                }
                if(newAllFields.size()>0) newAllFields.sort();
                addNewField();
            }    
            
        }
        
    }
    
    
    public List<SelectOption> getProjectList(){
        
        projOptions = new List<SelectOption>();
        List<Jira_Project__c> projectSetting =new List<Jira_Project__c>(); 
        if(Jira_Project__c.sObjectType.getDescribe().isAccessible()){
            projectSetting=[select id,Name,ProjectKey__c,ProjectId__c,IssueType__c,DefaultIssueType__c from Jira_Project__c LIMIT 1000];
        }
        projOptions.add(new SelectOption('Null',System.label.nonelabel2));
        for(Jira_Project__c project : projectSetting){
            if(Schema.sObjectType.Jira_Project__c.fields.ProjectKey__c.isAccessible() && Schema.sObjectType.Jira_Project__c.fields.Name.isAccessible()){
                projOptions.add(new SelectOption(project.ProjectKey__c, project.Name));
            }
        }
        return projOptions;
    }
    
    public void newLoopRenderingSpecificField(){ 
        try{
            String isSelectedFieldUpdatable = ApexPages.currentPage().getParameters().get('newLoopRenderingSpecificField');
            if(isSelectedFieldUpdatable != 'None' && isSelectedFieldUpdatable != null)
            {
                List<String> splitData = new List<String>();
                splitData = isSelectedFieldUpdatable.split(' ');
                if(nw_wrapperList.size()>0)
                {
                    if(splitData.get(0).trim() != null && splitData.get(0) != 'None' && splitData.get(0).trim() != ''){
                        for(WrapperClass wrap: nw_wrapperList){
                            if(String.valueof(wrap.sno) == splitData.get(1)){
                                wrap.isRequired = false;
                                wrap.dataType = String.valueOf(newObjectFields.get(splitData.get(0)).getDescribe().getType());
                                if(!newObjectFields.get(splitData.get(0)).getDescribe().isNillable()){
                                    wrap.isRequired = true ;
                                }
                                if(!newObjectFields.get(splitData.get(0)).getDescribe().isupdateable()){ // Read-Only
                                    wrap.isUpdateable = false;
                                    
                                    wrap.fieldName = splitData.get(0);
                                    wrap.fieldValue = '';
                                    
                                }
                                else
                                { // Updateable
                                    wrap.isUpdateable = true;
                                    wrap.fieldName = splitData.get(0);
                                    wrap.wrapObj.clear();
                                    if(newObjectFields.get(splitData.get(0)).getDescribe().isDependentPickList())
                                    {//Dependent PickList
                                        nw_fetchDepPickList(wrap,splitData.get(0));
                                    }  
                                }
                                
                            }
                        }
                    }        
                }
                
            }
        }catch(Exception ex){ 
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('RuleSetFlowComponentController',null, null, null,null,null, null , null, null, 'newLoopRenderingSpecificField', Error);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage())); 
        }
    }
    
    
    public void ed_LoopRenderingSpecificField(){
        try{
            String isSelectedFieldUpdatable = ApexPages.currentPage().getParameters().get('ed_LoopRenderingSpecificField');
            if(isSelectedFieldUpdatable != 'None' && isSelectedFieldUpdatable != null)
            {
                List<String> splitData = new List<String>();
                splitData = isSelectedFieldUpdatable.split(' ');
                if(wrapperList.size()>0)
                {
                    if(splitData.get(0).trim() != null && splitData.get(0) != 'None'){
                        for(EditWrapperClass wrap: wrapperList){
                            if(String.valueof(wrap.sno) == splitData.get(1)){
                                wrap.isRequired = false;
                                wrap.dataType = String.valueOf(edObjectFields.get(splitData.get(0)).getDescribe().getType());
                                if(!edObjectFields.get(splitData.get(0)).getDescribe().isNillable()){
                                    wrap.isRequired = true ;
                                }
                                if(!edObjectFields.get(splitData.get(0)).getDescribe().isupdateable()){ wrap.isUpdateable = false; wrap.fieldName = splitData.get(0);  wrap.fieldValue = '';}
                                else {wrap.isUpdateable = true; wrap.fieldName = splitData.get(0); wrap.editWrapObj.clear();
                                      if(edObjectFields.get(splitData.get(0)).getDescribe().isDependentPickList())
                                      {
                                          ed_fetchDepPickList(wrap,splitData.get(0));  
                                      }
                                     }
                                
                            }
                        }
                    }   
                }
                
            }
        }catch(Exception ex){ 
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('RuleSetFlowComponentController',null, null, null,null,null, null , null, null, 'ed_LoopRenderingSpecificField', Error);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage()));
        }            
    }
    /**
*    For getting the picklist values for dependent picklist
*/
    public void ed_fetchDepPickList(EditWrapperClass wrap, String field){
        wrap.dependentPickList = new List<SelectOPtion>();
        
        List<Schema.PicklistEntry> ple = new List<Schema.PicklistEntry>();
        ple = edObjectFields.get(field).getDescribe().getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            wrap.dependentPickList.add(new SelectOption( f.getValue(),f.getLabel()));
            wrap.dependentPickList.add(new SelectOption('None',System.label.nonelabel2));
        }  
    }
    public void nw_fetchDepPickList(WrapperClass wrap, String field){
        wrap.dependentPickList = new List<SelectOPtion>();
        wrap.dependentPickList.add(new SelectOption('None',System.label.nonelabel2));
        List<Schema.PicklistEntry> ple = new List<Schema.PicklistEntry>();
        ple = newObjectFields.get(field).getDescribe().getPicklistValues();
        for( Schema.PicklistEntry f : ple)
        {
            wrap.dependentPickList.add(new SelectOption( f.getValue(),f.getLabel()));
        }  
    }
    
    public PageReference refresh(){
        PageReference page = new PageReference('/apex/AdminSetting');
        page.setRedirect(true);
        return page;
    }
    public PageReference ed_deleteField(){
        try{
            if( (ed_removefield !=null || ed_removefield != '') )
            {
                List<Child_Rule_Set__c> deleteChildList = new List<Child_Rule_Set__c>();
                List<String> deleteChildId = new List<String>();
                String sno;
                Boolean shouldBreak = false;
                ruleSetChildList = new List<Child_Rule_Set__c>();
                nw_FilterValid = false;
                if(wrapperList.size()>0)
                {
                    
                    for(Integer i=0; i< wrapperList.size(); i++)
                    {
                        if(String.valueof(wrapperList[i].sno) == ed_removeField)
                        {    
                            
                            PageReference p = deleteFilterCheck(ed_removeField);
                            if(p == null)
                            {
                                if(!nw_FilterValid)
                                {
                                    return null;
                                }
                                
                                shouldBreak = true;
                                break;
                            }
                            
                        }        
                    }
                    
                }
                
                if(nw_FilterValid)
                {
                    
                    List<String> nullSNO = new List<String>();
                    for(EditWrapperClass wr : wrapperList){
                        if(wr.fieldName == 'None' || wr.fieldName == null){
                            nullSNO.add(String.valueof(wr.sno));
                        }
                    }
                    for(String str : nullSNO){
                        if(String.valueOf(editruleSet.FilterLogic__c).indexOf(str)>-1){
                            editruleSet.FilterLogic__c = editruleSet.FilterLogic__c.replaceAll(str,'');
                        }
                    }
                    INteger childToremove ;
                    if(wrapperList.size()>0)
                    {
                        if(wrapperList.size() == 1 )
                        {
                            for(EditWrapperClass wrap : wrapperList){
                                if(wrap.fieldName != 'None' && wrap.fieldName != '' && wrap.fieldName != null){
                                    deleteRuleSetOnRule = true;
                                    return null;
                                }
                            }
                        }
                        for(Integer i=0; i< wrapperList.size(); i++)
                        {
                            if(String.valueof(wrapperList[i].sno) == ed_removeField)
                            {
                                
                                if(wrapperList[i].childId != null)
                                {
                                    deleteChildId.add(String.valueOf(wrapperList[i].childId));
                                    
                                }
                                wrapperList.remove(i); 
                                childToremove = i;
                            } 
                            
                        }
                        
                        
                    }   
                    List<EditWrapperClass> sortWrapList = new List<EditWrapperClass>();
                    for(Integer i=0; i< wrapperList.size(); i++)
                    {
                        if(wrapperList[i].FieldName != 'None' && wrapperList[i].FieldName != null)
                        {
                            EditWrapperClass wrap= new EditWrapperClass();
                            
                            wrap.sno = i+1;
                            wrap.ObjectName = wrapperList[i].objectName;
                            wrap.FieldName = wrapperList[i].FieldName ;
                            wrap.FieldValue = wrapperList[i].FieldValue ;
                            wrap.filter= wrapperList[i].filter;
                            
                            wrap.dataType = String.valueOf(edObjectFields.get(wrap.fieldName).getDescribe().getType());
                            wrap.isRequired = false;
                            if(!edObjectFields.get(wrap.fieldName).getDescribe().isNillable()){
                                wrap.isRequired = true ;
                            }
                            if(edObjectFields.get(wrap.FieldName).getDescribe().isupdateable()) wrap.isUpdateable = true;
                            else wrap.isUpdateable = false;
                            if(edObjectFields.get(wrap.fieldName).getDescribe().isDependentPickList()) {ed_fetchDepPickList(wrap,wrap.fieldName);}
                            wrap.editWrapObj = wrapperList[i].editWrapObj;
                            wrap.vPlayId = editruleSet.Id; 
                            
                            if(wrapperList[i].childId != null){
                                wrap.childId = wrapperList[i].childId;
                            }
                            sortWrapList.add(wrap);
                        }
                    }wrapperList = new List<EditWrapperClass>();
                    wrapperList.addAll(sortWrapList);
                    
                    
                    List<Child_Rule_Set__c> updateChildList = new List<Child_Rule_Set__c>();
                    for(EditWrapperClass ch : wrapperList)
                    {
                        Child_Rule_Set__c child = new  Child_Rule_Set__c();
                        child.Field_Name__c  = ch.fieldName == 'contactemail' ? 'contactemail': ch.fieldName;
                        child.field_value__c  = ch.fieldValue;
                        child.filter__c  = ch.filter;
                        child.sno__c = String.valueof(ch.sno);
                        child.object_Name__c  = ch.objectName;
                        child.Rule_Set__c = ch.vPlayId ;
                        child.dataType__C = ch.dataType;
                        if(ch.childID != null){
                            child.Id = ch.childID;
                        }
                        child.dataType__c = ch.dataType; 
                        updateChildList.add(child);                    
                    }
                    
                    String filterResult = filterLogicUtility.updateFilter(String.valueOf(editruleSet.filterLogic__c),Integer.valueOf(ed_removeField));
                    if(filterResult != null) editruleSet.filterLogic__c = filterResult;
                    //nw_wrapperList = new List<WrapperClass>();
                    filterLogic(String.valueOf(editruleSet.filterLogic__c));
                    if(wrapperList.isEmpty()){
                        editModeAddNewField();
                    }
                    return null;
                }             
            } 
        }catch(Exception ex){
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('RuleSetFlowComponentController',null, null, null,null,null, null , null, null, 'ed_deleteField', Error);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage())); return null;
        }
        return null;
    }
    
    
    public pageReference deleteRuleSetOnRule(){
        try{
            if(editruleSet.Id != null)
            {
                List<Rule_Set__c> vPlays = new List<Rule_Set__c>();  
                Id RuleId = editruleSet.Id; 
                if(Schema.sObjectType.Rule_Set__c.isAccessible() && Schema.sObjectType.Rule_Set__c.fields.Id.isAccessible()){
                    vPlays = [Select Id from Rule_Set__c where ID =: RuleId LIMIT 1];                
                }
                if(vPlays.size() > 0){
                    if (Rule_Set__c.sObjectType.getDescribe().isAccessible() && Rule_Set__c.sObjectType.getDescribe().isDeletable()) { 
                        database.delete(vPlays);
                    }
                }            
                
                
                if(wrapperList.size()>0)
                {
                    EditWrapperClass wrap = wrapperList.get(0);
                    if(wrap.ChildID!= null){ 
                        List<Child_Rule_Set__c> childs = new List<Child_Rule_Set__c>();
                        ID tempRuleId = wrap.childId;
                        if(Schema.sObjectType.Child_Rule_Set__c.isAccessible() && Schema.sObjectType.Child_Rule_Set__c.fields.Id.isAccessible()){
                            childs = [Select Id from Child_Rule_Set__c where Id =: tempRuleId LIMIT 1];
                        }
                        
                        if(childs.size() > 0){
                            if (Child_Rule_Set__c.sObjectType.getDescribe().isAccessible() && Child_Rule_Set__c.sObjectType.getDescribe().isDeletable()) { 
                                Database.delete(childs);
                            }
                        }
                        
                    }
                    wrapperList.remove(0) ; 
                }
                
                PageReference page = new PageReference('/apex/AdminSetting');
                page.setRedirect(true);
                return page;
            }
        }catch(Exception ex){
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('RuleSetFlowComponentController',null, null, null,null,null, null , null, null, 'deleteRuleSetOnRule', Error);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage()));  
        }
        
        return null;   
    }
    public PageReference deleteFilterCheck(String sno){
        try
        {
            if(editruleSet.filterLogic__c != null && editruleSet.filterLogic__c.trim().length()>0)
            {
                String filter = editruleSet.filterLogic__c;
                if(editruleSet.filterLogic__c.indexOf(sno)>-1){
                    nw_FilterValid = false;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label1 +sno+ System.label.RuleSetFlowComponentController_Label2));    
                    return null;
                }else{ 
                    nw_FilterValid = true;
                    
                } 
            }else{ nw_FilterValid =true; }
        }catch(Exception ex)
        {
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('RuleSetFlowComponentController',null, null, null,null,null, null , null, null, 'deleteFilterCheck', Error);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage())); 
        }      
        return null;
    }
    public void nw_deleteField(){
        try{
            nw_validWrapperList = new List<WrapperClass>();
            
            if( (nw_removeField !=null || nw_removeField != '') ){
                
                
                for(Integer i=0; i<nw_wrapperList.size(); i++)
                {
                    if(String.valueof(nw_wrapperList[i].sno) == nw_removeField){
                        nw_wrapperList.remove(i);
                        
                    }
                }
                for(Integer i=0; i< nw_wrapperList.size(); i++)
                {
                    if(nw_wrapperList[i].FieldName != 'None' && nw_wrapperList[i].FieldName != null){
                        WrapperClass wrap= new WrapperClass();
                        wrap.sno = i+1; 
                        wrap.ObjectName = nw_wrapperList[i].objectName;
                        wrap.FieldName = nw_wrapperList[i].FieldName ;
                        wrap.FieldValue = nw_wrapperList[i].FieldValue ;
                        wrap.filter= nw_wrapperList[i].filter;
                        wrap.dataType = nw_wrapperList[i].dataType;
                        wrap.Wrapobj = nw_wrapperList[i].Wrapobj;
                        wrap.isRequired = false;
                        if(!newObjectFields.get(wrap.fieldName).getDescribe().isNillable()){
                            wrap.isRequired = true ;
                        }
                        if(newObjectFields.get(wrap.FieldName).getDescribe().isupdateable()) wrap.isUpdateable = true;
                        else wrap.isUpdateable = false;
                        if(newObjectFields.get(wrap.FieldName).getDescribe().isDependentPickList()){nw_fetchDepPickList(wrap,wrap.fieldName);}
                        nw_validWrapperList.add(wrap);
                    }    
                }
                
                nw_wrapperList = new List<wrapperClass>();
                nw_wrapperList.addAll(nw_validWrapperList); 
                if(nw_wrapperList.isEmpty()){
                    addNewField();
                }                
            }
        }catch(Exception ex){
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('RuleSetFlowComponentController',null, null, null,null,null, null , null, null, 'nw_deleteField', Error);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage())); 
            
        }
        
    }
    public PageReference addNewField(){
        
        if(newValidateChild()){
            if(nw_wrapperList.size()>0)
            {
                
                for(Integer i=0; i<nw_wrapperList.size(); i++)
                {
                    if(nw_wrapperList[i].fieldName == null)
                    {
                        nw_wrapperList.remove(i);
                        
                    }
                }
                
            }
            addnewFieldButton = true;
            if(nw_WrapperList.size() < 5){
                
                WrapperClass wrap = new WrapperClass();
                if(nw_WrapperList != null && nw_WrapperList.size() > 0)
                {
                    wrap.sno= nw_WrapperList.size()+1;
                }
                else
                {
                    wrap.sno = 1;
                }
                wrap.objectName = newobjName;
                wrap.WrapObj = newObj.clone(false,true,false,false);
                wrap.isrequired = false;
                wrap.isUpdateable = true;
                nw_wrapperList.add(wrap);
            }
            
        }
        return null; 
        
        return null;   
    }
    public Boolean  newValidateChild(){
        if(nw_wrapperList.size() > 0 && nw_wrapperList != null)
        {
            
            for(WrapperClass wrap : nw_wrapperList)
            {
                newValidateChild = false;
                String description;
                newruleSet.ruleSetObject__c = newObjName;
                if(wrap.FieldName!= 'None' && wrap.FieldName!= null)
                {  
                    wrap.isRequired = false;
                    
                    if(!newObjectFields.get(wrap.fieldName).getDescribe().isNillable()){
                        wrap.isRequired = true ;
                    }
                    if(newObjectFields.get(wrap.FieldName).getDescribe().isupdateable())
                    {                          
                        nw_fielddataType = newObjectFields.get(wrap.fieldName).getDescribe().getType();
                        if(nw_fielddataType == Schema.DisplayType.DateTime){ if(wrap.wrapObj.get(wrap.FieldName) != '' && wrap.wrapObj.get(wrap.FieldName) != null) wrap.fieldValue = DateTime.valueOf(wrap.wrapObj.get(wrap.FieldName)).format('yyyy-MM-dd hh:mm:ss.sss'); }
                        else if(newObjectFields.get(wrap.fieldName).getDescribe().isDependentPickList()) {}
                        else if(wrap.wrapObj.get(wrap.FieldName) != ''  && wrap.wrapObj.get(wrap.FieldName) != null){
                            
                            wrap.fieldValue = String.valueOf(wrap.wrapObj.get(wrap.FieldName)); 
                        }
                        wrap.dataType = String.valueOf(nw_fielddataType);
                        wrap.isUpdateable = true;
                    }  
                    else{
                        nw_fielddataType = newObjectFields.get(wrap.fieldName).getDescribe().getType();
                        wrap.dataType = String.valueOf(nw_fielddataType);
                        wrap.isUpdateable = false;
                    }
                    
                    if(!newObjectFields.isEmpty()){
                        
                    }     
                    /*-------  if(newruleSet.description__c.length() == 0 ){
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Description Name can\'t be left blank.'));
return false;
}   
else if(newruleSet.description__c.length() > 0 ){
if(newruleSet.description__c.length() > 200)
{
ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'You can\'t add more than 200 characters in Description.'));
return false;    
}
} ----*/
                    if(newruleSet.ruleSetObject__c == null ||  newruleSet.ruleSetObject__c == 'None' ){ ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label3)); return false;}
                    
                    if(wrap.filter == null &&  wrap.fieldName != 'None' ){ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label4));  return false; }
                    
                    else if(wrap.filter != null && wrap.filter == 'None'){ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label5)); return false;} 
                    else
                    {
                        try{
                            if(!newobjectfields.isEmpty())
                            { 
                                String regex = '';
                                String text  = '';
                                if(nw_fielddataType== Schema.DisplayType.INTEGER)
                                {
                                    if( wrap.fieldValue != '' && !wrap.fieldValue.isNumeric()){
                                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label6));                              
                                        return false;
                                    }
                                    if(wrap.filter != 'greater than' && wrap.filter != 'less than' && wrap.filter != 'greater or equal' && wrap.filter != 'less or equal' && wrap.filter != 'equals' && wrap.filter != 'not equal to'  ) 
                                    {      
                                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label7)); 
                                        return false; 
                                    }     
                                }
                                if(nw_fielddataType== Schema.DisplayType.Double)
                                {
                                    
                                    if( wrap.fieldValue != '' ) Double dou = Double.valueOf(wrap.fieldValue);
                                    if(wrap.filter != 'greater than' && wrap.filter != 'less than' && wrap.filter != 'greater or equal' && wrap.filter != 'less or equal' && wrap.filter != 'equals' && wrap.filter != 'not equal to'  ) 
                                    {      
                                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label7)); 
                                        return false; 
                                    }                               
                                }
                                if(nw_fielddataType== Schema.DisplayType.PERCENT)
                                {
                                    
                                    
                                    if( wrap.fieldValue != '' ) Double dou = Double.valueOf(wrap.fieldValue);
                                    if(wrap.filter != 'greater than' && wrap.filter != 'less than' && wrap.filter != 'greater or equal' && wrap.filter != 'less or equal' && wrap.filter != 'equals' && wrap.filter != 'not equal to'  ) 
                                    {      
                                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label7)); 
                                        return false; 
                                    }                               
                                }
                                if(nw_fielddataType== Schema.DisplayType.BOOLEAN)
                                {
                                    if(String.valueOf(wrap.fieldValue) == '') wrap.fieldValue = 'false';
                                    if(String.valueOf(wrap.fieldValue).toLowercase() != 'true' && String.valueOf(wrap.fieldValue).toLowercase()  != 'false') 
                                    {
                                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,System.label.RuleSetFlowComponentController_Label8));                              
                                        return false;
                                    } 
                                } 
                                if(nw_fielddataType== Schema.DisplayType.CURRENCY){
                                    
                                }
                                if(nw_fielddataType== Schema.DisplayType.PHONE)
                                {
                                    
                                }
                                if(nw_fielddataType== Schema.DisplayType.TEXTAREA)
                                {
                                    
                                }
                                
                                if( nw_fielddataType == Schema.DisplayType.DATE)
                                {
                                    if(!newobjectfields.get(wrap.FieldName).getDescribe().isupdateable()) {    
                                        if( wrap.fieldValue != ''){
                                            Pattern MyPattern = Pattern.compile('(0?[1-9]|1[012])/(0?[1-9]|[12][0-9]|3[01])/((19|20)\\d\\d)');
                                            Matcher MyMatcher = MyPattern.matcher(wrap.fieldValue);
                                            
                                            if(!MyMatcher.matches()){
                                                ErrorMessage(System.label.RuleSetFlowComponentController_Label9);
                                                return false;
                                            }  
                                        }
                                    }              
                                }
                                if( nw_fielddataType == Schema.DisplayType.DATETIME)
                                {    
                                    if(!newobjectfields.get(wrap.FieldName).getDescribe().isupdateable()) { 
                                        if(wrap.fieldValue != ''){
                                            Pattern MyPattern = Pattern.compile('(0?[1-9]|1[012])/(0?[1-9]|[12][0-9]|3[01])/((19|20)\\d\\d) ([0-1]?[0-9]|[2][0-3]):([0-5][0-9]) (AM|PM)');
                                            Matcher MyMatcher = MyPattern.matcher(wrap.fieldValue);
                                            
                                            if(!MyMatcher.matches()){
                                                ErrorMessage(System.label.RuleSetFlowComponentController_Label10);
                                                return false;
                                            }              
                                        }
                                    }
                                }
                                
                                
                                if(nw_fielddataType == Schema.DisplayType.Boolean)
                                {
                                    if(wrap.filter != 'equals' && wrap.filter != 'not equal to'){ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label11)); return false;}
                                    
                                }
                                if(nw_fielddataType== Schema.DisplayType.REFERENCE)
                                {
                                    if(wrap.filter != 'equals' && wrap.filter != 'not equal to' &&  wrap.filter != 'starts with'){ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label12));  return false;  }
                                    
                                }
                                if(nw_fielddataType== Schema.DisplayType.MultiPicklist)
                                {
                                    if(wrap.filter != 'equals' && wrap.filter != 'not equal to' &&  wrap.filter != 'includes' &&  wrap.filter != 'excludes'){ ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label13));    return false;          }
                                    
                                }
                                if(nw_fielddataType== Schema.DisplayType.DATE || nw_fielddataType== Schema.DisplayType.DATETIME || nw_fielddataType== Schema.DisplayType.BOOLEAN || nw_fielddataType== Schema.DisplayType.CURRENCY  || nw_fielddataType== Schema.DisplayType.INTEGER || nw_fielddataType== Schema.DisplayType.DOUBLE ||nw_fielddataType== Schema.DisplayType.PERCENT)
                                {
                                    if(wrap.filter == 'contains' || wrap.filter == 'does not contain' ||  wrap.filter == 'starts with' || wrap.filter == 'includes' || wrap.filter == 'excludes'){ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label14));    return false; }
                                    
                                }
                                if(wrap.filter == 'includes' || wrap.filter == 'excludes'){
                                    if(nw_fielddataType != Schema.DisplayType.MultiPicklist) {ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label15)); return false;  }
                                    
                                }    
                                newValidateChild = true;
                                
                                newTargetType  = Schema.getGlobalDescribe().get(newObjName);
                                if(newTargetType != null){
                                    newObj = newTargetType.newSObject();    
                                }
                            }
                        }catch(Exception ex){
                            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage())); 
                            return false;
                        }
                        
                    }
                }
                else{
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label16)); 
                    return  false;
                }       
            }
        }
        else newValidateChild = true;   
        return newValidateChild;
    }
    public void newSave(){
        
        
        try{
            wrapperList = new List<EditWrapperClass>();
            if( newruleSet.description__c.trim().length() == 0)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label17));
                return;
            }
            if (newruleSet.SNO__c == 0){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label18));
                return;             
            }
            
            if(newruleSet.Project__c == null || newruleSet.Project__c.trim() == '' || newruleSet.Project__c.trim() == 'null'){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label19));
                return ;
            }else {
                for(Integer i=0; i<nw_wrapperList.size(); i++)
                {
                    if(nw_wrapperList[i].fieldName == null || nw_wrapperList[i].fieldName == 'None')
                    {
                        //nw_wrapperList.remove(i);
                    }
                }
                
                nw_wrapper = new  wrapperClass();
                if(nw_WrapperList.size() > 0 )
                {
                    // Add the Logic for validate in Loop
                    PageReference p= null;
                    if(!newValidateChild())
                    {
                        return; 
                    }
                    if(newruleSet.filterLogic__c.length() > 0){
                        addnewFieldButton =true;
                        wrapperList = new List<EditWrapperClass>();
                        p = filterLogic(newruleSet.filterLogic__c);
                        
                        if(p == null)
                        {
                            if(!nw_FilterValid){
                                return;
                            }
                            else if(nw_FilterValid)
                            {
                                
                                newruleSet.filterLogic__c =  newruleSet.filterLogic__c.toUpperCase().rePlaceAll(' ','').replaceAll('  ','');
                            }
                        }
                    }else
                    {
                        String filterLogic ='';
                        if(newruleSet.filterLogic__c.trim().length() == 0)
                        {
                            
                            if(nw_WrapperList.size()>=2){
                                for(Integer i=0; i<nw_WrapperList.size(); i++){
                                    filterLogic += (i+1);
                                    if(i == nw_WrapperList.size()-1) break;
                                    filterLogic += 'AND';
                                }
                            }
                            else if(nw_WrapperList.size() == 1) {
                                filterLogic = String.valueOf(1);        
                            }
                        }
                        newruleSet.filterLogic__c = filterLogic;
                        
                    }
                    if( newruleSet.Project__c.length() ==0 && newruleSet.Project__c!= null ){ ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label19)); return ;}
                    
                    else if(newruleSet.Project__c != null ){
                        
                        if(newruleSet.Project__c.trim() == null || newruleSet.Project__c.trim() == '' || newruleSet.Project__c.trim() == 'null') ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label19));// return null;}    
                        else if(newruleSet.Project__c != null && newruleSet.Project__c.trim() != null ) {
                            if (!(Rule_Set__c.sObjectType.getDescribe().isCreateable() && Schema.sObjectType.Rule_Set__c.fields.filterLogic__c.isCreateable() && Schema.sObjectType.Rule_Set__c.fields.ruleSetObject__c.isCreateable() ) ){
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, System.label.RuleSetFlowComponentController_Label20));
                            } else {
                                integer numbr = Integer.valueOf(newruleSet.SNO__c);
                                List<Rule_Set__c> serNumberList = new List<Rule_Set__c>();
                                if(Rule_Set__c.sObjectType.getDescribe().isAccessible()){
                                    for(Rule_Set__c sr : [select id,SNO__c from Rule_Set__c where SNO__c > =: numbr]){
                                        sr.SNO__c += 1;
                                        serNumberList.add(sr);
                                    }
                                }
                                if(schema.sObjectType.Rule_Set__c.isUpdateable()){
                                    update serNumberList;
                                }
                                
                                if(schema.sObjectType.Rule_Set__c.isCreateable()){
                                    insert newruleSet;    
                                }
                            }
                            
                            
                            
                        }
                        
                        
                    }
                    
                    for( WrapperClass ch :  nw_WrapperList){
                        
                        Child_Rule_Set__c child = new Child_Rule_Set__c();
                        
                        child.Rule_Set__c = newruleSet.Id;
                        child.Field_Name__c = ch.fieldName;
                        if(newObjectFields.get(ch.FieldName).getDescribe().isupdateable())
                        {
                            nw_fielddataType = newObjectFields.get(ch.fieldName).getDescribe().getType();
                            if(nw_fielddataType == Schema.DisplayType.DateTime){
                                
                                if(ch.wrapObj.get(ch.fieldName) != '' && ch.wrapObj.get(ch.fieldName) != null){ Integer hh = DateTime.valueOf(ch.wrapObj.get(ch.fieldName)).hour(); 
                                                                                                               String fieldValue = String.valueOf(DateTime.valueOf(ch.wrapObj.get(ch.fieldName)).format('yyyy-MM-dd hh:mm:ss.sss'));
                                                                                                               String result = setDateTimeFormat(fieldValue,hh);
                                                                                                               if(result != null) {ch.fieldValue =result; child.field_value__c = result;}  
                                                                                                              } else child.field_value__c = 'null'; 
                                
                            }else  if(nw_fielddataType == Schema.DisplayType.Date){
                                if(ch.wrapObj.get(ch.fieldName) != '' && ch.wrapObj.get(ch.fieldName) != null ){ child.field_value__c = String.valueOf(ch.wrapObj.get(ch.fieldName)).split(' ')[0];}
                                else{ child.field_value__c = 'null'; }
                            }
                            else if(newObjectFields.get(ch.FieldName).getDescribe().isDependentPickList()){
                                child.field_value__c = String.valueOf(ch.fieldValue);
                            }
                            else {
                                
                                if(ch.wrapObj.get(ch.fieldName) != '\'\'' && ch.wrapObj.get(ch.fieldName) != '\'\'\'\''  && ch.wrapObj.get(ch.fieldName) != '"' && ch.wrapObj.get(ch.fieldName) != '""' ){
                                    if(ch.wrapObj.get(ch.fieldName) == null){
                                        if(nw_fielddataType== Schema.DisplayType.INTEGER) child.field_value__c = 'null';
                                        else if(nw_fielddataType== Schema.DisplayType.DOUBLE) child.field_value__c = 'null';
                                        else if(nw_fielddataType== Schema.DisplayType.PERCENT) child.field_value__c = 'null';
                                        else if(nw_fielddataType== Schema.DisplayType.CURRENCY) child.field_value__c = 'null';
                                        else child.field_value__c = String.valueOf(ch.wrapObj.get(ch.fieldName));
                                        
                                    } else{ child.field_value__c = String.valueOf(ch.wrapObj.get(ch.fieldName));}
                                }
                            }
                        }else{
                            if(nw_fielddataType == Schema.DisplayType.DateTime){
                                if(ch.fieldValue != '') { String result = splitDateTimeFormat(String.valueOf(ch.fieldValue)); 
                                                         if(result != null) { 
                                                             ch.fieldValue = result; child.field_value__c = result;
                                                         }
                                                        }else{
                                                            child.field_value__c = 'null'; 
                                                        }
                            }else if(nw_fielddataType == Schema.DisplayType.Date){
                                if(child.field_value__c != '' && child.field_value__c != null) child.field_value__c = ch.fieldValue;
                                else child.field_value__c = 'null'; 
                                
                            }
                            else{
                                if(nw_fielddataType == Schema.DisplayType.BOOLEAN){  if(ch.fieldValue == '') child.field_value__c = 'False';}
                                if(ch.fieldValue != '' && ch.fieldValue != '\'\'' && ch.fieldValue != '\'\'\'\'' && ch.fieldValue != '"' && ch.fieldValue != '""') { 
                                    if(nw_fielddataType== Schema.DisplayType.INTEGER) child.field_value__c = 'null';
                                    else if(nw_fielddataType== Schema.DisplayType.DOUBLE) child.field_value__c = 'null';
                                    else if(nw_fielddataType== Schema.DisplayType.PERCENT) child.field_value__c = 'null';
                                    else if(nw_fielddataType== Schema.DisplayType.CURRENCY) child.field_value__c = 'null';
                                    else child.field_value__c = ch.fieldValue;
                                }
                                
                            }
                        }    
                        
                        child.Object_Name__c = ch.ObjectName;
                        child.filter__c = ch.Filter;
                        child.sno__c =String.valueof(ch.sno);
                        if(child.field_value__c == 'GENERIC_TEXT_FOR_REQUIRED_FIELD'){
                            child.field_value__c = '';
                        }
                        child.datatype__C = String.valueOF(nw_fielddataType);
                        newruleSetInsertChildList.add(child);
                        
                    }
                    if(newruleSetInsertChildList.size() > 0 && newruleSetInsertChildList!= null){
                        if (!(Child_Rule_Set__c.sObjectType.getDescribe().isCreateable() && 
                              Schema.sObjectType.Child_Rule_Set__c.fields.datatype__c.isCreateable() && 
                              Schema.sObjectType.Child_Rule_Set__c.fields.Field_Name__c.isCreateable() && 
                              Schema.sObjectType.Child_Rule_Set__c.fields.field_value__c.isCreateable() &&
                              Schema.sObjectType.Child_Rule_Set__c.fields.filter__c.isCreateable() &&
                              Schema.sObjectType.Child_Rule_Set__c.fields.Object_Name__c.isCreateable() &&
                              Schema.sObjectType.Child_Rule_Set__c.fields.sno__c.isCreateable() &&
                              Schema.sObjectType.Child_Rule_Set__c.fields.Rule_Set__c.isCreateable()
                             )){
                                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, System.label.RuleSetFlowComponentController_Label20));
                             } else {
                                 if(schema.sObjectType.Child_Rule_Set__c.isCreateable()){
                                     insert newruleSetInsertChildList;          
                                 }
                             }
                    }                     
                    
                } 
                else{
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label21));
                    return;
                } 
                listOfRules();
                newruleSet = new Rule_Set__c();   
                nw_wrapperList = new List<wrapperClass>();          
                addNewField();
            }
            
        }catch(Exception ex){
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('RuleSetFlowComponentController',null, null, null,null,null, null , null, null, 'newSave', Error);
            if(string.valueof(ex).contains('DUPLICATE_VALUE')){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label22));
            }
            
        }  
    }
    public String setDateTimeFormat(String fieldValue,Integer hh){
        if(hh >= 12 && hh < 24)
        { String dt = fieldValue;
         List<String> spaceSplit = new List<String>();List<String> colonSplit = new List<String>();
         spaceSplit = dt.split(' ');
         colonSplit = spaceSplit[1].split(':');
         colonSplit[0]  = String.valueOf(Integer.valueOf(colonSplit[0]));
         return (spaceSplit[0]+' '+colonSplit[0]+':'+colonSplit[1]+':00.000') ;
        }else{ 
            return (String.valueOf(DateTime.valueOf(fieldValue).format('yyyy-MM-dd hh:mm:ss.sss')));
        }
        return null;
    } 
    public String editSec_DateTimeFormat(String fieldValue){
        
        String dt = fieldValue;
        List<String> spaceSplit = new List<String>();List<String> colonSplit = new List<String>();List<String> hypenSplit = new List<String>();
        spaceSplit = dt.split(' ');
        hypenSplit = spaceSplit[0].split('-');
        colonSplit = spaceSplit[1].split(':');
        if(Integer.valueOf(colonSplit[0]) >=12 && Integer.valueOf(colonSplit[0]) < 24) 
        {
            colonSplit[0] = String.valueOf(Integer.valueOf(colonSplit[0])-12);
            colonSplit[2] = colonSplit[2].replace('00.000',' PM');
            return (hypenSplit[1]+'/'+hypenSplit[2]+'/'+hypenSplit[0]+' '+colonSplit[0]+':'+colonSplit[1]+colonSplit[2]);
        }else{ 
            colonSplit[2] = colonSplit[2].replace('00.000',' AM');
            return (hypenSplit[1]+'/'+hypenSplit[2]+'/'+hypenSplit[0]+' '+colonSplit[0]+':'+colonSplit[1]+colonSplit[2]);  
        }
        return null;    
    }
    public String splitDateTimeFormat( String fieldValue){
        List<String> spaceSplit = new LIst<String>();
        List<String> slashSplit = new List<String>();
        List<String> colonSplit =  new List<String>();
        spaceSplit = fieldValue.split(' '); 
        slashSplit = spaceSplit[0].split('/');
        if(slashSplit[0].length() == 1) slashSplit[0] = '0'+slashSplit[0];
        if(slashSplit[1].length() == 1) slashSplit[1] = '0'+slashSplit[1];
        colonSplit = spaceSplit[1].split(':');
        if(colonSplit[0].length() == 1) colonSplit[0] = '0'+colonSplit[0];
        if(colonSplit[1].length() == 1) colonSplit[1] = '0'+colonSplit[1];
        if(spaceSplit[2] == 'AM' || spaceSplit[2] == 'PM') 
        {
            if(spaceSplit[2] == 'PM') colonSplit[0]  = String.valueOf(Integer.valueOf(colonSplit[0])+12);
            spaceSplit[2] = spaceSplit[2].replace('AM',':00.000').replace('PM',':00.000');
            
        }
        fieldValue = slashSplit[2]+'-'+slashSplit[0]+'-'+slashSplit[1]+' '+colonSplit[0]+':'+colonSplit[1]+spaceSplit[2];
        return fieldValue;
    }
    public PageReference editModeAddNewField(){
        
        
        if(editValidateChild())
        {
            if(wrapperList.size()>0)
            {
                for(Integer i =0; i<wrapperList.size(); i++)
                {
                    if(wrapperList[i].fieldName == null)
                    {
                        wrapperList.remove(i);
                    }
                }
            }
            
            addnewFieldButton = false;
            if(wrapperList.size() < 5){
                
                EditWrapperClass wrap = new EditWrapperClass();
                if(WrapperList != null && WrapperList.size() > 0)
                {
                    wrap.sno = WrapperList.size()+1;
                }
                else
                {
                    wrap.sno = 1;
                }
                wrap.objectName = objName;
                wrap.editWrapObj = Obj.clone(false,true,false,false);
                wrap.isRequired = false;
                wrap.isUpdateable = true;
                wrapperList.add(wrap);
            }
            //  }        
        }
        return null;   
    }
    public Boolean editValidateChild() {
        if(wrapperList.size()>0){
            nw_FilterValid = false;
            for(EditWrapperClass wrap : wrapperList)
            {         
                editvalidateChild = false;
                String description;
                editruleSet.ruleSetObject__c = objName;
                if(wrap.FieldName != 'None' && wrap.FieldName != null)
                {
                    wrap.isRequired = false;
                    if(!edObjectFields.get(wrap.fieldName).getDescribe().isNillable()){
                        wrap.isRequired = true ;
                    }                    
                    if(edObjectFields.get(wrap.FieldName).getDescribe().isupdateable())
                    {
                        if(wrap.childId == null)
                        {      
                            ed_fielddataType = edObjectFields.get(wrap.fieldName).getDescribe().getType();
                            if(ed_fielddataType == Schema.DisplayType.DateTime){ 
                                if(wrap.editWrapObj.get(wrap.FieldName) != '' && wrap.editWrapObj.get(wrap.FieldName) != null && wrap.editWrapObj.get(wrap.FieldName) != 'null') wrap.fieldValue = DateTime.valueOf(wrap.editWrapObj.get(wrap.FieldName)).format('yyyy-MM-dd hh:mm:ss.sss'); 
                                
                            }else if(edObjectFields.get(wrap.fieldName).getDescribe().isDependentPickList()){}
                            
                            else if(wrap.editWrapObj.get(wrap.FieldName) != null && wrap.editWrapObj.get(wrap.FieldName) != '' ) {
                                wrap.fieldValue = String.valueOf(wrap.editWrapObj.get(wrap.FieldName));  
                                
                            }
                            
                        }    
                        else
                        {
                            
                            ed_fielddataType = edObjectFields.get(wrap.fieldName).getDescribe().getType();
                            if(ed_fielddataType == Schema.DisplayType.DateTime) { if(wrap.editWrapObj.get(wrap.FieldName) != '' && wrap.editWrapObj.get(wrap.FieldName) != null && wrap.editWrapObj.get(wrap.FieldName) != 'null') wrap.fieldValue = DateTime.valueOf(wrap.editWrapObj.get(wrap.FieldName)).format('yyyy-MM-dd hh:mm:ss.sss'); } 
                            else if(edObjectFields.get(wrap.fieldName).getDescribe().isDependentPickList()){ }
                            else { if(wrap.editWrapObj.get(wrap.FieldName) != '' && wrap.editWrapObj.get(wrap.FieldName) != null && wrap.editWrapObj.get(wrap.FieldName) != 'null') wrap.fieldValue = String.valueOf(wrap.editWrapObj.get(wrap.FieldName));    }
                            
                            
                        }
                        wrap.isUpdateable = true;
                    }  
                    else{
                        ed_fielddataType = edObjectFields.get(wrap.fieldName).getDescribe().getType();
                        if(ed_fielddataType == Schema.DisplayType.DateTime)
                        {
                        }
                        wrap.isUpdateable = false;
                    }
                    
                    wrap.dataType = String.valueOf(edObjectFields.get(wrap.fieldName).getDescribe().getType());
                    
                    if(editruleSet.description__c.length() == 0 ){ ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label46)); return false;}
                    
                    else if(editruleSet.description__c.length() > 0 ){
                        if(editruleSet.description__c.length() > 200) {ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label47));  return false; }
                        
                    }
                    if(editruleSet.ruleSetObject__c == null ||  editruleSet.ruleSetObject__c == 'None' ){ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label3)); return false; }
                    
                    
                    if(wrap.filter == null &&  wrap.fieldName != 'None' ){ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label4));  return false;}
                    
                    else if(wrap.filter != null && wrap.filter == 'None') {ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label5)); return false; }
                    else 
                    {
                        try{
                            if(!edObjectFields.isEmpty())
                            { 
                                String regex = '';
                                String text  = '';
                                if(ed_fielddataType== Schema.DisplayType.INTEGER)
                                {
                                    if(wrap.fieldValue != '' && wrap.fieldValue != null &&  wrap.fieldValue != 'null'   &&  !wrap.fieldValue.isNumeric()){  ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label6));  return false;}
                                    
                                    if(wrap.filter != 'greater than' && wrap.filter != 'less than' && wrap.filter != 'greater or equal' && wrap.filter != 'less or equal' && wrap.filter != 'equals' && wrap.filter != 'not equal to'  ) { ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label7)); return false;}
                                    
                                }
                                if(ed_fielddataType== Schema.DisplayType.Double)
                                {
                                    
                                    
                                    if(wrap.fieldValue != '' && wrap.fieldValue != null &&  wrap.fieldValue != 'null' ) Double dou = Double.valueOf(wrap.fieldValue);
                                    if(wrap.filter != 'greater than' && wrap.filter != 'less than' && wrap.filter != 'greater or equal' && wrap.filter != 'less or equal' && wrap.filter != 'equals' && wrap.filter != 'not equal to'  ) { ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label7)); return false;}
                                    
                                }
                                if(ed_fielddataType== Schema.DisplayType.PERCENT)
                                {
                                    if(wrap.fieldValue != '' && wrap.fieldValue != null &&  wrap.fieldValue != 'null' ) Double dou = Double.valueOf(wrap.fieldValue);
                                    if(wrap.filter != 'greater than' && wrap.filter != 'less than' && wrap.filter != 'greater or equal' && wrap.filter != 'less or equal' && wrap.filter != 'equals' && wrap.filter != 'not equal to'  ) { ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label7));  return false;}
                                    
                                }
                                if(ed_fielddataType== Schema.DisplayType.BOOLEAN)
                                {
                                    if(String.valueOf(wrap.fieldValue) == '') wrap.fieldValue = 'false';
                                    if(String.valueOf(wrap.fieldValue) != 'true' && String.valueOf(wrap.fieldValue) != 'false') 
                                    {
                                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,System.label.RuleSetFlowComponentController_Label8));                              
                                        return false;
                                    } 
                                } 
                                if(ed_fielddataType== Schema.DisplayType.CURRENCY){
                                    
                                    
                                }
                                if(ed_fielddataType== Schema.DisplayType.PHONE)
                                {
                                    
                                } 
                                if( ed_fielddataType == Schema.DisplayType.DATE)
                                {
                                    if(!edObjectFields.get(wrap.FieldName).getDescribe().isupdateable()) { 
                                        if(wrap.fieldValue != ''){
                                            Pattern MyPattern = Pattern.compile('(0?[1-9]|1[012])/(0?[1-9]|[12][0-9]|3[01])/((19|20)\\d\\d)');
                                            Matcher MyMatcher = MyPattern.matcher(wrap.fieldValue);
                                            
                                            if(!MyMatcher.matches()){
                                                ErrorMessage(System.label.RuleSetFlowComponentController_Label9);
                                                return false;
                                            }   
                                        }    
                                    }            
                                }
                                if( ed_fielddataType == Schema.DisplayType.DATETIME)
                                {    
                                    if(!edObjectFields.get(wrap.FieldName).getDescribe().isupdateable()) { 
                                        if(wrap.fieldValue != ''){
                                            Pattern MyPattern = Pattern.compile('(0?[1-9]|1[012])/(0?[1-9]|[12][0-9]|3[01])/((19|20)\\d\\d) ([0-1]?[0-9]|[2][0-3]):([0-5][0-9]) (AM|PM)');
                                            Matcher MyMatcher = MyPattern.matcher(wrap.fieldValue);
                                            
                                            if(!MyMatcher.matches()){
                                                ErrorMessage(System.label.RuleSetFlowComponentController_Label10);
                                                return false;
                                            }  
                                        }                
                                    }
                                }
                                
                                
                                if(ed_fielddataType == Schema.DisplayType.Boolean )
                                {
                                    if(wrap.filter != 'equals' && wrap.filter != 'not equal to')
                                    {
                                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label11));
                                        return false;
                                    }    
                                }
                                if(ed_fielddataType== Schema.DisplayType.REFERENCE)
                                {
                                    if(wrap.filter != 'equals' && wrap.filter != 'not equal to' &&  wrap.filter != 'starts with')
                                    {
                                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label12));           
                                        return false;    
                                    }    
                                }
                                if(ed_fielddataType== Schema.DisplayType.MultiPicklist)
                                {
                                    if(wrap.filter != 'equals' && wrap.filter != 'not equal to' &&  wrap.filter != 'includes' &&  wrap.filter != 'excludes')
                                    {
                                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label13));           
                                        return false;    
                                    }    
                                }
                                if(ed_fielddataType== Schema.DisplayType.DATE || ed_fielddataType== Schema.DisplayType.DATETIME || ed_fielddataType== Schema.DisplayType.BOOLEAN || ed_fielddataType== Schema.DisplayType.CURRENCY  || ed_fielddataType== Schema.DisplayType.INTEGER || ed_fielddataType== Schema.DisplayType.DOUBLE || ed_fielddataType== Schema.DisplayType.PERCENT)
                                {
                                    
                                    if(wrap.filter == 'contains' || wrap.filter == 'does not contain' ||  wrap.filter == 'starts with' ||  wrap.filter == 'includes' ||  wrap.filter == 'excludes')
                                    {
                                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label14));           
                                        return false;    
                                    }    
                                }
                                if(wrap.filter == 'includes' || wrap.filter == 'excludes'){
                                    if(ed_fielddataType != Schema.DisplayType.MultiPicklist)
                                    {
                                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label15));           
                                        return false; 
                                    }
                                }
                                editvalidateChild = true;
                                TargetType  = Schema.getGlobalDescribe().get(ObjName);
                                if(TargetType != null){
                                    Obj = TargetType.newSObject();    
                                }
                                
                            }
                        }catch(Exception ex){
                            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage()));
                            return false;
                        }   
                    }
                    
                }else{ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label16)); return  false;}
                
                //return editvalidateChild;
                /*******************************************/
            }   
        }else return true;
        return editvalidateChild;     
    }
    
    public PageReference CloneRuleSet(){
        try{
            if(cloneId != null && cloneId != '')
            {
                List<Rule_Set__c> vPlayList = new List<Rule_Set__c>();
                List<Rule_Set__c> vPlayClonedList = new List<Rule_Set__c>();
                String specificParentQuery = finalParentQuery + ' where Id =: cloneID LIMIT 1';
                if(Schema.sObjectType.Child_Rule_Set__c.isAccessible() && Schema.sObjectType.Rule_Set__c.isAccessible())
                    vPlayList = Database.Query(specificParentQuery);
                if(vPlayList.size()>0)
                {
                    Rule_Set__c vPlay = new Rule_Set__c();
                    for(Rule_Set__c vp: vPlayList)
                    {
                        vPLay.Project__c = vp.Project__c;
                        vPLay.description__c = vp.description__c+' - (COPY)';
                        vPLay.isActive__c = vp.isActive__c;
                        vPLay.RuleSetObject__c = vp.RuleSetObject__c;
                        vPlay.filterLogic__c = vp.filterLogic__c;
                        
                    }
                    if (!(Rule_Set__c.sObjectType.getDescribe().isCreateable() &&
                          Schema.sObjectType.Rule_Set__c.fields.Project__c.isCreateable() &&
                          Schema.sObjectType.Rule_Set__c.fields.description__c.isCreateable() &&
                          Schema.sObjectType.Rule_Set__c.fields.isActive__c.isCreateable() &&
                          Schema.sObjectType.Rule_Set__c.fields.RuleSetObject__c.isCreateable() &&
                          Schema.sObjectType.Rule_Set__c.fields.filterLogic__c.isCreateable()                    
                         )){
                             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, System.label.RuleSetFlowComponentController_Label20));
                         } else {
                             insert vPlay; 
                             
                         }
                    List<Child_Rule_Set__c> cloneVPlayChildList = new List<Child_Rule_Set__c>();
                    for(Rule_Set__c vp: vPlayList)
                    {
                        for(Child_Rule_Set__c ch : vp.Child_Rule_Sets__r)
                        {
                            Child_Rule_Set__c child = new Child_Rule_Set__c();
                            child.Field_Name__c  = ch.Field_Name__c;
                            child.field_Value__c  = ch.field_Value__c;
                            child.filter__c  = ch.filter__c ;
                            child.Object_Name__c  = ch.Object_Name__c;
                            child.Rule_Set__c = vPlay.Id;
                            //child.Rule_Set__c = ch.Rule_Set__c ;
                            child.sno__c = ch.sno__c;
                            child.dataType__c = ch.dataType__c;                           
                            cloneVPlayChildList.add(child);
                        }
                        
                    }
                    
                    if (!(Child_Rule_Set__c.sObjectType.getDescribe().isCreateable() &&
                          Schema.sObjectType.Child_Rule_Set__c.fields.dataType__c.isCreateable() && 
                          Schema.sObjectType.Child_Rule_Set__c.fields.Field_Name__c.isCreateable() && 
                          Schema.sObjectType.Child_Rule_Set__c.fields.field_Value__c.isCreateable() && 
                          Schema.sObjectType.Child_Rule_Set__c.fields.filter__c.isCreateable() && 
                          Schema.sObjectType.Child_Rule_Set__c.fields.Object_Name__c.isCreateable() && 
                          Schema.sObjectType.Child_Rule_Set__c.fields.sno__c.isCreateable() && 
                          Schema.sObjectType.Child_Rule_Set__c.fields.Rule_Set__c.isCreateable()                
                         )){
                             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, System.label.RuleSetFlowComponentController_Label20));
                         } else {
                             if(schema.sObjectType.Child_Rule_Set__c.isCreateable()){
                                 insert cloneVPlayChildList;     
                             }
                         }
                    if(vPlay.Id != null){
                        Id ruleSetId = id.valueof(vPlay.Id);
                    }
                    String specificParentQuery2 = finalParentQuery + ' WHERE ID =: ruleSetId LIMIT 1';
                    if(Schema.sObjectType.Child_Rule_Set__c.isAccessible() && Schema.sObjectType.Rule_Set__c.isAccessible())
                        vPlayClonedList = Database.Query(specificParentQuery2);
                    if(vPlayClonedList.size() > 0){
                        ruleSetList.add(vPlayClonedList.get(0));  
                        listOfRules();
                        return null;
                    }
                } 
                listOfRules();                
            }
        }
        catch(Exception ex)
        {
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('RuleSetFlowComponentController',null, null, null,null,null, null , null, null, 'CloneRuleSet', Error);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage())); return null;
        }   
        return null;   
    }
    public PageReference deleteRuleSet(){
        try
        {
            if(deleteRuleSetId != null && deleteRuleSetId != '')
            {
                List<Child_Rule_Set__c> deletevPlayChildList = new List<Child_Rule_Set__c>();
                if(Schema.sObjectType.Child_Rule_Set__c.isAccessible() && Schema.sObjectType.Child_Rule_Set__c.fields.Id.isAccessible()){
                    deletevPlayChildList = [select id from Child_Rule_Set__c where Rule_Set__c = : deleteRuleSetId limit 1]; 
                }
                
                
                if (deletevPlayChildList.size()>0){
                    if(Schema.sObjectType.Child_Rule_Set__c.isAccessible() && Schema.sObjectType.Child_Rule_Set__c.isDeletable()) { 
                        Database.delete(deletevPlayChildList);
                    }
                    
                }
                List<Rule_Set__c> deleteruleSets =  new List<Rule_Set__c>();
                if(Schema.sObjectType.Rule_Set__c.isAccessible() && Schema.sObjectType.Rule_Set__c.fields.Id.isAccessible()){
                    deleteruleSets = [Select id from Rule_Set__c where Id =: deleteRuleSetId LIMIT 1];
                }           
                
                
                if(deleteruleSets.size() > 0){
                    if (Schema.sObjectType.Rule_Set__c.isAccessible() && Schema.sObjectType.Rule_Set__c.isDeletable()) { 
                        Database.delete(deleteruleSets);
                    } 
                }
                listOfRules();
                
                return null;
            }
        }catch(Exception ex){
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('RuleSetFlowComponentController',null, null, null,null,null, null , null, null, 'deleteRuleSet', Error);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage())); return null;
            return null;
        } 
        return null;   
    }
    public PageReference editSave(){
        try{
            nw_wrapperList = new List<WrapperClass>();
            if( editruleSet.description__c.trim().length() == 0){
                
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label17));
                return  null;
            }
            else {
                if(wrapperList.size()>0)
                {
                    PageReference p= null;
                    
                    if(!editvalidateChild())
                    {
                        return null; 
                    }
                    else{
                    }
                    
                    if(editruleSet.filterLogic__c.trim().length() > 0)
                    {    addnewFieldButton = false;
                     nw_wrapperList = new List<WrapperClass>();
                     p = filterLogic(editruleSet.filterLogic__c);
                     
                     if(p == null){
                         if(!nw_FilterValid){
                             
                             return null;
                         }
                         else if(nw_FilterValid)
                         {
                             editruleSet.filterLogic__c =  editruleSet.filterLogic__c.toUpperCase().rePlaceAll(' ','').replaceAll('  ','');
                             
                         }
                     }
                    }
                    else
                    {
                        String filterLogic ='';
                        if(editruleSet.filterLogic__c.trim().length() == 0)
                        {
                            if(wrapperList.size()>=2){
                                for(Integer i=0; i<wrapperList.size(); i++){
                                    filterLogic += (i+1);
                                    if(i == wrapperList.size()-1) break;
                                    filterLogic += 'AND';
                                }
                            }else if(wrapperList.size() == 1)
                            {
                                filterLogic = String.valueOf(1);
                            }
                        }
                        editruleSet.filterLogic__c = filterLogic;
                        
                        
                    }
                    if((wrap.fieldValue != null ) && editruleSet.Project__c.length() ==0 && editruleSet.Project__c !=null  )
                    {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label19));
                        return null;
                    }
                    else if(editruleSet.Project__c != null ){
                        
                        if(editruleSet.Project__c.trim() == null || editruleSet.Project__c.trim() == '' || editruleSet.Project__c.trim() == 'null'){ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label23)); return null;}  
                        else if (editruleSet.Project__c != null && editruleSet.Project__c.trim() != null) {
                            
                            if (! ( Rule_Set__c.sObjectType.getDescribe().isCreateable() 
                                   && Rule_Set__c.sObjectType.getDescribe().isUpdateable()
                                   && Schema.sObjectType.Rule_Set__c.fields.filterLogic__c.isCreateable()
                                   && Schema.sObjectType.Rule_Set__c.fields.Project__c.isCreateable()
                                   && Schema.sObjectType.Rule_Set__c.fields.ruleSetObject__c.isCreateable()
                                   
                                  )){
                                      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, System.label.RuleSetFlowComponentController_Label20));
                                  } else {
                                      if(schema.sObjectType.Rule_Set__c.isCreateable() && schema.sObjectType.Rule_Set__c.isUpdateable()){
                                          upsert editruleSet;
                                      }
                                  }
                            
                            
                        }
                        
                    }
                    for( EditWrapperClass ch :  wrapperList){
                        
                        Child_Rule_Set__c child = new Child_Rule_Set__c();   
                        child.Field_Name__c  = ch.fieldName;
                        
                        
                        ed_fielddataType = edObjectFields.get(ch.fieldName).getDescribe().getType();  
                        if(edObjectFields.get(ch.FieldName).getDescribe().isupdateable())
                        {
                            
                            if(ed_fielddataType == Schema.DisplayType.DateTime){
                                if(ch.editwrapObj.get(ch.fieldName) != null && ch.editwrapObj.get(ch.fieldName) != ''){
                                    Integer hh = DateTime.valueOf(ch.editwrapObj.get(ch.fieldName)).hour(); 
                                    
                                    String fieldValue = String.valueOf(DateTime.valueOf(ch.editwrapObj.get(ch.fieldName)).format('yyyy-MM-dd hh:mm:ss.sss'));
                                    String result = setDateTimeFormat(fieldValue,hh);
                                    if(result != null) {ch.fieldValue =result; child.field_value__c = result;}
                                } else child.field_value__c = 'null';                                             
                                
                            }else if(ed_fielddataType == Schema.DisplayType.Date){
                                if(ch.editwrapObj.get(ch.fieldName) != '' && ch.editwrapObj.get(ch.fieldName) != null ) child.field_value__c = String.valueOf(ch.editwrapObj.get(ch.fieldName)).split(' ')[0]; else child.field_value__c = 'null';
                            }else if(edObjectFields.get(ch.FieldName).getDescribe().isDependentPickList()){
                                child.field_value__c = ch.fieldValue; 
                            }
                            else{
                                if(ch.editwrapObj.get(ch.fieldName) != '\'\'' && ch.editwrapObj.get(ch.fieldName) != '\'\'\'\''  && ch.editwrapObj.get(ch.fieldName) != '"' && ch.editwrapObj.get(ch.fieldName) != '""' ){
                                    
                                    if(ch.editwrapObj.get(ch.fieldName) == null){
                                        if(ed_fielddataType== Schema.DisplayType.INTEGER) child.field_value__c = 'null';
                                        else if(ed_fielddataType== Schema.DisplayType.DOUBLE) child.field_value__c = 'null';
                                        else if(ed_fielddataType== Schema.DisplayType.PERCENT) child.field_value__c = 'null';
                                        else if(ed_fielddataType== Schema.DisplayType.CURRENCY) child.field_value__c = 'null';
                                        else child.field_value__c = String.valueOf(ch.editwrapObj.get(ch.fieldName));
                                        
                                    }else{ child.field_value__c = String.valueOf(ch.editwrapObj.get(ch.fieldName));}
                                    
                                }
                            }
                            
                        }else{
                            if(ed_fielddataType == Schema.DisplayType.DateTime){
                                if(ch.fieldValue != ''){
                                    String result = splitDateTimeFormat(String.valueOf(ch.fieldValue)); 
                                    if(result != null) { 
                                        ch.fieldValue = result; child.field_value__c = result;
                                        
                                    }
                                }else child.field_value__c = 'null';
                                
                            }else if(ed_fielddataType == Schema.DisplayType.Date){
                                if(ch.fieldValue != '') child.field_value__c = String.valueOf(ch.fieldValue); else child.field_value__c = 'null';
                            }
                            else{
                                
                                if(ed_fielddataType == Schema.DisplayType.BOOLEAN){  if(ch.fieldValue == '') child.field_value__c = 'False';}
                                if(ch.fieldValue != '' && ch.fieldValue != '\'\'' && ch.fieldValue != '\'\'\'\'' && ch.fieldValue != '"' && ch.fieldValue != '""') { 
                                    if(ed_fielddataType== Schema.DisplayType.INTEGER) child.field_value__c = 'null';
                                    if(ed_fielddataType== Schema.DisplayType.DOUBLE) child.field_value__c = 'null';
                                    if(ed_fielddataType== Schema.DisplayType.PERCENT) child.field_value__c = 'null';
                                    if(ed_fielddataType== Schema.DisplayType.CURRENCY) child.field_value__c = 'null';
                                    else child.field_value__c = ch.fieldValue;
                                }
                            }
                            
                        }
                        
                        child.filter__c  = ch.filter;
                        child.sno__c = String.valueof(ch.sno);
                        child.object_Name__c  = ch.objectName;
                        child.Rule_Set__c = editruleSet.Id;
                        
                        if(!edObjectFields.isEmpty()){
                            ed_fielddataType = edObjectFields.get(ch.fieldName).getDescribe().getType();
                        }
                        child.datatype__C = String.valueOF(ed_fielddataType);
                        if(ch.childId != null){
                            child.put('Id',  ch.childId);
                        }
                        if(child.field_value__c == 'GENERIC_TEXT_FOR_REQUIRED_FIELD'){
                            child.field_value__c = '';
                        }
                        ruleSetInsertChildList.add(child);
                        
                    }
                    if(ruleSetInsertChildList.size() > 0 && ruleSetInsertChildList!= null){
                        if(editruleSet.Id != null && edRetainObject != editruleSet.ruleSetObject__c)
                        {
                            List<Child_Rule_Set__c> childList = new List<Child_Rule_Set__c>();
                            if(Schema.sObjectType.Child_Rule_Set__c.isAccessible() && Schema.sObjectType.Child_Rule_Set__c.fields.Id.isAccessible()){
                                childList = [select id from Child_Rule_Set__c where Rule_Set__c =: editruleSet.Id]; 
                            }
                            
                            
                            if(childList.size()>0){
                                if (Schema.sObjectType.Child_Rule_Set__c.isAccessible() && Schema.sObjectType.Child_Rule_Set__c.isDeletable()){ 
                                    Database.delete(childList);
                                } 
                            }
                            
                            
                        }
                        if(editruleSet.Id != null){ // Deleting the children from database which are deleted from the wrapperList.
                            List<Child_Rule_Set__c> childList = new List<Child_Rule_Set__c>();
                            Id parentId = editruleSet.Id;
                            String specChildQuery = onlyChildQuery + ' WHERE Rule_Set__c = :parentId';
                            if(Schema.sObjectType.Child_Rule_Set__c.isAccessible())
                                childList = Database.Query(specChildQuery);
                            Set<Id> childToDeleteId= new Set<Id>();
                            for(Child_Rule_Set__c child : childList){childToDeleteId.add(child.Id); }
                            Set<Id> childIdToSave = new Set<Id>();
                            List<Child_Rule_Set__c> childDeleteList = new List<Child_Rule_Set__c>();
                            for(EditWrapperClass wr : wrapperList){ if(wr.ChildId != null){childIdToSave.add(wr.ChildId);} }
                            for(Id ids : childToDeleteId){
                                if(!childIdToSave.contains(ids)){
                                    Child_Rule_Set__c ch = new Child_Rule_Set__c(Id = ids);
                                    childDeleteList.add(ch);
                                }     
                            }
                            
                            if (Schema.sObjectType.Child_Rule_Set__c.isAccessible() && Schema.sObjectType.Child_Rule_Set__c.isDeletable()) { 
                                Database.delete(childDeleteList);
                            } 
                            
                        }
                        if (! ( Child_Rule_Set__c.sObjectType.getDescribe().isCreateable() 
                               && Child_Rule_Set__c.sObjectType.getDescribe().isUpdateable()
                               && Schema.sObjectType.Child_Rule_Set__c.fields.Field_Name__c.isCreateable()
                               && Schema.sObjectType.Child_Rule_Set__c.fields.field_value__c.isCreateable()
                               && Schema.sObjectType.Child_Rule_Set__c.fields.filter__c.isCreateable()
                               && Schema.sObjectType.Child_Rule_Set__c.fields.sno__c.isCreateable()
                               && Schema.sObjectType.Child_Rule_Set__c.fields.object_Name__c.isCreateable()
                               && Schema.sObjectType.Child_Rule_Set__c.fields.Rule_Set__c.isCreateable()
                               && Schema.sObjectType.Child_Rule_Set__c.fields.datatype__c.isCreateable()
                               
                              ) ){
                                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, System.label.RuleSetFlowComponentController_Label20));
                              } else {
                                  if(schema.sObjectType.Child_Rule_Set__c.isCreateable() && schema.sObjectType.Child_Rule_Set__c.isUpdateable()){
                                      upsert ruleSetInsertChildList;           
                                  }
                              }      
                    }                     
                } 
                else
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label21));
                    return null;
                }   
                listOfRules();
                
            }              
        }catch(Exception ex){
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('RuleSetFlowComponentController',null, null, null,null,null, null , null, null, 'editSave', Error);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, string.ValueOf(ex)));                       
            return null;            
        } 
        return null;    
    }
    public void editSection() {
        try{
            if(editId != null) {
                wrapperList = new List<EditwrapperClass>();
                List<Child_Rule_Set__c> ruleSetChildList = new List<Child_Rule_Set__c>();  
                String specParentQuery = onlyParentQuery + ' where Id =: editId limit 1 ';
                if(Schema.sObjectType.Rule_Set__c.isAccessible())                 
                    editruleSetList = Database.Query(specParentQuery);
                editruleSet = editruleSetList.get(0); 
                edRetainObject = editruleSet.ruleSetObject__c;
                editSection = false;
                objName = editruleSet.ruleSetObject__c;
                allField();
                if(editruleSetList.size()>0 && editruleSetList!= null)
                {   
                    String editruleSetListID = editruleSetList.get(0).Id;
                    String specChildQuery = onlyChildQuery + ' WHERE Rule_Set__c =: editruleSetListID order by sno__c limit 5 ';
                    if(Schema.sObjectType.Rule_Set__c.isAccessible())
                        ruleSetChildList = Database.Query(specChildQuery);
                    if(ruleSetChildList.size() > 0 && !ruleSetChildList.isEmpty()) {
                        
                        
                        for(Child_Rule_Set__c child : ruleSetChildList)
                        {
                            EditWrapperClass wrap = new EditWrapperClass();
                            wrap.fieldName = child.Field_Name__c; 
                            wrap.fieldValue = child.field_Value__c;
                            wrap.filter = child.filter__c;
                            wrap.objectName = child.object_Name__c;
                            wrap.dataType = child.dataType__c;
                            wrap.vPlayId = child.Rule_Set__c;
                            wrap.sno = Integer.valueof(child.sno__c);
                            wrap.childId = child.Id;
                            
                            Schema.SOBjectType targetType  = Schema.getGlobalDescribe().get(child.object_Name__c);
                            
                            if(targetType != null)
                            {
                                wrap.editWrapObj = targetType.newSObject();
                                //obj = wrap.editWrapObj;
                                Schema.DisplayType fielddataType  = edObjectFields.get(wrap.fieldName).getDescribe().getType(); 
                                wrap.isRequired = false;
                                if(!edObjectFields.get(wrap.fieldName).getDescribe().isNillable()){
                                    wrap.isRequired = true ;
                                }
                                if(edObjectFields.get(wrap.fieldName).getDescribe().isUpdateable())
                                {
                                    if(fielddataType == Schema.DisplayType.INTEGER) if(wrap.fieldValue == null || wrap.fieldValue == 'null') wrap.editWrapobj.put(wrap.fieldName,null); else{ wrap.editWrapobj.put(wrap.fieldName,Integer.valueOf(wrap.fieldValue));}
                                    else if(fielddataType == Schema.DisplayType.STRING || fielddataType == Schema.DisplayType.PICKLIST || fielddataType == Schema.DisplayType.PHONE || fielddataType == Schema.DisplayType.MULTIPICKLIST || fielddataType == Schema.DisplayType.URL || fielddataType == Schema.DisplayType.REFERENCE) 
                                    {
                                        
                                        if(edObjectFields.get(wrap.fieldName).getDescribe().isDependentPickList())  {ed_fetchDepPickList(wrap,wrap.fieldName);}
                                        else {if(wrap.fieldValue == null || wrap.fieldValue == 'null') wrap.editWrapobj.put(wrap.fieldName,null); else wrap.editWrapobj.put(wrap.fieldName,String.valueOf(wrap.fieldValue));}
                                    }
                                    else if(fielddataType == Schema.DisplayType.DOUBLE) if(wrap.fieldValue == null || wrap.fieldValue == 'null') wrap.editWrapobj.put(wrap.fieldName,null); else wrap.editWrapobj.put(wrap.fieldName,Double.valueOf(wrap.fieldValue));
                                    else if(fielddataType == Schema.DisplayType.BOOLEAN) wrap.editWrapobj.put(wrap.fieldName,Boolean.valueOf(wrap.fieldValue));
                                    else if(fielddataType == Schema.DisplayType.PERCENT) if(wrap.fieldValue == null || wrap.fieldValue == 'null') wrap.editWrapobj.put(wrap.fieldName,null); else wrap.editWrapobj.put(wrap.fieldName,Double.valueOf(wrap.fieldValue));
                                    else if(fielddataType == Schema.DisplayType.CURRENCY) if(wrap.fieldValue == null || wrap.fieldValue == 'null') wrap.editWrapobj.put(wrap.fieldName,null); else wrap.editWrapobj.put(wrap.fieldName,Integer.valueOf(wrap.fieldValue));
                                    else if(fielddataType == Schema.DisplayType.DATETIME){
                                        
                                        if(wrap.fieldValue != 'null' && wrap.fieldValue != null && wrap.fieldValue != '' ) wrap.editWrapobj.put(wrap.fieldName,DateTime.valueOf(wrap.fieldValue));
                                        else wrap.editWrapobj.put(wrap.fieldName,null); 
                                    } 
                                    else if(fielddataType == Schema.DisplayType.DATE){  if(wrap.fieldValue != 'null' && wrap.fieldValue != null && wrap.fieldValue != '' ){  wrap.editWrapobj.put(wrap.fieldName,Date.valueOf(wrap.fieldValue)); }
                                                                                      else wrap.editWrapobj.put(wrap.fieldName,null); }
                                    else if(fielddataType == Schema.DisplayType.TIME){  if(wrap.fieldValue != 'null' && wrap.fieldValue != null && wrap.fieldValue != '' ){
                                        
                                        list<String> TimeData=wrap.fieldValue.split(':');
                                        Time fieldTimeValue = Time.newInstance(
                                            Integer.valueOf(TimeData[0]),
                                            Integer.valueOf(TimeData[1]),
                                            Integer.valueOf('00'),
                                            Integer.valueOf('00')) ;
                                        
                                        wrap.editWrapobj.put(wrap.fieldName,fieldTimeValue); 
                                    }
                                                                                      else wrap.editWrapobj.put(wrap.fieldName,null); }
                                    else wrap.editWrapobj.put(wrap.fieldName,String.valueOf(wrap.fieldValue));
                                    wrap.isUpdateable = true;
                                }else
                                {// For Read-only fields
                                    if(fielddataType == Schema.DisplayType.DATETIME){
                                        String result = '';
                                        if(wrap.fieldValue != '' && wrap.fieldValue != 'null' && wrap.fieldValue != null)  result = editSec_DateTimeFormat(String.valueOf(wrap.fieldValue));  
                                        if(result != null) wrap.fieldValue = result;      
                                        wrap.isUpdateable = false;
                                    }    
                                }   
                                
                            }
                            //wrap.soList.add(wrap.editWrapobj);
                            wrapperList.add(wrap);
                            
                        }
                        
                        
                    }
                    if(wrapperList.size()>0){
                    }
                }
            }
        }
        catch(Exception ex)
        {
            
            String Error=System.label.cause_Label +ex.getCause()+'\n'+ System.label.LineNumber_Label +ex.getLineNumber()+'\n'+ System.label.Message_Label +ex.getMessage();
            GenerateJiraLogs.CreateLogRealTime('RuleSetFlowComponentController',null, null, null,null,null, null , null, null, 'editSection', Error);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage())); 
        }        
    }
    public List<SelectOption> getAllFilter(){
        List<SelectOption> filter = new List<SelectOption>(); 
        filter.add(new SelectOption('None',System.label.nonelabel2));
        filter.add(new SelectOption('contains',System.label.RuleSetFlowComponentController_Label35));
        filter.add(new SelectOption('does not contain',System.label.RuleSetFlowComponentController_Label36));
        filter.add(new SelectOption('equals',System.label.RuleSetFlowComponentController_Label37));
        filter.add(new SelectOption('excludes',System.label.RuleSetFlowComponentController_Label38));    
        filter.add(new SelectOption('greater or equal',System.label.RuleSetFlowComponentController_Label39));
        filter.add(new SelectOption('greater than',System.label.RuleSetFlowComponentController_Label40));
        filter.add(new SelectOption('includes',System.label.RuleSetFlowComponentController_Label41));
        filter.add(new SelectOption('less or equal',System.label.RuleSetFlowComponentController_Label42));
        filter.add(new SelectOption('less than',System.label.RuleSetFlowComponentController_Label43));
        filter.add(new SelectOption('not equal to',System.label.RuleSetFlowComponentController_Label44));
        filter.add(new SelectOption('starts with',System.label.RuleSetFlowComponentController_Label45));
        return filter;
    }
    public PageReference filterLogic(String filter){
        Boolean showError = true;
        nw_FilterValid = true;
        String andOP = 'AND';
        String orOP = 'OR';
        List<String> ANDString = new List<String>();
        List<String> ORString = new List<String>();
        
        ANDString.add('AND');
        ANDString.add('aND');
        ANDString.add('AnD');
        ANDString.add('ANd');
        ANDString.add('anD');
        ANDString.add('And');
        ANDString.add('aNd');
        ANDString.add('and');
        
        ORString.add('OR');
        ORString.add('Or');
        ORString.add('oR');
        ORString.add('or');
        if(addnewFieldButton){
            
            if(nw_WrapperList.size() == 0)
            {  
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label21));
                nw_FilterValid =false;
                return null;
            }
        }else{
            if(WrapperList.size() == 0)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,  System.label.RuleSetFlowComponentController_Label21));
                nw_FilterValid =false;
                return null;
            }
        }
        if(nw_WrapperList.size() > 0 || WrapperList.size()>0)
        {
            filter = filter.toUpperCase();
            if(filter != null)
            {
                String InitialString = filter.trim().rePlaceAll(' ','');
                String filteredString = filter.trim().rePlaceAll(' ','');
                
                /**************** REmoving brackets ********************/      
                if(filteredString.indexOf(')') > -1)
                {
                    try{
                        filteredString = filteredString.remove(')');
                        
                    }catch(Exception ex){
                        nw_FilterValid =false;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage())); return null;    
                    }    
                }
                if(filteredString.indexOf('(') > -1 )
                {
                    
                    try{ 
                        filteredString = filteredString.remove('(');
                        
                    }catch(Exception ex){
                        
                        nw_FilterValid =false;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage())); return null;
                    }
                    
                }
                /******************** Removing AND OR ************************/
                if(filteredString.indexOf('AND') > -1)
                {
                    filteredString = filteredString.replaceAll('AND','');
                    showError = false;
                }
                
                if(filteredString.indexOf('OR') > -1)
                {
                    filteredString = filteredString.replaceAll('OR','');
                    showError = false;
                }
                if(filteredString.isNumeric()) showError = false;
                if(showError){
                    
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label24));    
                    nw_FilterValid =false;
                    return null;
                    
                }
                
                if(filteredString.isNumeric())
                {
                    Set<Integer> allowedNO = new Set<Integer>();
                    Map<Integer,Integer> mapNoToASCII = new Map<Integer,Integer>();
                    mapNoToASCII.put(1,49);
                    mapNoToASCII.put(2,50);
                    mapNoToASCII.put(3,51);
                    mapNoToASCII.put(4,52);
                    mapNoToASCII.put(5,53);
                    Set<Integer> allSNO = new Set<Integer>();
                    if(nw_wrapperList.size()>0 || WrapperList.size()>0)
                    {
                        if(nw_WrapperList.size()>0)
                        {   
                            for(WrapperClass str : nw_WrapperList)
                            {
                                allSNO.add(Integer.valueOf(str.sno));
                            }
                            
                            
                            for(WrapperClass str : nw_WrapperList)
                            {
                                if(!mapNoToASCII.isEmpty() && mapNoToASCII.containsKey(Integer.ValueOf(str.sno))){
                                    nw_FilterValid = true;
                                    allowedNO.add(mapNoToASCII.get(Integer.ValueOf(str.sno)));
                                    
                                }else
                                {
                                    if(Integer.valueOf(str.sno)>5){
                                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label25));    
                                        nw_FilterValid =false;
                                        return null;    
                                    }else{
                                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label24));  
                                        nw_FilterValid =false;
                                        return null;
                                    }
                                    
                                }
                                
                            }
                        } 
                        if(wrapperList.size()>0)
                        {   
                            for(EditWrapperClass str : WrapperList)
                            {
                                allSNO.add(Integer.valueOf(str.sno));
                            } 
                            for(EditWrapperClass str : WrapperList)
                            {
                                if(!mapNoToASCII.isEmpty() && mapNoToASCII.containsKey(Integer.ValueOf(str.sno))){
                                    nw_FilterValid = true;
                                    allowedNO.add(mapNoToASCII.get(Integer.ValueOf(str.sno)));
                                    
                                }else{
                                    if(Integer.valueOf(str.sno)>5){
                                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label25));    
                                        nw_FilterValid =false;
                                        return null;    
                                    }else{
                                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label24));  
                                        nw_FilterValid =false;
                                        return null;
                                    }
                                    
                                }
                                
                            }
                        }   
                        if(allowedNo.size()>0 && filteredString.length()>0)
                        {
                            Set<Integer> uniqueNo = new  Set<Integer>();
                            for(Integer i=0; i<filteredString.length(); i++){uniqueNo.add(filteredString.charAt(i));}
                            
                            if(allowedNo.size() != uniqueNo.size())    
                            {
                                
                                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label26));    
                                nw_FilterValid =false;        
                                return null;
                            }   
                            
                        }
                        if(allowedNo.size()>0)
                        {    
                            for(Integer k=0 ; k<filteredString.length(); k++)
                            {
                                
                                if(allowedNo.contains(filteredString.charAt(k)))
                                {
                                    nw_FilterValid =true;
                                }else
                                {
                                    if(filteredString.charAt(k)>53){
                                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label25));    
                                        nw_FilterValid =false;        
                                        return null; 
                                    }else{
                                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label27));  
                                        nw_FilterValid =false;
                                        return null;
                                    }
                                }  
                                
                            }
                        }
                        
                    }
                    List<String> leftBracket = new List<String>();
                    List<String> RightBracket = new List<String>();
                    List<String> validatedString = new List<String>();
                    
                    /******************************  Replacing AND OR with A, O **********************/
                    for(Integer i=0; i<=InitialString.length()-1; i++)
                    {
                        for(String str : ANDString)
                        {
                            if(InitialString.indexOf(str) > -1) InitialString = InitialString.replaceAll(str,'A');
                            
                        }
                        for(String str : ORString)
                        {
                            if(InitialString.indexOf(str) > -1) InitialString = InitialString.replaceAll(str,'O');
                        }
                        
                    }
                    
                    
                    /**
*    Checking the parenthesis
*/
                    for(Integer i=0; i<=InitialString.length()-1; i++)
                    {
                        if(InitialString.charAt(i) == 40 )
                        {
                            leftBracket.add('(');   
                        }
                        if(InitialString.charAt(i) == 41 )
                        {
                            RightBracket.add(')');
                            nw_FilterValid = true;
                            continue;
                        }
                    } 
                    if(leftBracket.size() != rightBracket.size())
                    {    
                        
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label28));    
                        nw_FilterValid =false;
                        return null;
                    }
                    
                    for(Integer i=0; i<=InitialString.length()-1; i++)
                    {
                        if(InitialString.charAt(i) == 40 )
                        {
                            if(validatedString.size() == 0) 
                            {
                                validatedString.add('('); 
                                nw_FilterValid = true;
                                continue;
                            }
                            else {
                                if(validatedString.get(i-1).isNumeric()) 
                                { 
                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label24));  
                                    nw_FilterValid =false;
                                    return null;
                                }  
                                else if(validatedString.get(i-1) == ')') 
                                { 
                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label29));  
                                    nw_FilterValid =false;
                                    return null;
                                }  
                                
                                else {
                                    validatedString.add('(');
                                    nw_FilterValid = true;
                                    continue;
                                }
                                
                            } 
                        }
                        // Numeric for 1,2,3,4,5
                        if(InitialString.charAt(i) == 49 || InitialString.charAt(i) == 50 || InitialString.charAt(i) == 51 || InitialString.charAt(i) == 52 || InitialString.charAt(i) == 53)
                        {
                            if(validatedString.size() == 0) 
                            {
                                validatedString.add(String.valueOf(InitialString.charAt(i)));
                                nw_FilterValid = true;
                                continue;
                            }    
                            else 
                            {
                                if(validatedString.get(i-1) == ')') 
                                { 
                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label24));  
                                    nw_FilterValid =false;
                                    return null;
                                }    
                                else if(validatedString.get(i-1).isNumeric() ) 
                                { 
                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label30));  
                                    nw_FilterValid =false;
                                    return null;
                                }
                                else{
                                    validatedString.add(String.valueOf(InitialString.charAt(i)));
                                    nw_FilterValid = true;
                                    continue;
                                }
                                
                            }    
                        }
                        // Right Bracket )
                        if(InitialString.charAt(i) == 41)
                        {
                            if(validatedString.size() == 0) 
                            {
                                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label24));  
                                nw_FilterValid =false;
                                return null;
                            }
                            else
                            {
                                if(validatedString.get(i-1) == '(') 
                                { 
                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label24));  
                                    nw_FilterValid =false;
                                    return null;
                                } 
                                else if(validatedString.get(i-1) == 'A')
                                {
                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label24));  
                                    nw_FilterValid =false;
                                    return null;
                                }
                                else if(validatedString.get(i-1) == 'O')
                                {
                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label24));  
                                    nw_FilterValid =false;
                                    return null;
                                } 
                                else{ 
                                    validatedString.add(')');
                                    nw_FilterValid = true;
                                    continue;
                                }
                            }   
                        }
                        // AND operator , for AND operator using A (65) ASCII code 
                        // OR operator , for OR operator using O (65) ASCII code 
                        if(InitialString.charAt(i) == 65 || InitialString.charAt(i) == 79)
                        {
                            if(validatedString.size() == 0) 
                            {
                                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label31));  
                                nw_FilterValid =false;
                                return null;
                            }
                            else
                            {   
                                if(validatedString.get(i-1) == 'A') 
                                { 
                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label32));  
                                    nw_FilterValid =false;
                                    return null;
                                } 
                                else if(validatedString.get(i-1) == 'O')
                                {
                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label32));  
                                    nw_FilterValid =false;
                                    return null;
                                }
                                else if(validatedString.get(i-1) == '(')
                                {
                                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label24));  
                                    nw_FilterValid =false;
                                    return null;
                                }
                                else if(validatedString.get(i-1) == '49' || validatedString.get(i-1) == '50' || validatedString.get(i-1) == '51' || validatedString.get(i-1) == '52' || validatedString.get(i-1) == '53')
                                {
                                    if((i-2)>0)
                                    {
                                        if(validatedString.get(i-2) == 'A' || validatedString.get(i-2) == 'O')
                                        {
                                            String convertChar = validatedString.get(i-2);
                                            if(convertChar.charAt(0) != InitialString.charAt(i)){
                                                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label33));  
                                                nw_FilterValid =false;
                                                return null;
                                            }
                                            else
                                            {
                                                if(InitialString.charAt(i) == 65){
                                                    validatedString.add('A'); 
                                                    nw_FilterValid = true;
                                                    continue;   
                                                }
                                                else if(InitialString.charAt(i) == 79){
                                                    validatedString.add('O'); 
                                                    nw_FilterValid = true;
                                                    continue;
                                                } 
                                            }
                                        } 
                                        else if(validatedString.get(i-2) == '(' || validatedString.get(i-2) == ')')
                                        {
                                            if(InitialString.charAt(i) == 65){
                                                validatedString.add('A'); 
                                                nw_FilterValid = true;
                                                continue;   
                                            }
                                            else if(InitialString.charAt(i) == 79){
                                                validatedString.add('O'); 
                                                nw_FilterValid = true;
                                                continue;
                                            }
                                        }
                                    }
                                    else{
                                        if(InitialString.charAt(i) == 65){
                                            validatedString.add('A');    
                                            nw_FilterValid = true;
                                            continue;
                                        }
                                        else if(InitialString.charAt(i) == 79){
                                            validatedString.add('O'); 
                                            nw_FilterValid = true;
                                            continue;
                                        }
                                    }           
                                }else if(validatedString.get(i-1) == ')' ){
                                    // continue in reverse in validatedString until  AND/OR operator
                                    List<String> revRtB = new List<String>();
                                    List<String> revLtB = new List<String>();
                                    
                                    if( ValidatedString.size() > 3 ){
                                        String operator;
                                        for(Integer j= (i-1); j>= 0; j--)
                                        {
                                            if(validatedString.get(j) == ')')
                                            {
                                                revRtB.add(')');
                                            }
                                            else if(validatedString.get(j) == '('){
                                                revLtB.add('(');
                                            }
                                            else if(validatedString.get(j) == 'A' || validatedString.get(j) == 'O')
                                            {
                                                operator = validatedString.get(j);
                                                break;
                                            }
                                            
                                        }
                                        if(revRtB.size()>0 && revLtB.size()>0)
                                        {
                                            
                                            if(revRtB.size() == revLtB.size()){
                                                
                                                if(operator.charAt(0) == InitialString.charAt(i))
                                                {
                                                    if(InitialString.charAt(i) == 65){
                                                        validatedString.add('A'); 
                                                        nw_FilterValid = true;   
                                                        continue;
                                                    }
                                                    else if(InitialString.charAt(i) == 79){
                                                        validatedString.add('O'); 
                                                        nw_FilterValid = true;
                                                        continue;
                                                    }
                                                }
                                            }    
                                        }
                                    }else{
                                        
                                        for(Integer j= (i-1); j>= 0; j--)
                                        {
                                            if(validatedString.get(j) == ')')
                                            {
                                                
                                                revRtB.add(')');
                                            }
                                            else if(validatedString.get(j) == '('){
                                                revLtB.add('(');
                                            }
                                            if(revRtB.size()>0 && revLtB.size()>0)
                                            {
                                                
                                                if(revRtB.size() == revLtB.size()){
                                                    
                                                    if(InitialString.charAt(i) == 65){
                                                        validatedString.add('A'); 
                                                        nw_FilterValid = true;   
                                                        continue;
                                                    }
                                                    else if(InitialString.charAt(i) == 79){
                                                        validatedString.add('O'); 
                                                        nw_FilterValid = true;
                                                        continue;
                                                    }
                                                    
                                                }    
                                            }
                                            
                                        }    
                                    }    
                                    if(revRtB.size() > 0 && revLtB.size() > 0){
                                        if(revRtB.size() != revLtB.size() ){
                                            if(InitialString.charAt(i) == 65){
                                                validatedString.add('A'); 
                                                nw_FilterValid = true;
                                                continue;   
                                            }
                                            else if(InitialString.charAt(i) == 79){
                                                validatedString.add('O'); 
                                                nw_FilterValid = true;
                                                continue;
                                            } 
                                        }else{
                                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label33));    
                                            nw_FilterValid =false;
                                            return null;
                                            
                                        }
                                        
                                    }
                                    else  if(revRtB.size()>0){ 
                                        if(InitialString.charAt(i) == 65){
                                            validatedString.add('A'); 
                                            nw_FilterValid = true;
                                            continue;   
                                        }
                                        else if(InitialString.charAt(i) == 79){
                                            validatedString.add('O'); 
                                            nw_FilterValid = true;
                                            continue;
                                        } 
                                    }
                                    
                                    
                                } 
                                
                            }    
                        }
                        
                    }   
                }
                else
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, System.label.RuleSetFlowComponentController_Label24));    
                    nw_FilterValid =false;
                    return null;
                }   
            }
        }
        return null;
    }
    public static void ErrorMessage(String Error){
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR, Error );
        ApexPages.addMessage(msg); 
    }
    
    public pagereference refreshProjects(){
        getProjectList();
        return null;
    }
    public void InsertJiraLogs(){
        if(!JiraLogsToInsert.isEmpty()){
            Insert JiraLogsToInsert;
        }
    }  
    
}