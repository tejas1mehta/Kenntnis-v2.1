Quora.Collections.Topics = Backbone.Collection.extend({
  url: "api/topics",
  model: Quora.Models.Topic,

  getTopics: function(arrayIDs){
    var topicsArray = this.filter(function(topic){
      return _.contains(arrayIDs, topic.id)
    })

    return topicsArray
  },
});
