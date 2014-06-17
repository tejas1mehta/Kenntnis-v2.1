Quora.CollectionMixIn = {

  getOrAdd: function(id){
    var retModel = this.get(id);
    if (!retModel){
      retModel = new this.model({id:id})
      this.add(retModel)
    }

    return retModel
  },

  getObjects: function(arrayIDs){
    var objectsArray = this.filter(function(object){
      return _.contains(arrayIDs, object.id)
    })

    return objectsArray
  },

  findFilteredObjects: function(filteringCriteria, boundToModel){
    var sourceCollection = this;
    var filteredCollection = new this.constructor();

    var applyFilter = function() {
      filteredCollection.reset(sourceCollection.filter(function(sc){
        return (filteringCriteria.apply(sc))
      }));
    };

    var addFilter = function(newObject){
      if (filteringCriteria.apply(newObject)){
        filteredCollection.add(newObject)
      }
    };

    var removeFilter = function(oldObject){
      if (filteringCriteria.apply(oldObject)){
        filteredCollection.remove(oldObject)
      }
    };

    var unBindCollection = function(){
      console.log("UNBOUND")
      sourceCollection.unbind("add", addFilter)
      sourceCollection.unbind("remove", removeFilter)
      if (boundToModel){boundToModel.unbind("change", applyFilter)}
    }

    if (boundToModel){boundToModel.bind("change", applyFilter)}
    this.bind("add", addFilter);
    this.bind("remove", removeFilter);
    filteredCollection.bind("unbind", unBindCollection);

    applyFilter();
    return filteredCollection;
  },

  getOrFetch: function (id) {
    var curCollection = this;

    var curModel;
    if (curModel = this.get(id)) {
      curModel.fetch();
    } else {
      curModel = new this.model({ id: id });
      curModel.fetch({
        success: function () { curCollection.add(curModel,{merge:true, parse: true}); }
      });
    }

    return curModel;
  },
}
