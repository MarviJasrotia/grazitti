public interface ITrigger{

    void bulkBefore();
    void bulkAfter();
    void beforeInsert(SObject so);
    void afterInsert(SObject so);
    void beforeUpdate(SObject oldSo, SObject so);
    void beforeDelete(SObject so);
    void afterUpdate(SObject newObj, SObject oldSo);
    void afterDelete(SObject so);
    void andFinally();

}