class ViatimagesSimpleSearchesController < SimpleSearchesController
  def show
    super

    # Restrict the search context to the images item type
    @simple_search_results = ItemList::SimpleSearchResult.new(
      :catalog => catalog,
      :query => @saved_search.query,
      :page => params[:page],
      :item_type_slug => 'images',
      :search_uuid => @saved_search.uuid
    )
  end
end
