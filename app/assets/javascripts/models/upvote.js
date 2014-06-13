Quora.Models.Upvote = Backbone.Model.extend({
  urlRoot: "api/upvotes",
  parse: function(response){
    return response
  }
}); 
