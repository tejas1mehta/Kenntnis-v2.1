Quora.Models.QnRelevantUser = Backbone.Model.extend({
  // urlRoot: "api/followings",

  parse: function (response) {
    var question = this;
    if (response.relevant_user) {
      var relUser = new Quora.Models.User(response.relevant_user)
      var userExists = Quora.relevantQnUsers.filter(function(model) {return model.id === relUser.id});
      if (userExists.length === 0){
        Quora.relevantQnUsers.add(relUser)
      }
      console.log(Quora.relevantQnUsers)

      delete response.relevant_user;
    }

    return response
  },
});
