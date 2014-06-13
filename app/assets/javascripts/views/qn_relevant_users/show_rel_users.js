Quora.Views.RelUserShow = Backbone.View.extend({
  template: JST["qn_relevant_users/show"],

  initialize: function (options) {
    this.listenTo(this.model, "sync change", this.render)
    // this.listenTo(Quora.upvotes, "add", this.render)
  },


  render: function () {
    var view = this;
    debugger
    var relUserIDs = [];
    Quora.relUserJoins.forEach(function (userJoin) {
     if (userJoin.get("question_id") == view.model.id){
      relUserIDs.push(userJoin.get("relevant_user_id"))
     }
    });

    var relUsers = Quora.relevantQnUsers.filter(function(relUser){ return (relUserIDs.indexOf(relUser.id) !== -1)});

    var renderedContent = this.template({
      relUsers : relUsers
    });
    this.$el.html(renderedContent);
    //this.attachSubviews();

    return this;
  },

});
