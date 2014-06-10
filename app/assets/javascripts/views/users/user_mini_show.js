Quora.Views.UserMiniShow = Backbone.CompositeView.extend({
  template: JST["users/minishow"],
  templateJustName: JST["users/userName"],
  initialize: function(options){
    if (options.justName){
     this.justName = true 
    } else{
      var followingView = new Quora.Views.FollowingShow({object: this.model})
      this.addSubview(".following-btn", followingView)
    }
    this.listenTo(this.model, "sync change", this.render);
  },

  render: function () {
    var view = this;
    if (this.justName){ this.template = this.templateJustName}

    var renderedContent = this.template({
      user : this.model
    });
    this.$el.html(renderedContent);
    // this.attachSubviews()
    return this;
  },

});
