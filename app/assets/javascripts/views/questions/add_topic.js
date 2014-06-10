Quora.Views.AddTopic = Backbone.CompositeView.extend({
  template: JST["questions/add_topics"],

  initialize: function () {
    this.listenTo(this.collection, "sync", this.render);
  },

  render: function () {
    var view = this;
    console.log("rendereing topcis to add")

    var renderedContent = this.template({
      allTopics : this.collection
    });

    this.$el.html(renderedContent);

    return this;
  }
})