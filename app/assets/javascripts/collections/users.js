Quora.Collections.Users = Backbone.Collection.extend({
	url: "api/users",
  model: Quora.Models.User,
  getOrFetchUser: function (id) {
    var curCollection = this;

    var curModel;

    if (!(curModel = this.get(id))){
      curModel = new this.model({ id: id });
    }

    curModel.fetch({
      data: {
           last_obj_time: 0,
           data_to_fetch: "profile_results"
      },
      success: function () {
        curCollection.add(curModel,{merge:true, parse: true});
      }
    });

    return curModel;
  },

});
_.extend(Quora.Collections.Users.prototype, Quora.CollectionMixIn);