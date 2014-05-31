Quora.Views.UserMiniShow = Backbone.CompositeView.extend({
  template: JST["users/minishow"],
  initialize: function(){
    var followingView = new Quora.Views.FollowingShow({object: this.model})
    this.addSubview(".following-btn", followingView)
  },
  render: function () {
    var view = this;

    var renderedContent = this.template({
      user : this.model
    });
    this.$el.html(renderedContent);

    return this;
  },

});
