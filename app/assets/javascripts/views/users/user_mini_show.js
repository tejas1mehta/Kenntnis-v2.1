Quora.Views.UserMiniShow = Backbone.CompositeView.extend({
  template: JST["users/minishow"],
  initialize: function(options){
    if (!(this.justName = options.justName)){
      var followingView = new Quora.Views.FollowingShow({object: this.model})
      this.addSubview(".following-btn", followingView)
      this.$el.addClass("qns-des")
    } 
    this.listenTo(this.model, "sync change", this.render);
  },

  render: function () {
    var view = this;

    var renderedContent = this.template({
      user : this.model,
      onlyName: this.justName
    });

    this.$el.html(renderedContent);
    this.attachSubviews()
    return this;
  },

});
