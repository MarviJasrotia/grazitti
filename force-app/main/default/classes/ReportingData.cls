/*
* This class is used to fetch the fields where reporting is Enabled
*/
public with sharing class ReportingData{
    public static Set<String> getReportingFields(){
        Set<String> finalfields = New Set<String>();
        Map<String,String> ApiNamebyType = New Map<String,String>();
        if(!Jira_ProjectFieldsMapping__c.sObjectType.getDescribe().isAccessible()){
            return null;
        }
        for(Jira_ProjectFieldsMapping__c jpm : [SELECT Id, JIRA_Field_Api_Name__c, 
                                                Jira_Field_Name__c, IsReportingEnabled__c,DataType__c,isArray__c
                                                FROM Jira_ProjectFieldsMapping__c
                                                WHERE IsReportingEnabled__c = TRUE]){
                                                    if(Schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.JIRA_Field_Api_Name__c.isAccessible()){
                                                        finalfields.add(jpm.JIRA_Field_Api_Name__c);
                                                    }
                                                    if(Schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.JIRA_Field_Api_Name__c.isAccessible() && Schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.DataType__c.isAccessible()){
                                                        ApiNamebyType.put(jpm.JIRA_Field_Api_Name__c, jpm.DataType__c);
                                                    }
                                                }
        
        return finalfields;
    }
    
    public static Map<String,String> getReportingFieldsMap(String ProjectID){
        Map<String,String> ApiNamebyType = New Map<String,String>();
        if(!Jira_ProjectFieldsMapping__c.sObjectType.getDescribe().isAccessible()){
            return null;
        } 
        for(Jira_ProjectFieldsMapping__c jpm : [SELECT Id, JIRA_Field_Api_Name__c, 
                                                Jira_Field_Name__c, IsReportingEnabled__c,DataType__c,isArray__c
                                                FROM Jira_ProjectFieldsMapping__c
                                                WHERE IsReportingEnabled__c = TRUE AND
                                                Jira_Project__c =: ProjectId]){
                                                    if(Schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.JIRA_Field_Api_Name__c.isAccessible() && Schema.sObjectType.Jira_ProjectFieldsMapping__c.fields.DataType__c.isAccessible()){
                                                        ApiNamebyType.put(jpm.JIRA_Field_Api_Name__c, jpm.DataType__c);
                                                    }
                                                }
        
        return ApiNamebyType;
    }
}