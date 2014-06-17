Quora.Collections.TopicQuestionJoins = Backbone.Collection.extend({

  model: Quora.Models.TopicQuestionJoin,

  getTopicJoins: function(question){
    var findTopicJoinCriteria = function(){
         return (parseInt(question.id) === this.get("question_id"))
    };

    return this.findFilteredObjects(findTopicJoinCriteria)
  },

  getQnJoins: function(topic_id){
    var findQnJoinCriteria = function(){
      return (parseInt(topic_id) === this.get("topic_id"))
    };

    return this.findFilteredObjects(findQnJoinCriteria)
  },

});
_.extend(Quora.Collections.TopicQuestionJoins.prototype, Quora.CollectionMixIn);