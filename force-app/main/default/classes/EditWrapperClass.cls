public class EditWrapperClass 
     {
         public Integer sno { get; set; }
         public SObject editWrapobj { get; set; }
         public String filter { get; set; }
         public Boolean isUpdateable { get; set; }
         public Boolean isRequired { get; set; }
         public String fieldName { get; set; }
         public String fieldValue { get; set; }
         public String objectName { get; set; }
         public String vPlayId { get; set; }
         public String dataType { get; set; } 
         public String childId { get; set; }
         public List<SelectOption> dependentPickList { get; set; }
     }