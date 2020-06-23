public  with sharing class RefreshFieldConfiguration {
    
    public void FetchProjects(){
        Database.executeBatch(new UpdateProjectRelatedData(),1);
    }
}