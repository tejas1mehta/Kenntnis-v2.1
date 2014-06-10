Quora.Collections.TopicQuestionJoins = Backbone.Collection.extend({

  model: Quora.Models.TopicQuestionJoin,

  getTopicJoins: function(question){
    var findTopicJoinsCriteria = function(question){
      var qnTopicJoins = this.filter(function(topicJoin){
         return (parseInt(question.id) === topicJoin.get("question_id"))
      });

      return qnTopicJoins
    };

    return this.findFilteredObjects(findTopicJoinsCriteria.bind(this, question))
  },

});
_.extend(Quora.Collections.TopicQuestionJoins.prototype, Quora.CollectionMixIn);