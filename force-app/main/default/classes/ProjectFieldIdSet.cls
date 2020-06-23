public class ProjectFieldIdSet {
    public Jira_ProjectFieldsMapping__c Field{get;set;}
    public map<id,id> RelatedFields{get;set;} 
    public ProjectFieldIdSet(Jira_ProjectFieldsMapping__c Field,map<id,id> RelatedFields){
        this.Field=Field;
        this.RelatedFields=RelatedFields;
    }
}