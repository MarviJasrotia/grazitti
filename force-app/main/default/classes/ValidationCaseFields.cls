/** 
* @Author Grazitti
* 
*/
public with sharing class ValidationCaseFields {
    
    public map<String,string> caseFieldset {get;set;}
    public map<String,string> caseFields {get;set;}
    public map<String,string> selectcaseFields {get;set;}
    public list <Validation__c> validationfields;
    public String selectedObject{get;set;}
    public Set<String> MappedObjectsForValidation{get;set;}
    public Map<String,List<Validation__c>> validedObjects;
    public List<Validation__c> validationRecords;
    public String lastModifiedObject{get;set;}
    public String fieldValue {get; set;}
    public List<SelectOption> SObjectListNew{get;set;}
    set<string> MappedSfObjectList= new set<string>();
    public Boolean  mapsize{get;set;}
    Map<String, Schema.SObjectType> schemaMap=new Map<String, Schema.SObjectType>();
    Map<String,String> objectLabelToApi=new Map<String,String>();
    //CONSTRUCTOR
    public ValidationCaseFields(){
        
        SObjectListNew=new List<SelectOption>();
        schemaMap = Schema.getGlobalDescribe();
        
        if(!Jira_ProjectFieldsMapping__c.sObjectType.getDescribe().isAccessible() || !Validation__c.sObjectType.getDescribe().isAccessible()){
            return;
        }
        
        for(Jira_ProjectFieldsMapping__c jpm:[SELECT Id, Name, Salesforce_Object__c, LastModifiedDate FROM Jira_ProjectFieldsMapping__c WHERE Salesforce_Object__c!=NULL ORDER BY LastModifiedDate DESC ]){
            if(Schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.Salesforce_Object__c.isAccessible() && (!MappedSfObjectList.contains(jpm.Salesforce_Object__c))){
                // Schema.DescribeSObjectResult dls=schemaMap.get(jpm.Salesforce_Object__c).getDescribe();
                // objectLabelToApi.put(dls.getLabel(),dls.getName());
                //  MappedSfObjectList.add(dls.getLabel());
                MappedSfObjectList.add(jpm.Salesforce_Object__c);
            }
        }
        for(String obj : MappedSfObjectList){
            SObjectListNew.add(new SelectOption(obj,obj));
        }
        
        
        validationRecords=new List<Validation__c>();
        if(Validation__c.sObjectType.getDescribe().isAccessible()){
            validationRecords= Validation__c.getAll().values();
        }
        if(Schema.sObjectType.Validation__c.fields.Object__c.isAccessible() && validationRecords.size()>0 && validationRecords!=NULL){
            selectedObject=validationRecords[0].Object__c;
            mapsize=true;
        }else{
            mapsize=false;
        }
        //call the function 
        FetchFields();         
    }
    
    //THIS WILL FETCH ALL THE FIELDS OF AN OBJECT AND LOAD ON THE PAGE
    public Void FetchFields(){
        
        //  fieldValue =selectedObject;
        MappedObjectsForValidation=new Set<String>();
        validedObjects=new Map<String,List<Validation__c>>();
        validationRecords=new List<Validation__c>();
        
        //FETCH ALL THE RECORDS OF CUSTOM FIELDS    
        if(Validation__c.sObjectType.getDescribe().isAccessible()){ 
            validationRecords= Validation__c.getAll().values();
        }
        //CREATE A MAP OF OBJECT TO VALIDATION RECORD MAP
        if(validationRecords.size()>0 && validationRecords!=NULL){
            
            for(Validation__c vr:validationRecords){
                
                if(validedObjects.containskey(vr.object__c)){
                    validedObjects.get(vr.object__c).add(vr);
                }else{
                    validedObjects.put(vr.object__c,new List<Validation__c>());
                    validedObjects.get(vr.object__c).add(vr);
                } 
                
                
                if(!MappedObjectsForValidation.contains(vr.object__c) && Schema.sObjectType.Validation__c.fields.Object__c.isAccessible()){
                    MappedObjectsForValidation.add(vr.object__c);
                }    
            }
        }
        caseFields = new map <String,string>();
        caseFieldset= new map <String,string>(); 
        selectcaseFields = new map <String,string>();
        string SelectedString='';
        
        
        if(selectedObject!=NULL && selectedObject!=''){
            
            
            if(!validedObjects.isEmpty()){
                if(validedObjects.containsKey(selectedObject)){
                    for(Validation__c valid : validedObjects.get(selectedObject)){
                        SelectedString+=valid.FieldNames__c+';';
                    }
                }
            }    
            
            Map<String, Schema.SObjectField> fieldMap;
            
            //FETCH THE OBJECT FIELDS
            fieldMap = Schema.getGlobalDescribe().get(selectedObject).getDescribe().fields.getMap();
            
            //   if(!objectLabelToApi.isEmpty() && objectLabelToApi.containsKey(selectedObject)){
            // 	fieldMap = Schema.getGlobalDescribe().get(objectLabelToApi.get(selectedObject)).getDescribe().fields.getMap();
            
            //  }
            for(Schema.SObjectField sfield: fieldMap.Values()) {
                
                schema.describefieldresult dfield = sfield.getDescribe();
                String dataType = String.valueOf(dfield.getType());
                
                if(JiraService.sfJiraDataTypeMapping.get(dataType)!=Null){
                    caseFields.put(dfield.getname(), dfield.getLabel());
                    caseFieldset.put( dfield.getLabel(), dfield.getname());
                }
            }
            
            if(SelectedString!=null  && SelectedString!=''){
                for(String s:SelectedString.split(';')){
                    
                    if(caseFields.containsKey(s)){
                        selectcaseFields.put(caseFields.get(s),s);
                        caseFields.remove(s);
                    }
                }
            }
            
            caseFields.remove('Id');
            caseFieldset.remove(null);
            caseFields.remove(null);
            selectcaseFields.remove(null);
        }
        
        if(MappedObjectsForValidation.size()>0){
            mapsize=true;  
            
        }
        
        
    }
    
    
    public void  movetoselected(){
        string movetodata = ApexPages.currentPage().getParameters().get('movetodata'); 
        for(String s: movetodata.split(';')){
            if(s!=null){
                
                if(caseFields.containsKey(s)){
                    selectcaseFields.put(caseFields.get(s), s);
                    caseFields.remove(s); 
                    
                }
            }  
        }
    }
    
    public void movefromselected(){
        
        string movefromdata = ApexPages.currentPage().getParameters().get('movefromdata');
        for(String s: movefromdata.split(';')){
            if(s!=null){
                selectcaseFields.remove(s);
                
                caseFields.put(caseFieldset.get(s),s);
            }
        }
    }
    
    public PageReference save(){
        
        List<Validation__c> deleteOldValidatedFields=new List<Validation__c>();
        
        if(validedObjects.ContainsKey(selectedObject)){
            deleteOldValidatedFields= validedObjects.get(selectedObject);  
        }
        
        if(!deleteOldValidatedFields.isEmpty()) {
            if(schema.sObjectType.Validation__c.isDeletable()){    
                delete deleteOldValidatedFields;
            }
        }
        
        validationfields= new list<validation__c>();
        String fields='';
        
        
        for(String s :selectcaseFields.keySet()){
            
            Validation__c valid= new Validation__c();
            if(schema.sObjectType.Validation__c.fields.FieldNames__c.isCreateable()){
                valid.FieldNames__c=selectcaseFields.get(s);
            }
            String Name=selectedObject+'__'+selectcaseFields.get(s);
            
            if(s.length()>38){
                if(schema.sObjectType.Validation__c.fields.name.isCreateable()){
                    valid.name=selectedObject.substring(0,3)+'__'+s.substring(0,38) ;
                }
            }else{
                if(schema.sObjectType.Validation__c.fields.name.isCreateable()){
                    valid.name=selectedObject.substring(0,3)+'__'+s; 
                }
            }
            if(schema.sObjectType.Validation__c.fields.Field_Label__c.isCreateable()){
                valid.Field_Label__c=s;
            }
            if(schema.sObjectType.Validation__c.fields.Object__c.isCreateable()){
                valid.Object__c=selectedObject;
            }
            
            validationfields.add(valid);
        }
        
        if(!validationfields.isEmpty() && schema.sObjectType.Validation__c.isCreateable()){
            insert validationfields;
        }
        
        
        validedObjects=new Map<String,List<Validation__c>>();
        validationRecords=new List<Validation__c>();
        validationRecords= Validation__c.getAll().values(); 
        
        If(validationRecords.SIZE()>0 && validationRecords!=NULL){
            
            for(Validation__c vr:validationRecords){
                
                if(validedObjects.containskey(vr.Object__c)){
                    validedObjects.get(vr.Object__c).add(vr);
                }else{
                    validedObjects.put(vr.Object__c,new List<Validation__c>());
                    validedObjects.get(vr.Object__c).add(vr);
                } 
            }
        }  
        
        
        if(!validedObjects.containsKey(selectedObject)){
            
            if(MappedObjectsForValidation.contains(selectedObject))
                MappedObjectsForValidation.remove(selectedObject);
        }
        else{
            
            if(!MappedObjectsForValidation.contains(selectedObject))
                MappedObjectsForValidation.add(selectedObject);
            
        }
        
        if(MappedObjectsForValidation.size()>0){
            mapsize=true;
            
        }else{
            mapsize=false;
        }
        return null;  
    }
}