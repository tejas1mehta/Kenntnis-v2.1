Quora.Views.UserSearchResults = Backbone.CompositeView.extend({
  template: JST["users/search_results"],

  initialize: function () {

  },

  render: function () {
    var view = this;

    var renderedContent = this.template();
    this.$el.html(renderedContent);
    if (this.model.searchView){
      this.model.searchView.forEach(function(searchViewObj){
        view.addSubview(("#search_results"), searchViewObj)
      })
    }

    return this;
  },

});
