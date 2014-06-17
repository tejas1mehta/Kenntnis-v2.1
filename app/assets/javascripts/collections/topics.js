Quora.Collections.Topics = Backbone.Collection.extend({
  url: "api/topics",
  model: Quora.Models.Topic,
});
_.extend(Quora.Collections.Topics.prototype, Quora.CollectionMixIn);