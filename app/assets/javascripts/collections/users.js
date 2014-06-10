Quora.Collections.Users = Backbone.Collection.extend({
	url: "api/users",
  model: Quora.Models.User,

  getQuestionAuthor: function(question){
    var getAuthorCriteria = function(question){
      var userModel = this.get(question.attributes.author_id)
      return userModel
    };

    return this.findFilteredObjects(getAuthorCriteria.bind(this, question), question)
  },

});
_.extend(Quora.Collections.Users.prototype, Quora.CollectionMixIn);