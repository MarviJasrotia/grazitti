/**
 * @author Grazitti
 * used in AdminSetting controller for creating map between Salesforce case fields and jira fields
 *  
 */
public with sharing class FieldsWrapper{
    /**
     * Jira_ProjectFieldsMapping__c type variable to store the mapping details of sf and jira fields.
     */
    public Jira_ProjectFieldsMapping__c field{get;set;}
    /**
     *  String type helper variable which makes sure the datatype of jira and case fields match during the selection of mapping fields.
     */
    public String fieldType{get; set;}
       
    
    public FieldsWrapper(Jira_ProjectFieldsMapping__c field){
        this.field = field;
        fieldType = 'All';
    }
    public FieldsWrapper(){
         this.field = new Jira_ProjectFieldsMapping__c();
        fieldType = 'All';
    }
    
}