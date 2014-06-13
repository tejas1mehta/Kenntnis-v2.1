Quora.CollectionMixIn = {
  addOrReplace: function(modelResponse){
    var newModel = new this.model(modelResponse, {parse: true});
    var modelExists = this.filter(function(model) {return model.id === newModel.id});
    if (modelExists.length === 0){ 
      this.add(newModel)
    } else {
      var modelIndex = this.indexOf(modelExists)
      this[modelIndex] = newModel
    }
  },

  findFilteredObjects: function(filteringCriteria, boundToModel){
    var sourceCollection = this;
    var filteredCollection = new this.constructor();

    var applyFilter = function() {
      filteredCollection.reset(filteringCriteria());
      // console.log(filteredCollection)
    };

    if (boundToModel){boundToModel.bind("change", applyFilter)}
    this.bind("change", applyFilter);
    this.bind("add", applyFilter);
    this.bind("remove", applyFilter);

    applyFilter();
    return filteredCollection;
  },
}