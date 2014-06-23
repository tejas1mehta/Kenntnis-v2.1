Quora.Collections.QuestionAnswers = Backbone.Collection.extend({
  url: function(){
    return "api/questions/" + this.question.get("id") + "/answers"
  },
  intialize: function(models, options){
    this.question = options.question;
  },
  model: Quora.Models.QuestionAnswer,
  comparator: function(model){
    return (-1*model.get("created_at"))
  },

});
