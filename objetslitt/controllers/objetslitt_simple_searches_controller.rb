class ObjetslittSimpleSearchesController < SimpleSearchesController
  def show
    super

    # Override the search result list to show the "textes" tab appear first
    # by default on a search without a type parameter, unless there is no text
    # in the results.

    preferred_default_slug = "textes"

    # Override the active? method of the search results
    @simple_search_results.define_singleton_method(:active?) do |item_type|

      # Prevent making the "textes" tab active if it contains no results !
      # Otherwise it would hide occurrences when the search results contain no
      # text but other categories
      preferred_type_count = item_counts_by_type.find { |type, _| type.slug == preferred_default_slug }&.last || 0

      # Make the default result tab "textes" when there is at least one text
      if item_type_slug.present? or preferred_type_count == 0
        super(item_type)
      else
        item_type.slug == preferred_default_slug
      end
    end
  end
end
