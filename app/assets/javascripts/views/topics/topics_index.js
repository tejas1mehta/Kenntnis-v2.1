Quora.Views.TopicsIndex = Backbone.View.extend({

  template: JST['topics/index'],
  initialize: function () {
    this.listenTo(this.collection, "sync", this.render);
  },

  render: function () {
    var view = this;
    var renderedContent = this.template({
      topics : this.collection
    });

    this.$el.html(renderedContent);
    //this.attachSubviews();

    return this;
  },

});
