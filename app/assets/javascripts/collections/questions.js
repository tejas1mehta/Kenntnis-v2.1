Quora.Collections.Questions = Backbone.Collection.extend({
  url: "api/questions",
  model: Quora.Models.Question,


});
_.extend(Quora.Collections.Questions.prototype, Quora.CollectionMixIn);