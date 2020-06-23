Global class AutoCreateJira  {
    @InvocableMethod
    Global static void AutoCreateJira(List<String> SobjectId_Project_Type){
        BatchToAutoCreateJira batchjira=new BatchToAutoCreateJira(SobjectId_Project_Type);
        Database.executeBatch(batchjira,1);
    }
}